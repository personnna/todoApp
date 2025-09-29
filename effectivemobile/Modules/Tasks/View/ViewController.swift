//
//  ViewController.swift
//  effectivemobile
//
//  Created by ellkaden on 23.09.2025.
//

import UIKit
import SnapKit

//protocol TasksPresenterProtocol: AnyObject {
//    func viewDidLoad()
//    func getTask(at index: Int) -> TaskViewModel
//    func numberOfTasks() -> Int
//    // ... другие методы
//}

class ViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource {
    
    private var tasks: [TaskViewModel] = []
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        searchBar.searchBarStyle = .minimal
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.textColor = .white // Ваш цвет
            // Также можно настроить цвет placeholder'а
            textField.attributedPlaceholder = NSAttributedString(
                string: "Search",
                attributes: [.foregroundColor: UIColor.lightGray]
            )
        } 
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    private let bottomBar = BottomBar()
    
    var presenter: TasksPresenterProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewController loaded")
        view.backgroundColor = .background
        navigationController?.navigationBar.tintColor = .yellowButton
        navigationItem.backButtonTitle = "Назад"
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TaskCell.self, forCellReuseIdentifier: TaskCell.reuseIdentifier)
        tableView.isUserInteractionEnabled = true
        setupView()
        setupConstraints()
        presenter?.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 64
        
    }

    private func setupView(){
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(bottomBar)
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.appFont(ofSize: 34, weight: .bold)
        ]
        
        let titleLabel = UILabel()
        titleLabel.text = "Задачи"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 28)
        titleLabel.textColor = .white

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        
        bottomBar.editButton.addTarget(self, action: #selector(didTapEditButton), for: .touchUpInside)


    }
    
    @objc private func didTapEditButton() {
        print("логику написать при добавлении")
        presenter?.didTapAddButton()
    }
    
    private func setupConstraints(){
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview().inset(8)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        bottomBar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview() // будет перекрывать safe area
            make.height.equalTo(70 + view.safeAreaInsets.bottom) // учтем "подбородок"
        }
        
        let bottomBarHeight: CGFloat = 50
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomBarHeight, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: bottomBarHeight, right: 0)
    }
}

extension ViewController{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("Началось редактирование.")
        searchBar.becomeFirstResponder()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter?.didChangeSearchText(searchText)
    }
    
    
    

}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("UITableView is asking for rows.") // <-- ADD THIS LINE
        return presenter?.numberOfTasks() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskCell.reuseIdentifier, for: indexPath) as? TaskCell else {
            return UITableViewCell()
        }
        
        if let taskViewModel = presenter?.getTask(at: indexPath) {
            cell.configure(with: taskViewModel)
        }
        
        cell.backgroundColor = .clear
        cell.selectedBackgroundView?.backgroundColor = .clear
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willBeginContextMenuInteractionAt indexPath: IndexPath, point: CGPoint) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.setSelected(false, animated: false)
            cell.setHighlighted(true, animated: false)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            presenter?.didDeleteTask(at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Нажатие сработало на ячейке \(indexPath.row)!")

        
        if presenter == nil {
            print("ПРЕЗЕНТЕР РАВЕН NIL! Навигация невозможна.")
        }
        tableView.deselectRow(at: indexPath, animated: true)
        presenter?.didSelectTask(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let task = tasks[indexPath.row]
        
        // 1. Создаем основной конфигурационный объект
        return UIContextMenuConfiguration(
            identifier: nil, // Можно использовать ID для идентификации
            previewProvider: {
                // ПРЕДПРОСМОТР: Что должно отображаться в окне?
                // Возвращаем UIViewController, который показывает содержимое ячейки
                return self.makeTaskPreviewViewController(for: task)
            },
            actionProvider: { _ in
                // ДЕЙСТВИЯ: Создаем список пунктов меню (Редактировать, Поделиться, Удалить)
                return self.makeContextMenu(for: indexPath)
            }
        )
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true // Оставляем true для обычных коротких нажатий
    }
    
    // Этот метод не позволяет ячейке выделяться после активации меню
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        // Мы можем принудительно отменить выделение, если оно произошло
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
}

extension ViewController: TasksViewProtocol {
    
    func displayTasks(_ tasks: [TaskViewModel]) {
        self.tasks = tasks
        self.tableView.reloadData()
        self.bottomBar.updateTaskCount(count: tasks.count)
    }
    
    // 2. Loading State Methods
    func showLoading() {
        // You can simply print here or show a loading indicator
        print("View: Showing loading indicator...")
    }
    
    func hideLoading() {
        // You can simply print here or hide the loading indicator
        print("View: Hiding loading indicator.")
    }
    
    // 3. Task Deletion Method
    func removeTask(at indexPath: IndexPath) {
        // Use the built-in animation
        tableView.deleteRows(at: [indexPath], with: .automatic)
        bottomBar.updateTaskCount(count: tasks.count)
    }
    
    func updateCount(count: Int) {
        bottomBar.updateTaskCount(count: count)
    }
    
    private func makeContextMenu(for indexPath: IndexPath) -> UIMenu {
        // Получаем задачу, если нужно передать ее в действие
        let task = tasks[indexPath.row]
        
        // 1. Действие "Редактировать"
        let editAction = UIAction(title: "Редактировать", image: UIImage(systemName: "pencil")) { [weak self] action in
            // Вызываем логику редактирования (как при нажатии на ячейку)
            self?.presenter?.didSelectTask(at: indexPath)
        }
        
        // 2. Действие "Поделиться" (Можно реализовать позже)
        let shareAction = UIAction(title: "Поделиться", image: UIImage(systemName: "square.and.arrow.up")) { action in
            print("Поделиться задачей: \(task.name)")
            // Здесь может быть вызов UIActivityViewController
        }
        
        // 3. Действие "Удалить"
        let deleteAction = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] action in
            // Вызываем логику удаления, которую мы уже настроили
            self?.presenter?.didDeleteTask(at: indexPath)
        }
        
        // Создаем меню
        return UIMenu(title: "", children: [editAction, shareAction, deleteAction])
    }
    
    // Создает контроллер для предварительного просмотра (похожий на ячейку)
    private func makeTaskPreviewViewController(for task: TaskViewModel) -> UIViewController {
        let previewVC = UIViewController()
        previewVC.view.backgroundColor = .backgroundGray
        
        let nameLabel = UILabel()
        nameLabel.numberOfLines = 1
        nameLabel.text = task.name
        nameLabel.textColor = .white
        nameLabel.font = .appFont(ofSize: 16, weight: .medium)
        nameLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        let descriptionLabel = UILabel()
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = task.description
        descriptionLabel.textColor = .white
        descriptionLabel.font = .appFont(ofSize: 12, weight: .regular)
        descriptionLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        descriptionLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        let dateLabel = UILabel()
        dateLabel.numberOfLines = 1
        dateLabel.textColor = .gray
        dateLabel.text = task.creationDate
        dateLabel.font = .appFont(ofSize: 12, weight: .regular)
        
        let stackView = UIStackView(arrangedSubviews: [nameLabel, descriptionLabel, dateLabel])
        stackView.axis = .vertical
        stackView.spacing = 6
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false

        
        previewVC.view.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16))
        }
        let preferredWidth: CGFloat = 350
        let fittingSize = stackView.systemLayoutSizeFitting(
            CGSize(width: preferredWidth, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        
        previewVC.preferredContentSize = CGSize(width: preferredWidth, height: fittingSize.height)

        return previewVC
    }
    
    func didSaveNewTask() {
        // 1. Отладочный вывод
        print("TasksVC: Делегат сработал! Запрашиваем обновление...")
        
        // 2. Запрашиваем у Presenter повторную загрузку данных
        // (Presenter вызовет Interactor, который загрузит данные,
        // и затем вызовет view.displayTasks()).
        presenter?.viewDidLoad()
    }
    
    
    
//    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
//        // Блокируем стандартную подсветку, чтобы избежать белого мигания.
//        // Явно устанавливаем цвет фона, чтобы он не менялся.
//        let targetColor: UIColor = .clear // или цвет, который вы используете для ячейки
//        
//        if animated {
//            UIView.animate(withDuration: 0.1) {
//                self.contentView.backgroundColor = targetColor
//                self.backgroundColor = targetColor
//            }
//        } else {
//            self.contentView.backgroundColor = targetColor
//            self.backgroundColor = targetColor
//        }
//    }
}

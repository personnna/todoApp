//
//  DetailViewController.swift
//  effectivemobile
//
//  Created by ellkaden on 26.09.2025.
//

import UIKit
import SnapKit

class DetailViewController: UIViewController {
    
    weak var delegate: TaskUpdateDelegate?
    
    var presenter: DetailPresenterProtocol? 
    
    var task: TaskViewModel?
    
    // MARK: - UI Components
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .leading
        return stack
    }()
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Название задачи"
        textField.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        textField.textColor = .white
        textField.backgroundColor = .clear // Темный фон для поля ввода
        textField.borderStyle = .none // Красивые скругленные углы
        return textField
    }()
    
    private let dateCreatedLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .lightGray
        return label
    }()
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textView.textColor = .white
        textView.backgroundColor = .clear
        textView.tintColor = .yellowButton
        textView.text = "Описание задачи..."
        textView.contentInset = UIEdgeInsets.zero
        return textView
    }()
    
    // MARK: - Initialization
    
    init(task: TaskViewModel? = nil) {
        self.task = task
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        
        setupUI()
        configureWithTask()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = task != nil ? "" : "Новая задача"
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(
//            title: "Сохранить",
//            style: .done,
//            target: self,
//            action: #selector(saveTapped)
//        )
        
        view.addSubview(stackView)
        
        stackView.addArrangedSubview(titleTextField)
        stackView.addArrangedSubview(dateCreatedLabel)
        stackView.addArrangedSubview(descriptionTextView)
        
        if task == nil {
            dateCreatedLabel.isHidden = true
        } else {
            stackView.addArrangedSubview(dateCreatedLabel)
        }
        
//        stackView.snp.makeConstraints { make in
//            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
//            make.leading.trailing.equalToSuperview().inset(20)
//        }
//        
        titleTextField.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.width.equalToSuperview() // Занимает всю ширину стэка
        }
        descriptionTextView.snp.makeConstraints { make in
            make.height.equalTo(150) // Даем ему фиксированную высоту для формы
            make.width.equalToSuperview()
        }
        stackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
    // MARK: - Data Configuration
    
    private func configureWithTask() {
//        guard let task = task else {
//            // Режим добавления новой задачи
//            titleTextField.text = "Введите название"
//            return
//        }
//        
//        let newFormat = convertDateFormat(dateString: task.creationDate)
//        titleTextField.text = task.name
//        dateCreatedLabel.text = newFormat
//        descriptionTextView.text = task.description
        
        if let task = task {
            titleTextField.text = task.name
            descriptionTextView.text = task.description
            
            // Кнопка "Сохранить" теперь должна вызывать didRequestUpdateTask
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Обновить",
                style: .done,
                target: self,
                action: #selector(saveTapped) // saveTapped будет обрабатывать оба случая
            )
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // ✅ ОТЛАДКА: Проверяем, что метод вообще сработал
        print("DetailVC: viewWillDisappear сработал.")
        
        if let presenter = presenter {
            
            let title = titleTextField.text ?? ""
            let description = descriptionTextView.text ?? ""
            
            // 1. Проверка, есть ли вообще данные для сохранения/обновления
            if title.isEmpty && description.isEmpty {
                print("DetailVC: Заголовок и описание пусты. Сохранение пропущено.")
                return
            }
            
            // 2. Логика добавления/редактирования
            if let existingTask = task {
                // РЕЖИМ РЕДАКТИРОВАНИЯ
                print("DetailVC: Запрос на обновление задачи ID: \(existingTask.id)")
                presenter.didRequestUpdateTask(
                    id: Int(existingTask.id),
                    title: title,
                    description: description
                )
            } else {
                // РЕЖИМ ДОБАВЛЕНИЯ
                print("DetailVC: Запрос на добавление новой задачи.")
                presenter.didRequestSaveNewTask(
                    title: title,
                    description: description
                )
            }
            
            // 3. ✅ КЛЮЧЕВОЙ МОМЕНТ: Вызов Делегата
            delegate?.didSaveNewTask()
            print("DetailVC: Вызван delegate?.didSaveNewTask()")
        } else {
            print("DetailVC: Presenter равен nil! Невозможно сохранить.")
        }
    }
    
    func convertDateFormat(dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd.MM.yyyy"
        
        guard let date = inputFormatter.date(from: dateString) else {
            return dateString
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd/MM/yyyy"
        
        return outputFormatter.string(from: date)
    }
    
    @objc private func saveTapped() {
        // 1. Вызываем Presenter для сохранения
        presenter?.didRequestSaveNewTask(
            title: titleTextField.text ?? "",
            description: descriptionTextView.text ?? ""
        )
        
        // 2. ✅ Вызываем делегата (для обновления TasksVC)
        delegate?.didSaveNewTask()
        
        // 3. Закрываем модальное окно
        dismiss(animated: true)
    }
    
//    @objc private func saveTapped() {
//        if let existingTask = task {
//            // РЕЖИМ РЕДАКТИРОВАНИЯ
//            presenter?.didRequestUpdateTask(
//                id: existingTask.id, // Нужен ID для обновления
//                title: titleTextField.text ?? "",
//                description: descriptionTextView.text ?? ""
//            )
//        } else {
//            // РЕЖИМ ДОБАВЛЕНИЯ
//            presenter?.didRequestSaveNewTask(
//                title: titleTextField.text ?? "",
//                description: descriptionTextView.text ?? ""
//            )
//        }
//        
//        delegate?.didSaveNewTask()
//        dismiss(animated: true)
//    }
}

//
//  ViewController.swift
//  effectivemobile
//
//  Created by ellkaden on 23.09.2025.
//

import UIKit
import SnapKit

class ViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Задачи"
        label.font = .appFont(ofSize: 34, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        searchBar.searchBarStyle = .minimal
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewController loaded")
        view.backgroundColor = .background
        searchBar.delegate = self
        tableView.register(TaskCell.self, forCellReuseIdentifier: TaskCell.reuseIdentifier)
        tableView.dataSource = self
        setupView()
        setupConstraints()
    }

    private func setupView(){
        view.addSubview(titleLabel)
        view.addSubview(searchBar)
        view.addSubview(tableView)
    }
    
    private func setupConstraints(){
        titleLabel.snp.makeConstraints{  make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.equalToSuperview().offset(20)
        }
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(8)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension ViewController{
    // Этот метод вызывается, когда пользователь начинает редактировать текст
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // Здесь можно показать дополнительную UI, если нужно
    }

    // Этот метод вызывается, когда пользователь нажимает на кнопку поиска на клавиатуре
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // Скрыть клавиатуру
        // Здесь можно запустить поиск по введенному тексту
    }

    // Этот метод вызывается при изменении текста
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Здесь можно реализовать поиск в реальном времени
    }
}

extension ViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfTasks() // Запрос у Presenter количества задач
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskCell.reuseIdentifier, for: indexPath) as? TaskCell else {
            return UITableViewCell()
        }

        // Получение готовой ViewModel от Presenter
        let taskViewModel = presenter.getTask(at: indexPath.row)
        
        // Настройка ячейки с помощью метода configure
        cell.configure(with: taskViewModel)

        return cell
    }
}

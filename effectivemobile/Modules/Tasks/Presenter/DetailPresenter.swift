//
//  DetailPresenter.swift
//  effectivemobile
//
//  Created by ellkaden on 26.09.2025.
//

class DetailPresenter: DetailPresenterProtocol {
    weak var view: DetailViewController? // DetailViewController
    var interactor: DetailInteractorInputProtocol?
    var router: DetailRouterProtocol? // Или используйте TasksRouter, если он управляет навигацией
    
    func didRequestSaveNewTask(title: String, description: String) {
        // Передаем запрос Interactor'у
        interactor?.saveNewTask(title: title, description: description)
    }
    
    func didRequestUpdateTask(id: Int, title: String, description: String) {
        // Просто передаем команду Interactor'у
        interactor?.updateTask(id: id, title: title, description: description)
    }
}


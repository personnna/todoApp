//
//  DetailPresenter.swift
//  effectivemobile
//
//  Created by ellkaden on 26.09.2025.
//

class DetailPresenter: DetailPresenterProtocol {
    weak var view: DetailViewController?
    var interactor: DetailInteractorInputProtocol?
    var router: DetailRouterProtocol?
    
    func didRequestSaveNewTask(title: String, description: String) {
        interactor?.saveNewTask(title: title, description: description)
    }
    
    func didRequestUpdateTask(id: Int, title: String, description: String) {
        interactor?.updateTask(id: id, title: title, description: description)
    }
}


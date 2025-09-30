//
//  TasksRouter.swift
//  effectivemobile
//
//  Created by ellkaden on 23.09.2025.
//

import UIKit

class TasksRouter: TasksRouterProtocol {
    weak var viewController: UIViewController?
    func navigateToAddTask() {
        let detailVC = DetailViewController(task: nil)
        
        let detailPresenter = DetailPresenter()
        let detailInteractor = TasksInteractor()
        
        detailVC.presenter = detailPresenter
        detailPresenter.interactor = detailInteractor
        detailPresenter.view = detailVC
        
        if let tasksUpdateDelegate = viewController as? TaskUpdateDelegate {
            detailVC.delegate = tasksUpdateDelegate
        }
        
        let navController = UINavigationController(rootViewController: detailVC)
        viewController?.present(navController, animated: true)
    }
    
    func navigateToTaskDetails(with task: TaskViewModel) {
        let detailVC = DetailViewController(task: task)
        
        let detailPresenter = DetailPresenter()
        let detailInteractor = TasksInteractor()
        
        detailVC.presenter = detailPresenter
        detailPresenter.interactor = detailInteractor
        detailPresenter.view = detailVC
        
        if let tasksVC = viewController as? TaskUpdateDelegate {
            detailVC.delegate = tasksVC
        }
        
        viewController?.navigationController?.pushViewController(detailVC, animated: true)
    }
}

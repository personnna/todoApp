//
//  TasksRouter.swift
//  effectivemobile
//
//  Created by ellkaden on 23.09.2025.
//

import UIKit

class TasksRouter: TasksRouterProtocol {
    weak var viewController: UIViewController?
    
    // ...
    
    // ИСПРАВЛЕНИЕ: МЕТОД ДОБАВЛЕНИЯ (когда жмете кнопку 'плюс')
    func navigateToAddTask() {
        let detailVC = DetailViewController(task: nil)
        
        // 1. ✅ КЛЮЧЕВОЙ ШАГ: Инициализация Presenter и Interactor для DetailVC
        let detailPresenter = DetailPresenter()
        let detailInteractor = TasksInteractor() // Или DetailInteractor
        
        // 2. ✅ СВЯЗЫВАНИЕ КОМПОНЕНТОВ (DetailVC.presenter НЕ ДОЛЖЕН БЫТЬ nil)
        detailVC.presenter = detailPresenter
        detailPresenter.interactor = detailInteractor
        detailPresenter.view = detailVC
        
        // 3. Установка Делегата (для обновления TasksVC)
        if let tasksUpdateDelegate = viewController as? TaskUpdateDelegate {
            detailVC.delegate = tasksUpdateDelegate
        }
        
        let navController = UINavigationController(rootViewController: detailVC)
        viewController?.present(navController, animated: true) // Модально
    }
    
    // ИСПРАВЛЕНИЕ: МЕТОД РЕДАКТИРОВАНИЯ (когда жмете на ячейку)
    func navigateToTaskDetails(with task: TaskViewModel) {
        let detailVC = DetailViewController(task: task)
        
        // 1. ✅ КЛЮЧЕВОЙ ШАГ: Инициализация Presenter и Interactor для DetailVC
        let detailPresenter = DetailPresenter()
        let detailInteractor = TasksInteractor()
        
        // 2. ✅ СВЯЗЫВАНИЕ КОМПОНЕНТОВ
        detailVC.presenter = detailPresenter
        detailPresenter.interactor = detailInteractor
        detailPresenter.view = detailVC
        
        // 3. Установка делегата
        if let tasksVC = viewController as? TaskUpdateDelegate {
            detailVC.delegate = tasksVC
        }
        
        // 4. Push (НЕ present!)
        viewController?.navigationController?.pushViewController(detailVC, animated: true)
    }
}

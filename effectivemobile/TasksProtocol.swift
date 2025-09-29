//
//  TasksProtocol.swift
//  effectivemobile
//
//  Created by ellkaden on 23.09.2025.
//

import Foundation

protocol TasksViewProtocol: AnyObject {
    func displayTasks(_ tasks: [TaskViewModel])
    func showLoading()
    func hideLoading()
    func removeTask(at indexPath: IndexPath)
    func updateCount(count: Int)
}

protocol TasksPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didSelectTask(at indexPath: IndexPath)
    func numberOfTasks() -> Int
    func getTask(at indexPath: IndexPath) -> TaskViewModel
    func didDeleteTask(at indexPath: IndexPath) // Новый метод
    func didTapAddButton()
    func didChangeSearchText(_ text: String)
}

protocol TasksInteractorInputProtocol: AnyObject {
//    func fetchTasks()
    func deleteTask(withID id: Int)
    func fetchTasks(with predicate: NSPredicate?)
    func saveNewTask(title: String, description: String)
    func updateTask(id: Int, title: String, description: String) // ✅ Проверьте, что он тут есть

}

protocol TasksInteractorOutputProtocol: AnyObject {
    func didFetchTasks(_ tasks: [TaskViewModel])
    func didFailToFetchTasks(with error: Error)
    func taskDidDelete(at indexPath: IndexPath)
    func showLoading() // Presenter'у нужно вызвать View для показа загрузки
    func hideLoading() 

}

protocol TasksRouterProtocol: AnyObject {
    func navigateToTaskDetails(with task: TaskViewModel)
    func navigateToAddTask()
}

protocol TasksPresenterInput: AnyObject {
    func viewDidLoad()
    
}

protocol TasksPresenterOutput: AnyObject {
    func displayTasks(_ tasks: [TaskViewModel])
}

protocol DetailPresenterProtocol: AnyObject {
    // Вызывается DetailViewController для сохранения новой задачи
    func didRequestSaveNewTask(title: String, description: String)
    
    func didRequestUpdateTask(id: Int, title: String, description: String)
    
    // Методы для редактирования (реализуем позже)
    // func didRequestUpdateTask(...)
}

protocol DetailInteractorInputProtocol: AnyObject {
    // Вызывается Presenter'ом для сохранения в Core Data
    func saveNewTask(title: String, description: String)
    func updateTask(id: Int, title: String, description: String)

}
// В TasksProtocols.swift (или DetailProtocols.swift)


// Протокол для навигации из DetailPresenter
protocol DetailRouterProtocol: AnyObject {
    // Добавьте методы навигации, если они нужны в DetailVC
}

protocol TaskUpdateDelegate: AnyObject {
    func didSaveNewTask()
}

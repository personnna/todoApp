//
//  TasksPresenter.swift
//  effectivemobile
//
//  Created by ellkaden on 23.09.2025.
//

import Foundation

class TasksPresenter: TasksPresenterProtocol, TasksInteractorOutputProtocol {
    func showLoading() {
        view?.showLoading()
    }
    
    func hideLoading() {
        view?.hideLoading()
    }
    
    
    private var tasks: [TaskViewModel] = []
    
    weak var view: TasksViewProtocol? 
    var interactor: TasksInteractorInputProtocol?
    var router: TasksRouterProtocol?

    // MARK: - TasksPresenterProtocol
    func viewDidLoad() {
        view?.showLoading()
        interactor?.fetchTasks(with: nil)
    }
    
    func didDeleteTask(at indexPath: IndexPath) {
        let taskToDelete = tasks[indexPath.row]
        
        tasks.remove(at: indexPath.row)
        let taskId = Int(taskToDelete.id)
        
        interactor?.deleteTask(withID: taskId)
        
        view?.removeTask(at: indexPath)
        view?.updateCount(count: tasks.count)
    }
    
    func taskDidDelete(at indexPath: IndexPath) {
        // Обновляем UI на главном потоке
        DispatchQueue.main.async { [weak self] in
            // Сообщаем View удалить строку с анимацией
            self?.view?.removeTask(at: indexPath)
        }
    }
    
    func getTask(at indexPath: IndexPath) -> TaskViewModel {
        return tasks[indexPath.row]
    }

    func didSelectTask(at indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        router?.navigateToTaskDetails(with: task)
    }

    func numberOfTasks() -> Int {
        return tasks.count
    }

    // MARK: - TasksInteractorOutputProtocol
    func didFetchTasks(_ tasks: [TaskViewModel]) {
        self.tasks = tasks
        print("Presenter received \(tasks.count) tasks.") // <-- ADD THIS LINE
        DispatchQueue.main.async { [weak self] in
            self?.view?.hideLoading()
            self?.view?.displayTasks(tasks)
        }
    }

    func didFailToFetchTasks(with error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.view?.hideLoading()
        }
    }
    
    func didTapAddButton() {
        router?.navigateToAddTask()
    }
    
    func didChangeSearchText(_ text: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let predicate: NSPredicate?
        
        if trimmedText.isEmpty {
            predicate = nil
        } else {
            predicate = NSPredicate(format: "name CONTAINS[cd] %@ OR todoDescription CONTAINS[cd] %@", trimmedText, trimmedText)
        }

        interactor?.fetchTasks(with: predicate)
    }
}

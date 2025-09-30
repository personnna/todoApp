//
//  TasksInteractor.swift
//  effectivemobile
//
//  Created by ellkaden on 23.09.2025.
//

import Foundation

class TasksInteractor: TasksInteractorInputProtocol {
    
    
    weak var presenter: TasksInteractorOutputProtocol?
    var coreDataManager: CoreDataManager?
    var apiService: APIService?
    

    func fetchTasks(with predicate: NSPredicate? = nil) {
        
        DispatchQueue.main.async { [weak self] in
            self?.presenter?.showLoading()
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            print("Interactor: Initiating data fetch with predicate: \(predicate != nil ? "YES" : "NO")")
            
            let fetchedTodos = self.coreDataManager?.fetchTodos(with: predicate) ?? []
            

            if fetchedTodos.isEmpty && predicate == nil {
                self.loadFromAPI()
            } else {
                let viewModels = fetchedTodos.map { todo in
                    return TaskViewModel(
                        id: Int64(Int(todo.id)),
                        name: todo.name ?? "",
                        description: todo.todoDescription ?? "",
                        creationDate: todo.creationDate != nil ? DateFormatter.appDateFormat.string(from: todo.creationDate!) : "",
                        isCompleted: todo.isCompleted
                    )
                }
                
                DispatchQueue.main.async {
                    self.presenter?.didFetchTasks(viewModels)
                    self.presenter?.hideLoading()
                }
            }
        }
    }
    
    private func loadFromAPI() {
        self.apiService?.fetchTodos { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let apiTodos):
                let viewModels = apiTodos.map { apiTodo in
                    return TaskViewModel(
                        id: Int64(apiTodo.id),
                        name: apiTodo.todo,
                        description: apiTodo.todo,
                        creationDate: DateFormatter.appDateFormat.string(from: Date()),
                        isCompleted: apiTodo.completed
                    )
                }
                DispatchQueue.main.async {
                    self.presenter?.didFetchTasks(viewModels)
                    self.presenter?.hideLoading()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.presenter?.didFailToFetchTasks(with: error)
                    self.presenter?.hideLoading()
                }
            }
        }
    }

    private func generateRandomDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let randomTimeInterval = TimeInterval.random(in: -3600 * 24 * 365...0)
        let randomDate = Date().addingTimeInterval(randomTimeInterval)
        return formatter.string(from: randomDate)
    }
    
    func deleteTask(withID id: Int) {
        // Выполняем удаление в Core Data на фоновом потоке
        DispatchQueue.global(qos: .utility).async { [weak self] in
            self?.coreDataManager?.deleteTodo(withID: id)
            // Здесь Presenter'у больше не нужно ничего сообщать,
            // т.к. View уже обновился.
        }
    }

}


extension TasksInteractor: DetailInteractorInputProtocol {
    func updateTask(id: Int, title: String, description: String) {

        coreDataManager?.updateTask(
            with: Int(id),
            newTitle: title,
            newDescription: description
        )
    }
    
    func saveNewTask(title: String, description: String) {
                
        print("Interactor: Получена команда на сохранение новой задачи: \(title)")
        
        let newTaskData = APITodo(
            id: Int.random(in: 1000...9999),
            todo: title,
            completed: false,
            userId: 1
        )
        
    
        let result = coreDataManager?.save(from: newTaskData)

        
        if result == nil {
            print("🛑 Interactor: CoreDataManager.save вернул nil. Ошибка сохранения в Core Data.")
        } else {
            print("✅ Interactor: Сохранение Core Data выполнено успешно.")
        }
    }
}


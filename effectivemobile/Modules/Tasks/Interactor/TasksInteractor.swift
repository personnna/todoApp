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
        
        // 1. Показываем загрузку (в основном потоке)
        DispatchQueue.main.async { [weak self] in
            self?.presenter?.showLoading()
        }
        
        // 2. Выполняем загрузку/фильтрацию в фоновом потоке
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            print("Interactor: Initiating data fetch with predicate: \(predicate != nil ? "YES" : "NO")")
            
            // 3. ✅ КЛЮЧЕВОЙ ШАГ: Используем предикат для загрузки из Core Data
            let fetchedTodos = self.coreDataManager?.fetchTodos(with: predicate) ?? []
            
            // Если Core Data вернула результат (даже пустой), мы используем его.
            // Логика API должна запускаться, только если Core Data ВООБЩЕ пуста.
            if fetchedTodos.isEmpty && predicate == nil {
                // Если нет кеша и нет активного поиска, тогда загружаем из API
                self.loadFromAPI()
            } else {
                // 4. Преобразуем и отправляем Presenter'у
                let viewModels = fetchedTodos.map { todo in
                    return TaskViewModel(
                        // ✅ ИСПРАВЛЕНИЕ: id должен быть Int, а не Int64
                        id: Int64(Int(todo.id)),
                        name: todo.name ?? "",
                        description: todo.todoDescription ?? "",
                        // ✅ ИСПРАВЛЕНИЕ ДАТЫ: Используем ваш DateFormatter для консистентности
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
            
            // ... (логика API - она у вас верна)
            switch result {
            case .success(let apiTodos):
                let viewModels = apiTodos.map { apiTodo in
                    // Здесь также нужно сохранять apiTodos в Core Data
                    // self.coreDataManager?.save(from: apiTodo) // <-- Не забудьте об этом
                    return TaskViewModel(
                        id: Int64(apiTodo.id),
                        name: apiTodo.todo,
                        description: apiTodo.todo,
                        // ✅ ИСПРАВЛЕНИЕ ДАТЫ: Снова используем наш стандартный форматтер
                        creationDate: DateFormatter.appDateFormat.string(from: Date()), // Используйте реальную дату, если API ее не дает
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
//    func saveNewTask(title: String, description: String) {
//        // 1. Создаем структуру для передачи данных
//        
//        // 💡 Нам нужно передать значение 'title' в свойство 'todo'
//        // 💡 Нам нужно передать значение 'description' в какое-то поле (мы проигнорируем его пока)
//        // 💡 Нам нужно предоставить значение для 'userId'
//        
//        let newTaskData = APITodo(
//            id: Int.random(in: 1000...9999), // Временно генерируем ID
//            
//            // ✅ ИСПРАВЛЕНО: Свойство 'todo' (из APITodo) берет значение из 'title'
//            todo: title,
//            
//            // ✅ ИСПРАВЛЕНО: Свойство 'completed' берет значение из 'isCompleted'
//            completed: false, // Теперь 'completed'
//            
//            // ✅ ИСПРАВЛЕНО: Предоставляем недостающий 'userId'
//            userId: 1 // Используйте реальный userId или заглушку
//        )
//        
//        // 2. Сохраняем в Core Data
//        coreDataManager?.save(from: newTaskData)
//        
//        // 3. (ОПЦИОНАЛЬНО) Обновление UI
//        // ...
//    }
    
    func updateTask(id: Int, title: String, description: String) {
        
        // Передаем команду в CoreDataManager для поиска задачи по ID
        // и обновления ее данных.
        coreDataManager?.updateTask(
            with: Int(id), // ✅ ИСПРАВЛЕНИЕ
            newTitle: title,
            newDescription: description
        )
        
        // Примечание: Если CoreDataManager.updateTask() бросает ошибку,
        // здесь нужно добавить обработку (но для дедлайна можно оставить так).
    }
    
    func saveNewTask(title: String, description: String) {
                
        // ✅ ОТЛАДКА: Проверяем, дошла ли команда
        print("Interactor: Получена команда на сохранение новой задачи: \(title)")
        
        // 1. Создание APITodo (для передачи в Core Data Manager)
        let newTaskData = APITodo(
            id: Int.random(in: 1000...9999),
            todo: title,
            completed: false,
            userId: 1
        )
        
        // 2. Сохраняем в Core Data
        let savedTodo = coreDataManager?.save(from: newTaskData, description: description)

        if savedTodo == nil {
            print("Interactor: CoreDataManager.save вернул nil. Ошибка сохранения в Core Data.")
        } else {
            print("Interactor: CoreDataManager.save успешно вызван.")
        }
    }
}


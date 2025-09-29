//
//  CoreDataManager.swift
//  effectivemobile
//
//  Created by ellkaden on 23.09.2025.
//

import Foundation
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "YourDataModelName")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // CoreDataManager.swift
    
    // This method will take the API data and create a Core Data object.
    func save(from apiTodo: APITodo, description: String) -> Todo? {
        let context = persistentContainer.viewContext
        
        // Если сущность называется не Todo, замените имя здесь:
        let todoEntity = Todo(context: context)
        
        // ГАРАНТИЯ: ЗАПОЛНЕНИЕ ВСЕХ ОБЯЗАТЕЛЬНЫХ ПОЛЕЙ
        
        // 1. id (Int64)
        todoEntity.id = Int64(apiTodo.id)
        
        // 2. name (String)
        todoEntity.name = apiTodo.todo ?? "Новая задача"  // <-- Установите заглушку

        // 3. todoDescription (String)
        todoEntity.todoDescription = description       // ✅ ФИКС: Описание из параметра description
        
        // 4. isCompleted (Bool)
        todoEntity.isCompleted = apiTodo.completed
        
        // 5. creationDate (Date)
        todoEntity.creationDate = Date()               // ✅ ФИКС: Установка текущей даты
        
        do {
            try context.save()
            print("✅ CoreData: Сохранение прошло успешно.")
            return todoEntity
        } catch {
            let nserror = error as NSError
            // 🚨 Здесь будет видна причина отказа, если она все еще есть!
            print("❌ КРИТИЧЕСКАЯ ОШИБКА CORE DATA: \(nserror), \(nserror.userInfo)")
            return nil
        }
    }
    
    func fetchTodos(with predicate: NSPredicate? = nil) -> [Todo]? {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Todo> = Todo.fetchRequest()
        
        fetchRequest.predicate = predicate

        do {
            let todos = try context.fetch(fetchRequest)
            return todos
        } catch let error {
            print("Failed to fetch todos: \(error)")
            return nil
        }
    }
    
    // В CoreDataManager.swift

    // Добавьте этот метод:
    func deleteTodo(withID id: Int) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Todo> = Todo.fetchRequest()
        
        // Создаем предикат для поиска по ID
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let todoToDelete = results.first {
                context.delete(todoToDelete)
                saveContext() // Сохраняем изменения
            }
        } catch {
            print("Failed to delete todo with ID \(id): \(error.localizedDescription)")
        }
    }
    
    func updateTask(with id: Int, newTitle: String, newDescription: String) {
        let context = persistentContainer.viewContext
        
        // 1. ✅ ИСПРАВЛЕНИЕ: Используем Todo.fetchRequest()
        let fetchRequest: NSFetchRequest<Todo> = Todo.fetchRequest() // Было TaskEntity
        
        // 2. Ищем задачу с нужным ID
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let tasks = try context.fetch(fetchRequest)
            
            if let taskToUpdate = tasks.first {
                // 3. Обновляем поля сущности
                // ✅ ИСПРАВЛЕНИЕ: Убедитесь, что имена полей правильные
                taskToUpdate.name = newTitle // Используем 'name', как в save
                taskToUpdate.todoDescription = newDescription
                taskToUpdate.creationDate = Date()
                
                // 4. Сохраняем изменения
                try context.save()
                print("✅ Задача с ID \(id) успешно обновлена.")
            } else {
                print("⚠️ Задача с ID \(id) не найдена для обновления.")
            }
        } catch {
            print("❌ Ошибка при выполнении обновления Core Data: \(error)")
        }
    }}

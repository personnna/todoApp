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
    
    
    func save(from apiModel: APITodo) -> Bool {
        let context = persistentContainer.viewContext
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Todo", in: context) else {
            print("❌ Core Data: Не найдена сущность Todo")
            return false
        }
        let task = NSManagedObject(entity: entity, insertInto: context)
        
        task.setValue(Int32(apiModel.id), forKey: "id")
        task.setValue(apiModel.todo, forKey: "todo")
        task.setValue(apiModel.completed, forKey: "completed")
        task.setValue(Int32(apiModel.userId), forKey: "userId")
        
        task.setValue(apiModel.todo, forKey: "name")
        task.setValue(Date(), forKey: "creationDate")
        
        do {
            try context.save()
            print("✅ Core Data: Успешно сохранено.")
            return true
        } catch {
            print("❌ Core Data FAILED to save context: \(error.localizedDescription)")
            context.rollback()
            return false
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
    
    func deleteTodo(withID id: Int) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Todo> = Todo.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let todoToDelete = results.first {
                context.delete(todoToDelete)
                saveContext()
            }
        } catch {
            print("Failed to delete todo with ID \(id): \(error.localizedDescription)")
        }
    }
    
    func updateTask(with id: Int, newTitle: String, newDescription: String) {
        let context = persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<Todo> = Todo.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let tasks = try context.fetch(fetchRequest)
            
            if let taskToUpdate = tasks.first {
                taskToUpdate.name = newTitle
                taskToUpdate.todoDescription = newDescription
                taskToUpdate.creationDate = Date()
                
                try context.save()
                print("✅ Задача с ID \(id) успешно обновлена.")
            } else {
                print("⚠️ Задача с ID \(id) не найдена для обновления.")
            }
        } catch {
            print("❌ Ошибка при выполнении обновления Core Data: \(error)")
        }
    }}

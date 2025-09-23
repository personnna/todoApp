//
//  CoreDataManager.swift
//  effectivemobile
//
//  Created by ellkaden on 23.09.2025.
//

import Foundation
import CoreData

class CoreDataManager {
    // Shared instance, чтобы менеджер был доступен отовсюду
    static let shared = CoreDataManager()

    // Persistent container для работы с Core Data
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "YourDataModelName")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    // Контекст для сохранения данных
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

    // Методы для CRUD операций:
    // func fetchTasks() -> [TaskEntity]
    // func addTask(name: String, description: String, ...)
    // func updateTask(task: TaskEntity, isCompleted: Bool)
    // func deleteTask(task: TaskEntity)
}

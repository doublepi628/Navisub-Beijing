//
//  HistoryManager.swift
//  navisub
//
//  Created by Shaohan Yu on 2025/2/22.
//

import CoreData

class CoreDataStack : ObservableObject {
    private let persistentContainer: NSPersistentContainer
    
    var managedObjectContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    init(modelName: String) {
        persistentContainer = {
            guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "xcdatamodeld") else {
                fatalError("Failed to find the \(modelName).xcdatamodeld file in the bundle.")
            }
            guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
                fatalError("Failed to load the model from the .momd file.")
            }
            let container = NSPersistentContainer(name: modelName, managedObjectModel: model)
            container.loadPersistentStores{ _, error in
                if let error = error {
                    print(error)
                }
            }
            return container
        }()
    }
    
    func save() {
        guard managedObjectContext.hasChanges else {return}
        do {
            try managedObjectContext.save()
        } catch {
            print(error)
        }
    }
}

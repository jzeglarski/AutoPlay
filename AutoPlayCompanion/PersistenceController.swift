//
//  PersistenceController.swift
//  AutoPlay
//
//  Created by John Zeglarski on 3/6/21.
//

import Foundation
import CoreData
import MediaPlayer

struct PersistenceController {
    // A singleton for our entire app to use
    static let shared = PersistenceController()

    // Storage for Core Data
    let container: NSPersistentContainer

    // A test configuration for SwiftUI previews
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)

        let video = Video(context: controller.container.viewContext)
        let path = Bundle.main.path(forResource: filename, ofType: filetype)!
        let videoURL = URL(fileURLWithPath: path)
        video.data = try? Data(contentsOf: videoURL, options: .mappedIfSafe)

        return controller
    }()

    // An initializer to load Core Data, optionally able
    // to use an in-memory store.
    init(inMemory: Bool = false) {
        // If you didn't name your model Main you'll need
        // to change this name below.
        container = NSPersistentCloudKitContainer(name: "AutoPlay")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
    }
}

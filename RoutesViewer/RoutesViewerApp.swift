//
//  RoutesViewerApp.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 11.01.2024.
//

import SwiftUI
import UniformTypeIdentifiers

@main
struct RoutesViewerApp: App {
    @NSApplicationDelegateAdaptor private var appDelegate: MyAppDelegate
    @State var isImporterPresented = false

    var body: some Scene {
        WindowGroup {
            ContentView(documentStorage: appDelegate.documentStorage)
                .fileImporter(isPresented: $isImporterPresented, allowedContentTypes: appDelegate.documentStorage.supportedContentTypes, allowsMultipleSelection: true) { result in
                    switch result {
                    case .success(let files):
                        try? appDelegate.documentStorage.open(urls: files) // TODO: show error
                    case .failure:
                        print("failure") // TODO: show error
                    }
                }
        }
        .commands {
            CommandGroup(before: CommandGroupPlacement.newItem) {
                Button("Open") {
                    isImporterPresented = true
                }
                .keyboardShortcut(KeyEquivalent("o"), modifiers: .command)
            }
        }
    }
}

class MyAppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    var documentStorage = DocumentStorage()

    func application(_ application: NSApplication, open urls: [URL]) {
        try? documentStorage.open(urls: urls)
    }
}

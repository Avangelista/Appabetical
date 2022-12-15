//
//  AppabeticalApp.swift
//  Appabetical
//
//  Created by Rory Madden on 5/12/22.
//

import SwiftUI

@main
struct AppabeticalApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
            .onAppear { checkNewVersions() }
        }
    }
    
    func checkNewVersions() {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let url = URL(string: "https://api.github.com/repos/nutmeg-5000/Appabetical/releases/latest") {
            let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                guard let data = data else { return }
                
                if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    if (json["tag_name"] as? String)?.compare(version, options: .numeric) == .orderedDescending {
                        UIApplication.shared.confirmAlert(title: "Update Available", body: "A new version of Appabetical is available. It is recommended you update to avoid encountering bugs. Would you like to view the releases page?", onOK: {
                            UIApplication.shared.open(URL(string: "https://github.com/nutmeg-5000/Appabetical/releases/latest")!)
                        }, noCancel: false)
                    }
                }
            }
            task.resume()
        }
    }
}

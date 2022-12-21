//
//  Respring.swift
//  Appabetical
//
//  Created by exerhythm on 17.12.2022.
//

import Foundation

extension UIDevice {
    // Respring the device
    // Credit to haxi0
    // https://github.com/haxi0/InstaSpring/blob/main/InstaSpring/InstaSpring/ContentView.swift
    func respring() {
#if targetEnvironment(simulator)
#else
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
            guard let window = UIApplication.shared.windows.first else { return }
            while true {
                window.snapshotView(afterScreenUpdates: false)
            }
        }
#endif
    }
}

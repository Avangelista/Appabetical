//
//  Enums.swift
//  Appabetical
//
//  Created by Rory Madden on 13/12/22.
//

import Foundation

// Options for sorting

enum WidgetOptions {
    case top
}

enum ItemSize: Int {
    case normal = 1
    case small = 4
    case medium = 8
    case large = 16
    case unknown = 0
}

enum ItemType: Int {
    case app
    case folder
    case widget
    case unknown
}

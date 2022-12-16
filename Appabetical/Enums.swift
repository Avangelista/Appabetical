//
//  Enums.swift
//  Appabetical
//
//  Created by Rory Madden on 13/12/22.
//

import Foundation

// Options for sorting pages
enum PageOptions {
    case individually
    case acrossPages
}

// Options for sorting folders
enum FolderOptions {
    case noSort
    case alongside
    case separately
}

// Options for type of sort to use
enum SortOptions: Equatable {
    case alpha
    case colour
}

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

enum ItemType {
    case app
    case folder
    case widget
    case unknown
}

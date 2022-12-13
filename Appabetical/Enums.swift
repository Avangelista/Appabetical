//
//  Enums.swift
//  Appabetical
//
//  Created by Rory Madden on 13/12/22.
//

import Foundation

// Options for sorting pages
enum PageOptions: String, CaseIterable, Identifiable {
    case individually
    case acrossPages
    var id: String { self.rawValue }
}

// Options for sorting folders
enum FolderOptions: String, CaseIterable, Identifiable {
    case noSort
    case alongside
    case separately
    var id: String { self.rawValue }
}

// Options for type of sort to use
enum SortOptions: String, CaseIterable, Identifiable {
    case alpha
    case colour
    var id: String { self.rawValue }
}

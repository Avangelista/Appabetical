////
////  ComparatorUtils.swift
////  Appabetical
////
////  Created by Rory Madden on 13/12/22.
////
//
//import Foundation
//import SwiftUI
//
//func compareByTypeColor(object1: Any, object2: Any, folderOp: SortingManager.FolderSortingOption) -> Bool {
//    let (o1t, o1b, o1n) = getTypeBundleName(item: object1)
//    let (o2t, o2b, o2n) = getTypeBundleName(item: object2)
//
//    if o1t == .widget || o2t == .widget {
//        if o1t == .widget && o2t == .widget {
//            return getItemSize(item: object1).rawValue > getItemSize(item: object2).rawValue
//        } else if o1t == .widget {
//            return true
//        } else if o2t == .widget {
//            return false
//        }
//    } else if o1t == .folder || o2t == .folder {
//        if folderOp == FolderSortingOption.separately {
//            if o1t == .folder && o2t == .folder {
//                return o1n.lowercased() < o2n.lowercased()
//            } else if o1t == .folder {
//                return true
//            } else if o2t == .folder {
//                return false
//            }
//        } else if folderOp == FolderSortingOption.noSort {
//            if o1t == .folder && o2t == .folder {
//                return false
//            } else if o1t == .folder {
//                return true
//            } else if o2t == .folder {
//                return false
//            }
//        }
//    } else if o1t == .app && o2t == .app {
//        var hue1: CGFloat = 0
//        var saturation1: CGFloat = 0
//        var brightness1: CGFloat = 0
//        var alpha1: CGFloat = 0
//        SpringBoardAppUtils.shared.getColor(id: o1b).getHue(&hue1, saturation: &saturation1, brightness: &brightness1, alpha: &alpha1)
//
//        var hue2: CGFloat = 0
//        var saturation2: CGFloat = 0
//        var brightness2: CGFloat = 0
//        var alpha2: CGFloat = 0
//        SpringBoardAppUtils.shared.getColor(id: o2b).getHue(&hue2, saturation: &saturation2, brightness: &brightness2, alpha: &alpha2)
//
//        if hue1 < hue2 {
//            return true
//        } else if hue1 > hue2 {
//            return false
//        }
//
//        if saturation1 < saturation2 {
//            return true
//        } else if saturation1 > saturation2 {
//            return false
//        }
//
//        if brightness1 < brightness2 {
//            return true
//        } else if brightness1 > brightness2 {
//            return false
//        }
//    }
//    return true
//}
//
//func compareByType(object1: Any, object2: Any, folderOp: FolderSortingOption) -> Bool {
//    let (o1t, _, o1n) = getTypeBundleName(item: object1)
//    let (o2t, _, o2n) = getTypeBundleName(item: object2)
//
//    if o1t == .widget || o2t == .widget {
//        if o1t == .widget && o2t == .widget {
//            return getItemSize(item: object1).rawValue > getItemSize(item: object2).rawValue
//        } else if o1t == .widget {
//            return true
//        } else if o2t == .widget {
//            return false
//        }
//    } else if o1t == .folder || o2t == .folder {
//        if folderOp == FolderSortingOption.separately {
//            if o1t == .folder && o2t == .folder {
//                return o1n.lowercased() < o2n.lowercased()
//            } else if o1t == .folder {
//                return true
//            } else if o2t == .folder {
//                return false
//            }
//        } else if folderOp == FolderSortingOption.noSort {
//            if o1t == .folder && o2t == .folder {
//                return false
//            } else if o1t == .folder {
//                return true
//            } else if o2t == .folder {
//                return false
//            }
//        }
//    }
//    return o1n.lowercased() < o2n.lowercased()
//}

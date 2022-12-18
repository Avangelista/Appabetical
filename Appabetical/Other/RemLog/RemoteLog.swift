//
//  RemoteLog.swift
//  Evyrest
//
//  Created by exerhythm on 07.12.2022.
//

import Foundation


func remLog(_ objs: Any...) {
    for obj in objs {
        let args: [CVarArg] = [ String(describing: obj) ]
        withVaList(args) { RLogv("%@", $0) }
    }
}

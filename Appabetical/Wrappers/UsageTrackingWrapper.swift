//
//  UsageTrackingWrapper.swift
//  Appabetical
//
//  Created by sourcelocation on 22/12/2022.
//

import Foundation
import Dynamic

class UsageTrackingWrapper {
    
    static public var shared = UsageTrackingWrapper()
    
    struct AppUsage {
        var interval: Int
        var appName: String
        var usage: TimeInterval
    }
    
    public func getAppUsages(completion: @escaping ([AppUsage]?, Error?) -> ()) {
        remLog("obtaining usage reports")
        Dynamic.USUsageReporter().fetchReportsDuringInterval(
            DateInterval(start: Date().addingTimeInterval(-3600), end: Date()),
            partitionInterval: TimeInterval(3600),
            forceImmediateSync: true,
            completionHandler: { (localUsageReports,usageReportsByDeviceIdentifier, aggregateUsageReports, error) in
                guard error == nil else { completion(nil, error); return }
                remLog(" == received == ", localUsageReports, " == error == ", error)
            } as UsageReportCompletionBlock
        )
    }
    
    init() {
        Bundle(url: URL(fileURLWithPath: "/System/Library/PrivateFrameworks/UsageTracking.framework"))?.load()
    }
}

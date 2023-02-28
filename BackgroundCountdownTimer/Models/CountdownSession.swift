//
//  Item.swift
//  BackgroundCountdownTimer
//
//  Created by 仲純平 on 2023/02/28.
//

import Foundation
import CoreData

extension CountdownSession {
    enum Status: UInt {
        case running = 0
        case paused = 1
        case finished = 2
    }
}

extension CountdownSession {
    
    func isRunning() -> Bool {
        return self.status == Status.running.rawValue
    }
    
    func finished() -> Bool {
        return self.status == Status.finished.rawValue
    }
    
    func durationMillis() -> Int {
        return Int(self.durationSeconds * 1000)
    }
    
    
    func millisUntil(date: Date) -> Int {
        return Int(self.resumedAt!.distance(to: date) * 1000)
    }
    
    func currentProgressMillis() -> Int {
        if (isRunning()) {
            return Int(self.progressMillisAtResumed) + millisUntil(date: Date.now)
        } else {
            return Int(progressMillisAtResumed)
        }
    }
    
    func remainingMillis() -> Int {
        return durationMillis() - currentProgressMillis()
    }
    
    func progressPercent() -> Double {
        let progress =  Double(currentProgressMillis()) / Double(durationMillis())
        return min(progress, 1.0) * 100
    }
}

extension CountdownSession {
    static func insert(
        in context: NSManagedObjectContext,
        durationSeconds: Int
    ) -> CountdownSession {
        let session = self.init(context: context)
        session.status = Int16(Status.running.rawValue)
        session.durationSeconds = Int64(durationSeconds)
        session.progressMillisAtResumed = 0
        session.resumedAt = Date.now
        return session
    }
}

extension CountdownSession {
    
}

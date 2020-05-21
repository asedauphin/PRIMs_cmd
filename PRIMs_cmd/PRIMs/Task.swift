//
//  Task.swift
//  PRIMs
//
//  Created by Niels Taatgen on 4/28/15.
//  Copyright (c) 2015 Niels Taatgen. All rights reserved.
//

import Foundation

class Task {
    let name: String
    var loaded: Bool = false
//    var inputOutput: { (action: [Val]) -> Chunk?) }
    let filename: URL
    var goalChunk: Chunk? = nil
    var goalConstants: Chunk? = nil
    var scenario: PRScenario! = nil
    var reward: Double = 10.0
    var parameters: [(String,String)] = []
    var actions: [String:ActionInstance] = [:]
    /// Keeps track of the successes over trials, only for goals
    var goalHistory: [Bool?] = []
    init(name: String, path: URL) {
        self.name = name
        self.filename = path
    }
    
    /**
    Function that updates the reward History of the last goal in the goal buffer (if goal selection occurs)
    */
    func updateGoalHistory (model: Model, reward: Double) {
        guard model.dm.goalSelection && model.batchMode else {return}

        if reward <= 0 {
            self.goalHistory.append(false)
        }
        else {
            self.goalHistory.append(true)
        }
    }
    
    /*
     Function that compute the derivative of the Accuracy over trials
     */
    func accuracyDerivative(threshold: Int, distance: Int ) -> Double {
        let halfThreshold: Int = Int(threshold/2)
        let goalHistoryInt = goalHistoryIntegers()
        let length = self.goalHistory.count
        
        if length < threshold {
            return Double(goalHistoryInt.reduce(0, +)/length)
        }
        
        let meanLastTrials: Double = Double(goalHistoryInt[(length - halfThreshold)...].reduce(0, +)) / Double(halfThreshold)
        let meanFirstTrials: Double
        let result: Double
        
        if length < threshold + distance {
            meanFirstTrials = Double(goalHistoryInt[..<halfThreshold].reduce(0, +)) / Double(halfThreshold)
            result = Double( (meanLastTrials - meanFirstTrials) / Double(length) )
        }
        else {
            if goalHistoryInt[(length - distance - threshold + 1)...].count == goalHistoryInt[(length - distance - threshold + 1)...].reduce(0, +) {
                return -1.0
            }
            meanFirstTrials = Double(goalHistoryInt[(length - distance - threshold + 1)...(length - distance - halfThreshold)].reduce(0, +)) / Double(halfThreshold)
            result = Double( (meanLastTrials - meanFirstTrials) / Double(threshold+distance) )
        }
        
        if result > 0.01 {
            return result
        }
        else {return 0.0}
    }
    
    /*
     Function that convert the array goalHistory of type [Bool] to an array goalHistoryInt of type [Int]
     */
    func goalHistoryIntegers() -> [Int] {
        var goalHistoryInt = [Int]()
        for i in self.goalHistory {
            if i! {
                goalHistoryInt.append(1)
            }
            else {
                goalHistoryInt.append(0)}
        }
        return goalHistoryInt
    }

}

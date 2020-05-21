//
//  BatchRun.swift
//  PRIMs
//
//  Created by Niels Taatgen on 5/22/15.
//  Copyright (c) 2015 Niels Taatgen. All rights reserved.
//

import Foundation


class BatchRun {
    var batchScript: String
    let outputFileName: URL
    var model: Model
    unowned let mainModel: Model
    let directory: URL
    var traceFileName: URL
    let fileName: String
    var goalSelect: Bool // Indicates whether autonomous goal selection takes place (only possible in batch mode)
    var goalSelectionFunction: [String]
    
    init(script: String, mainModel: Model, outputFile: URL, directory: URL, fileName: String, goalSelect: Bool, goalSelectionFunction: [String]) {
        self.batchScript = script
        self.outputFileName = outputFile
        self.traceFileName = outputFile.deletingPathExtension().appendingPathExtension("tracedat")
        self.model = Model(batchMode: true, goalSelection: goalSelect)
        self.directory = directory
        self.mainModel = mainModel
        self.fileName = fileName
        self.goalSelect = goalSelect
        self.goalSelectionFunction = goalSelectionFunction
        
    }
    

    
    func runScript() {
        mainModel.clearTrace()
            
        var scanner = Scanner(string: self.batchScript)
        let whiteSpaceAndNL = CharacterSet.whitespacesAndNewlines
        _ = scanner.scanUpToCharactersFromSet(whiteSpaceAndNL)
        let numberOfRepeats = scanner.scanInt()
        if numberOfRepeats == nil {
            self.mainModel.addToTraceField("Illegal number of repeats")
            return
        }
        var newfile = true
        for i in 0..<numberOfRepeats! {
            self.mainModel.addToTraceField("Run #\(i + 1)")
            //DispatchQueue.main.async {}
            scanner = Scanner(string: self.batchScript)
            
            while let command = scanner.scanUpToCharactersFromSet(whiteSpaceAndNL as CharacterSet) {
                var stopByTime = false
                switch command {
                case "run-time":
                    stopByTime = true
                    fallthrough
                case "run":
                    self.model.batchParameters = []
                    let taskname = scanner.scanUpToCharactersFromSet(whiteSpaceAndNL as CharacterSet)
                    if taskname == nil {
                        self.mainModel.addToTraceField("Illegal task name in run")
                        return
                    }
                    let taskLabel = scanner.scanUpToCharactersFromSet(whiteSpaceAndNL as CharacterSet)
                    if taskLabel == nil {
                        self.mainModel.addToTraceField("Illegal task label in run")
                        return
                    }
                    let endCriterium = scanner.scanDouble()
                    if endCriterium == nil {
                        self.mainModel.addToTraceField("Illegal number of trials or end time in run")
                        return
                    }
                    
                    while !scanner.isAtEnd && (scanner.string as NSString).character(at: scanner.scanLocation) != 10 && (scanner.string as NSString).character(at: scanner.scanLocation) != 13 {
                        let batchParam = scanner.scanUpToCharactersFromSet(whiteSpaceAndNL as CharacterSet)
                        self.model.batchParameters.append(batchParam!)
                        self.mainModel.addToTraceField("Parameter: \(batchParam!)")
                    }
                
                    if stopByTime {
                        self.mainModel.addToTraceField("Running task \(taskname!) with label \(taskLabel!) for \(endCriterium!) seconds")
                    } else {
                        self.mainModel.addToTraceField("Running task \(taskname!) with label \(taskLabel!) for \(endCriterium!) trials")
                    }
                    var tasknumber = self.model.findTask(taskname!)
                    if tasknumber == nil {
                        let taskPath = self.directory.appendingPathComponent(taskname! + ".prims")
                        print("Trying to load \(taskPath)")
                        if !self.model.loadModelWithString(taskPath) {
                            self.mainModel.addToTraceField("Task \(taskname!) is not loaded nor can it be found")
                            return
                        }
                        tasknumber = self.model.findTask(taskname!)
                    }
                    if tasknumber == nil {
                        self.mainModel.addToTraceField("Task \(taskname!) cannot be found")
                        return
                    }
                    self.model.loadOrReloadTask(tasknumber!)
                    if self.model.scenario.script != nil {
                        self.model.scenario.script!.arg = taskLabel!
                    }
                    if self.model.scenario.initScript != nil {
                        self.model.scenario.initScript!.arg = taskLabel!
                    }
                    var j = 0
                    let startTime = self.model.time
                    while (!stopByTime && j < Int(endCriterium!)) || (stopByTime && (self.model.time - startTime) < endCriterium!) {
                        j += 1
//                    for j in 0..<numberOfTrials! {
//                        print("Trial #\(j)")
                        self.model.run()
                        var output: String = ""
                        for line in self.model.outputData {
                            output += "\(i) \(taskname!) \(taskLabel!) \(j) \(line.time) \(line.eventType) \(line.goalBaselevelActivation) \(line.reachGoal) \(line.retrievedOperators)"
                            
//                            \(line.eventParameter1) \(line.eventParameter2) \(line.eventParameter3)
                            
//                            for item in line.inputParameters {
//                                output += item + " "
//                            }
//                          output += "\(line.firings)
                            output += "\n"
                        }
                        // Print trace to file
                        /*
                         var traceOutput = ""
                        if self.model.batchTrace {
                            if self.model.batchTrace {
                                for (time, type, event) in self.model.batchTraceData {
                                    traceOutput += "\(i) \(taskname!) \(taskLabel!) \(j) \(time) \(type) \(event) \n"
                                }
                                self.model.batchTraceData = []
                            }
                        } */
                        if !newfile {
                            // Output File
                            if FileManager.default.fileExists(atPath: self.outputFileName.path) {
                                var err:NSError?
                                do {
                                    let fileHandle = try FileHandle(forWritingTo: self.outputFileName)
                                    fileHandle.seekToEndOfFile()
                                    let data = output.data(using: String.Encoding.utf8, allowLossyConversion: false)
                                    fileHandle.write(data!)
                                    fileHandle.closeFile()
                                } catch let error as NSError {
                                    err = error
                                    self.mainModel.addToTraceField("Can't open fileHandle \(err!)")
                                }
                            }
                            // Trace File
                            /*
                            if FileManager.default.fileExists(atPath: self.traceFileName.path) && self.model.batchTrace {
                                var err:NSError?
                                do {
                                    let fileHandle = try FileHandle(forWritingTo: self.traceFileName)
                                    fileHandle.seekToEndOfFile()
                                    let data = traceOutput.data(using: String.Encoding.utf8, allowLossyConversion: false)
                                    fileHandle.write(data!)
                                    fileHandle.closeFile()
                                } catch let error as NSError {
                                    err = error
                                    self.mainModel.addToTraceField("Can't open trace fileHandle \(err!)")
                                }
                            } */
                        } else {
                            newfile = false
                            var err:NSError?
                            // Output file
                            do {
                                try output.write(to: self.outputFileName, atomically: false, encoding: String.Encoding.utf8)
                            } catch let error as NSError {
                                err = error
                                self.mainModel.addToTraceField("Can't write datafile \(err!)")
                            }
                            // Trace file
                                /*
                                if self.model.batchTrace {
                                    do {
                                        try traceOutput.write(to: self.traceFileName, atomically: false, encoding: String.Encoding.utf8)
                                    } catch let error as NSError {
                                        err = error
                                        self.mainModel.addToTraceField("Can't write tracefile \(err!)")
                                    }
                                }
                                 */
                                }
                        // Write in the batch file the next task to run
                        // ,,!! Inifinite loop at the moment
                        if self.goalSelect && self.model.batchMode {
                            var totalTrials: Int = 0
                            var nextTask = self.model.tasks.randomElement()
                            
                            if self.goalSelectionFunction[0] == "accuracyDerivative" {
                                let nextBL = nextTask!.accuracyDerivative(threshold: Int(self.goalSelectionFunction[2])!, distance: Int(self.goalSelectionFunction[3])!)
                            
                            for task in self.model.tasks {
                                totalTrials += task.goalHistory.count
                                    let potentialBL = task.accuracyDerivative(threshold: Int(self.goalSelectionFunction[2])!, distance: Int(self.goalSelectionFunction[3])!)
    
                                    if  potentialBL > nextBL {
                                        nextTask = task
                                    }
                                }
                            }
                            
                            else {
                                for task in self.model.tasks {
                                    totalTrials += task.goalHistory.count
                                }
                            }
      
                            if totalTrials < Int(self.goalSelectionFunction[1])! {
                                let followingCommand = "\nrun \(nextTask!.name) \(nextTask!.name)_bottomUp 1"
                            //Write into the .bprims file
//                            guard let data = followingCommand.data(using: .utf8) else { return }
//                            let fileURL = URL(fileURLWithPath: self.fileName, relativeTo: self.directory).appendingPathExtension("bprims")
//                            var fileHandle: FileHandle?
//                            do {
//                                fileHandle = try FileHandle(forUpdating: fileURL)
//                            } catch { fileHandle = nil }
//                            if fileHandle != nil {
//                                fileHandle!.seekToEndOfFile()
//                                fileHandle!.write(data)
//                                fileHandle!.closeFile()
//                            }
                                var index = self.batchScript.index(of: "\n")?.encodedOffset
                                index = index! + 1
                                self.batchScript = self.batchScript.truncated(limit: self.batchScript.count - index!, position: .head, leader: "")
                                self.batchScript += followingCommand
                                scanner = Scanner(string: self.batchScript )
                            }
                    }
                            
                    }
                case "reset":
                    self.mainModel.addToTraceField("Resetting models")
                    var index:Int = self.batchScript.index(of: "\n")!.encodedOffset
                    index = index + 1 //length "\n"
                        self.batchScript = self.batchScript.truncated(limit: self.batchScript.count - index, position: .head, leader: "")

                    print("*** About to reset model ***")
                    self.model.dm = nil
                    self.model.procedural = nil
                    self.model.action = nil
                    self.model.operators = nil
                    self.model.action = nil
                    self.model.imaginal = nil
                    self.model.batchParameters = []
                    self.model = Model(batchMode: true, goalSelection: self.goalSelect)
                case "repeat":
                    _ = scanner.scanInt()
                    var index:Int = self.batchScript.index(of: "\n")!.encodedOffset
                    index = index + 1 //length "\n"
                    self.batchScript = self.batchScript.truncated(limit: self.batchScript.count - index, position: .head, leader: "")
                case "done": break
//                    print("*** Model has finished running ****")
                case "load-image":
                    let filename = scanner.scanUpToCharactersFromSet(whiteSpaceAndNL as CharacterSet)
                    if filename == nil {
                        self.mainModel.addToTraceField("Illegal task name in run")
                        return
                    }
                    let taskPath = self.directory.appendingPathComponent(filename! + ".brain").path
                    self.mainModel.addToTraceField("Loading image file \(taskPath)")
                    guard let m = (NSKeyedUnarchiver.unarchiveObject(withFile: taskPath) as? Model) else { return }
                    self.model = m
                    self.model.dm.reintegrateChunks()
                    self.model.batchMode = true
                case "save-image":
                    let filename = scanner.scanUpToCharactersFromSet(whiteSpaceAndNL as CharacterSet)
                    if filename == nil {
                        self.mainModel.addToTraceField("Illegal task name in run")
                        return
                    }
                    let taskPath = self.directory.appendingPathComponent(filename! + ".brain").path
                    self.mainModel.addToTraceField("Saving image to file \(taskPath)")
                    NSKeyedArchiver.archiveRootObject(self.model, toFile: taskPath)
                default: break
                    
                }
            }
            self.mainModel.addToTraceField("Done")
            }

        
    }

    
}

//
//  Simulation.swift
//  PRIMs_cmd
//
//  Created by DAUPHIN on 15/05/2020.
//  Copyright © 2020 prims. All rights reserved.
//

import Foundation
import Cocoa

enum OptionType: String {
  case control = "c" //random selection
  case accuracyDerivative = "a"
  case help = "h"
  case quit = "q"
  
  init(value: String) {
    switch value {
        case "c": self = .control
        case "a": self = .accuracyDerivative
        case "h": self = .help
        case "q": self = .quit

        default: self = .quit
    }
  }
}


class Simulation {
    let consoleIO = ConsoleIO()
    
    func getOption(_ option: String) -> (option: OptionType, value: String) {
      return (OptionType(value: option), option)
    }
    
    var model = Model(silent: false)
    var batchRunner: BatchRun? = nil

    
    func staticMode() {
        let argCount = CommandLine.argc
        let argument = CommandLine.arguments[1]
        let (option, value) = getOption(argument.substring(from: argument.index(argument.startIndex, offsetBy: 1)))
        switch option {
        case .control:
            //2
            if argCount != 5 {
                if argCount > 5 {
                    consoleIO.writeMessage("Too many arguments for option \(option.rawValue)", to: .error)
                } else {
                    consoleIO.writeMessage("Too few arguments for option \(option.rawValue)", to: .error)
                }
            } else { 
                let bprimsURL: URL = URL(fileURLWithPath: CommandLine.arguments[2], isDirectory: false)
                let tmp = try? String(contentsOf: bprimsURL, encoding: String.Encoding.utf8)
                if tmp == nil { return }
                var batchScript: String = tmp!
                
                let index = CommandLine.arguments[3]
                let batchName: String = bprimsURL.deletingPathExtension().lastPathComponent
                let outputFile: String = batchName + "_control_" + index
                
                let goalSelectionFunc = ["random", CommandLine.arguments[4]]
                let directoryURL: URL = bprimsURL.deletingLastPathComponent()
                let outputFileURL: URL = URL(fileURLWithPath: directoryURL.path + "/" + outputFile + ".dat")
                
                batchRunner = BatchRun(script: batchScript, mainModel: model, outputFile: outputFileURL, directory: directoryURL, fileName: outputFile, goalSelect: true, goalSelectionFunction: goalSelectionFunc)
                batchRunner!.runScript()
               
            }
        case .accuracyDerivative:
            //4
            if argCount != 7 {
                if argCount > 7 {
                    consoleIO.writeMessage("Too many arguments for option \(option.rawValue)", to: .error)
                } else {
                    consoleIO.writeMessage("Too few arguments for option \(option.rawValue)", to: .error)
                }
            } else {
                let bprimsURL: URL = URL(fileURLWithPath: CommandLine.arguments[2], isDirectory: false)
                let tmp = try? String(contentsOf: bprimsURL, encoding: String.Encoding.utf8)
                if tmp == nil { return }
                var batchScript: String = tmp!
                
                let index = CommandLine.arguments[3]
                let batchName: String = bprimsURL.deletingPathExtension().lastPathComponent
                let threshold = CommandLine.arguments[5]
                let distance = CommandLine.arguments[6]
                let outputFile: String = batchName + "_accuDeriv_thsh" + threshold + "_dist" + distance + "_" + index
        
                let goalSelectionFunc = ["accuracyDerivative", CommandLine.arguments[4], threshold, distance]
                let directoryURL: URL = bprimsURL.deletingLastPathComponent()
                let outputFileURL: URL = URL(fileURLWithPath: directoryURL.path + "/" + outputFile + ".dat")
                batchRunner = BatchRun(script: batchScript, mainModel: model, outputFile: outputFileURL, directory: directoryURL, fileName: outputFile, goalSelect: true, goalSelectionFunction: goalSelectionFunc)
                batchRunner!.runScript()
                
            }
            
        case .help:
            consoleIO.printUsage()
        case .quit:
            consoleIO.writeMessage("Unknown option \(value)")

        }

    }

//    func interactiveMode() {
//        consoleIO.writeMessage("Launch a PRIMs Simulation. Execute only batch files.")
//        consoleIO.printUsage()
//
//      var shouldQuit = false
//      while !shouldQuit {
//        consoleIO.writeMessage("Type 'c' to run a control experiment, 'a' to use the goal selection function based on accuracy derivative, 'h' show usage information and 'q' to quit.")
//        let (option, value) = getOption(consoleIO.getInput())
//
//        switch option {
//        case .control:
//          consoleIO.writeMessage("Number of iterations?")
//          let nbIterations = consoleIO.getInput()
//
////          if first.isAnagramOf(second) {
////            consoleIO.writeMessage("\(second) is an anagram of \(first)")
////          } else {
////            consoleIO.writeMessage("\(second) is not an anagram of \(first)")
////          }
//        case .accuracyDerivative:
//          consoleIO.writeMessage("Number of iterations?")
//          let nbIterations = consoleIO.getInput()
//          consoleIO.writeMessage("Threshold?")
//          let thresh = consoleIO.getInput()
//          consoleIO.writeMessage("Distance?")
//          let dist = consoleIO.getInput()
//
//          //consoleIO.writeMessage("\(s) is \(isPalindrome ? "" : "not ")a palindrome")
//        case .quit:
//          shouldQuit = true
//
//        default:
//          consoleIO.writeMessage("Unknown option \(value)", to: .error)
//        }
//      }
//    }


}

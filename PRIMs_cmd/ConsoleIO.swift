//
//  ConsoleIO.swift
//  PRIMs_cmd
//
//  Created by DAUPHIN on 14/05/2020.
//  Copyright © 2020 prims. All rights reserved.
// code from: https://www.raywenderlich.com/511-command-line-programs-on-macos-tutorial


import Foundation


//defines the output stream to use when writing messages
enum OutputType {
    //The standard output stream (or stdout) is normally attached to the display and should be used to display messages to the user.
    case error
    
    //The standard error stream (or stderr) is normally used to display status and error messages. This is normally attached to the display, but can be redirected to a file.
    case standard
}


class ConsoleIO {
    
    func writeMessage(_ message: String, to: OutputType = .standard) {
        //This method has two parameters; the first = message to print, the second = destination with default value to .standard
        switch to {
            case .standard:
                print("\u{001B}[;m\(message)")
            case .error:
                fputs("\u{001B}[0;31m\(message)\n", stderr)
        }
    }
    
    func printUsage() {
        //Every time you run a program, the path to the executable is implicitly passed as argument[0] and accessible through the global CommandLine enum.

        let executableName = (CommandLine.arguments[0] as NSString).lastPathComponent
            
        writeMessage("usage:")
        writeMessage("\(executableName) -c bprimsPath index nbOfIterations")
        writeMessage("or")
        writeMessage("\(executableName) -a bprimsPath index nbOfIterations threshold distance")
        writeMessage("or")
        writeMessage("\(executableName) -h to show usage information")
        writeMessage("Type \(executableName) without an option to enter interactive mode.")
    }
    
    func getInput() -> String {
      let keyboard = FileHandle.standardInput
      let inputData = keyboard.availableData
      let strData = String(data: inputData, encoding: String.Encoding.utf8)!
      return strData.trimmingCharacters(in: CharacterSet.newlines)
    }

}

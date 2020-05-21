//
//  main.swift
//  PRIMs_cmd
//
//  Created by DAUPHIN on 14/05/2020.
//  Copyright © 2020 prims. All rights reserved.
//
import Cocoa
import Foundation

let simulation = Simulation()

if CommandLine.argc < 2 {
  print("invalid syntax")
} else {
    simulation.staticMode()
}

//
//  main.swift
//  macApp
//
//  Created by user on 10/31/18.
//  Copyright © 2018 Alex. All rights reserved.
//

import PrimeNumbers_Metal

let gpuTest = PrimeNumbersGPU()
let cpuTest = PrimeNumbersCPU()

let gpuResults = gpuTest.computeTest(testName: "GPU Test", range: 0...4000)
let cpuResults = cpuTest.computeTest(testName: "CPU Test", range: 0...4000)

assert(cpuResults.elementsEqual(gpuResults), "Something wrong: gpu results != cpu results")

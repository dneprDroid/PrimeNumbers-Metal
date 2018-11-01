//
//  main.swift
//  macApp
//
//  Created by user on 10/31/18.
//  Copyright © 2018 Alex. All rights reserved.
//

import PrimeNumbers_Metal

let gpuTest = PrimeNumbersGPU()


let primeNumbers = gpuTest.compute(range: 0...40)

print("Prime Numbers:\n \(primeNumbers)")

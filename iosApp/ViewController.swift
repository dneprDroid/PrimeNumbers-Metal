//
//  ViewController.swift
//  iosApp
//
//  Created by user on 11/1/18.
//  Copyright © 2018 Alex. All rights reserved.
//

import UIKit
import PrimeNumbers_Metal

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        test()
    }
    
    private func test() {
        DispatchQueue.global().async {
            
            let deviceName = DeviceInfo.deviceName()
            print("Current Device Name: \(deviceName)")
            
            let gpuTest = PrimeNumbersTestGPU()
            let cpuTest = PrimeNumbersTestCPU()
            
            let (gpuPrimes, gpuTime) = gpuTest.computeTest(testName: "GPU Test",
                                                           range: 1...500_000, printPrimeNumbers: false)
            
            let (cpuPrimes, cpuTime) = cpuTest.computeTest(testName: "CPU Test",
                                                           range: 1...500_000, printPrimeNumbers: false)
            
            print("Checking....")
            
            assert(cpuPrimes.elementsEqual(gpuPrimes, by: self.checkArrays),
                    "Something went wrong: gpu results != cpu results:\n" +
                    "CPU (\(cpuPrimes.count) items): \(cpuPrimes)\n" +
                    "----------------------------------------\n" +
                    "GPU (\(gpuPrimes.count) items): \(gpuPrimes)")
            
            print("Tasks were completed successfully:")
            
            if gpuTime < cpuTime {
                print("GPU test is \(cpuTime/gpuTime) times faster than CPU test")
            } else {
                print("CPU test is \(gpuTime/cpuTime) times faster than GPU test")
            }
        }
    }
    
    private func checkArrays(_ v1:CInt, _ v2:CInt)->Bool {
        let equal = (v1 == v2)
        if !equal {
            print("Error: value from CPU results != value from GPU result: \(v1) != \(v2)")
        }
        return equal
    }
}


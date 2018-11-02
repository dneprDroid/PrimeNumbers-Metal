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
        let gpuMetalTest = PrimeNumbersMetal()
        let cpuTest = PrimeNumbersCPU()
        
        let gpuMetalResults = gpuMetalTest.computeTest(testName: "GPU Test (Metal)",
                                                  range: 1...40_000, printPrimeNumbers: false)
        
        let cpuResults = cpuTest.computeTest(testName: "CPU Test",
                                             range: 1...40_000, printPrimeNumbers: false)
        
        print("Checking....")
        assert(cpuResults.elementsEqual(gpuMetalResults, by: self.checkArrays),
                "Something went wrong: gpu results != cpu results:\n" +
                "CPU (\(cpuResults.count) items): \(cpuResults)\n" +
                "----------------------------------------\n" +
                "GPU (\(gpuMetalResults.count) items): \(gpuMetalResults)")
        
        print("Tasks were completed successfully.")
    }
    
    private func checkArrays(_ v1:CInt, _ v2:CInt)->Bool {
        let equal = (v1 == v2)
        if !equal {
            print("Error: value from CPU results != value from GPU result: \(v1) != \(v2)")
        }
        return equal
    }
}


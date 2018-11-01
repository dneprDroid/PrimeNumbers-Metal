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
            let gpuTest = PrimeNumbersGPU()
            let cpuTest = PrimeNumbersCPU()
            
            let gpuResults = gpuTest.computeTest(testName: "GPU Test",
                                                 range: 1...40000,
                                                 printPrimeNumbers: false)
            
            let cpuResults = cpuTest.computeTest(testName: "CPU Test",
                                                 range: 1...40000,
                                                 printPrimeNumbers: false)
            
            print("Checking....")
            assert(cpuResults.elementsEqual(gpuResults, by: self.checkArrays),
                   "Something went wrong: gpu results != cpu results:\n" +
                    "CPU: \(cpuResults)\n" +
                    "----------------------------------------\n" +
                    "GPU: \(gpuResults)")
            print("Tasks were completed successfully.")
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


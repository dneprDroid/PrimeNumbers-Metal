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
        
        
        
        let gpuTest = PrimeNumbersGPU()
        let cpuTest = PrimeNumbersCPU()
        
        let gpuResults = gpuTest.computeTest(testName: "GPU Test", range: 0...4000)
        let cpuResults = cpuTest.computeTest(testName: "CPU Test", range: 0...4000)
        
        assert(cpuResults.elementsEqual(gpuResults),
               "Something went wrong: gpu results != cpu results:\n" +
                "CPU: \(cpuResults)\n" +
                "----------------------------------------\n" +
                "GPU: \(gpuResults)")
    }
}


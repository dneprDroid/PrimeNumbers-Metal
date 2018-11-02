//
//  PrimeNumbersCPU.swift
//  PrimeNumbers-Metal
//
//  Created by user on 11/1/18.
//  Copyright © 2018 Alex. All rights reserved.
//

import Foundation


public final class PrimeNumbersTestCPU : PrimeNumbersTestProtocol {
    
    
    public init() {}
    
    public func compute(min: CInt, max: CInt)->[CInt] {
        var results = [CInt]()
        for number in min...max {
            if !isPrimeNumber(number) {
                continue
            }
            results.append(number)
        }
        return results
    }
    
    private func isPrimeNumber(_ number: CInt)->Bool {
        if number <= 1 {
            return false
        }
        if number <= 3 {
            return true
        }
        if number % 2 == 0 {
            return false
        }
        let maxIndex = CInt(sqrt(Double(number)) + 1)
        
        var i:CInt = 3
        while i <= maxIndex {
            if number % i == 0 {
                return false
            }
            i += 2
        }
        return true
    }

}

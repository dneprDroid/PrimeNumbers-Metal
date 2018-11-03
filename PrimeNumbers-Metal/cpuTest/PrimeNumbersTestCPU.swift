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
    
    public func compute(min: UInt32, max: UInt32)->[UInt32] {
        var results:[UInt32] = []
        for number in min...max {
            if !isPrimeNumber(number) {
                continue
            }
            results.append(number)
        }
        return results
    }
    
    private func isPrimeNumber(_ number: UInt32)->Bool {
        if number <= 1 {
            return false
        }
        if number <= 3 {
            return true
        }
        if number % 2 == 0 {
            return false
        }
        let maxIndex = UInt32(sqrt(Double(number)) + 1)
        
        var i:UInt32 = 3
        while i <= maxIndex {
            if number % i == 0 {
                return false
            }
            i += 2
        }
        return true
    }

}

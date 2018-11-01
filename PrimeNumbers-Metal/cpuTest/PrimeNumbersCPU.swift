//
//  PrimeNumbersCPU.swift
//  PrimeNumbers-Metal
//
//  Created by user on 11/1/18.
//  Copyright © 2018 Alex. All rights reserved.
//

import Foundation


public final class PrimeNumbersCPU : PrimeNumbersProtocol {
    
    
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
        for i in 2..<(number/2) {
            if number % i == 0 {
                return false
            }
        }
        return true
    }

}

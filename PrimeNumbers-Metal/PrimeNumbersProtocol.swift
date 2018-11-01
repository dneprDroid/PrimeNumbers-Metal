//
//  PrimeNumbersProtocol.swift
//  PrimeNumbers-Metal
//
//  Created by user on 10/31/18.
//  Copyright © 2018 Alex. All rights reserved.
//

import Foundation


public protocol PrimeNumbersProtocol {

    associatedtype Value : Numeric & Comparable
    
    func compute(min: Value, max: Value)->[Value]
    
}

public extension PrimeNumbersProtocol where Value : Strideable,
                                            Value.Stride : SignedInteger {
    
    public func compute(range: CountableClosedRange<Value>)->[Value] {
        return self.compute(min: range.lowerBound, max: range.upperBound)
    }
    
    @discardableResult
    public func computeTest(testName: String,
                            range: CountableClosedRange<Value>)->[Value] {
        let currentTime = Date()
        let result = self.compute(range: range)
        let taskTime = -currentTime.timeIntervalSinceNow
        print("'\(testName)': \(taskTime) sec")
        return result
    }
}

public extension PrimeNumbersProtocol {
    
}

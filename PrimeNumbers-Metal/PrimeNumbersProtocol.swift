//
//  PrimeNumbersProtocol.swift
//  PrimeNumbers-Metal
//
//  Created by user on 10/31/18.
//  Copyright © 2018 Alex. All rights reserved.
//

import Foundation


public protocol PrimeNumbersProtocol {

    associatedtype ValueType : Numeric & Comparable
    
    func compute(min: ValueType, max: ValueType)->[ValueType]
    
}

public extension PrimeNumbersProtocol {
    
    @discardableResult
    public func computeTest(testName: String,
                            min: ValueType, max: ValueType,
                            printPrimeNumbers: Bool = false)->[ValueType] {
        let currentTime = Date()
        let primeNumbers = self.compute(min: min, max: max)
        let taskTime:TimeInterval = -currentTime.timeIntervalSinceNow
        
        print("'\(testName)': \(taskTime) sec")
        if printPrimeNumbers {
            print("Prime Numbers for '\(testName)':\n \(primeNumbers)")
        }
        return primeNumbers
    }
}

//MARK: CountableClosedRange
public extension PrimeNumbersProtocol where ValueType : Strideable,
                                            ValueType.Stride : SignedInteger {
    
    public func compute(range: CountableClosedRange<ValueType>)->[ValueType] {
        return self.compute(min: range.lowerBound, max: range.upperBound)
    }
    
    @discardableResult
    public func computeTest(testName: String,
                            range: CountableClosedRange<ValueType>,
                            printPrimeNumbers: Bool = false)->[ValueType] {
        
        return self.computeTest(testName: testName,
                                min: range.lowerBound, max: range.upperBound,
                                printPrimeNumbers: printPrimeNumbers)
    }
    
}

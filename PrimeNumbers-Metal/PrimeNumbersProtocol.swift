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
}

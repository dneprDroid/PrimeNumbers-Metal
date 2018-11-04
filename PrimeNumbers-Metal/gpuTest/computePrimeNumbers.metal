//
//  compute.metal
//  PrimeNumbers-Metal
//
//  Created by user on 10/31/18.
//  Copyright © 2018 Alex. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


typedef int IntType;
typedef uint UIntType;
typedef float FloatType;

// Check sizes of types :
static_assert(sizeof(IntType) == sizeof(UIntType) && sizeof(IntType) == sizeof(FloatType),
              "Error: sizeof(IntType), sizeof(UIntType), sizeof(FloatType) aren't equal.");

inline bool isPrimeNumber(const UIntType num) {
    if (num <= 1)
        return false;
    if (num <= 3)
        return true;
    if (num % 2 == 0)
        return false;
    
    for (UIntType i = 3;  i <= sqrt((FloatType)num);  i+=2) {
        if (num % i == 0)
            return false;
    }
    return true;
}

kernel void forEachNumbers(const device UIntType& minVal [[ buffer(0) ]],
                           const device UIntType& maxVal [[ buffer(1) ]],
                        
                           device UIntType* results [[ buffer(2) ]], // Results buffer
                        
                           uint3 gid [[thread_position_in_grid]])    // Thread Index
{
    // assert(minVal % 2 != 0 && "minVal % 2 == 0, set minVal param as minVal+1");
    const UIntType inputIndex = gid.x;
    const UIntType number = minVal + (inputIndex << 1); // Calculate every odd number
    
    if (number > maxVal)
        return;
    
    if (number == 1) {
        results[inputIndex] = 2;
        return;
    }
    
    if (isPrimeNumber(number))
        results[inputIndex] = number;
}

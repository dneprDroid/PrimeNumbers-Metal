//
//  compute.metal
//  PrimeNumbers-Metal
//
//  Created by user on 10/31/18.
//  Copyright © 2018 Alex. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


typedef int Integer;
typedef uint UInteger;

inline bool isPrimeNumber(const UInteger num) {
    if (num <= 1)
        return false;
    if (num <= 3)
        return true;
    if (num % 2 == 0)
        return false;
    
    for (UInteger i = 2; i < num/2; i++) {
        if (num % i == 0)
            return false;
    }
    return true;
}

kernel void mapParallel(const device UInteger& minVal [[ buffer(0) ]],
                        const device UInteger& maxVal [[ buffer(1) ]],
                        device Integer* results [[ buffer(2) ]],
                        
                        uint3 gid [[thread_position_in_grid]]) {
    
    const UInteger inputIndex = gid.x;
    const UInteger number = minVal + inputIndex;
    if (number > maxVal)
        return;
    if (isPrimeNumber(number))
        results[inputIndex] = number;
}

//
//  compute.metal
//  PrimeNumbers-Metal
//
//  Created by user on 10/31/18.
//  Copyright © 2018 Alex. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


typedef int DataType;

bool isPrimeNumber(const uint num) {
    for (uint i = 2; i < num/2; i++) {
        if (num % i == 0)
            return false;
    }
    return true;
}

kernel void mapParallel(const device uint& minVal [[ buffer(0) ]],
                        const device uint& maxVal [[ buffer(1) ]],
                        
                        device DataType* results [[ buffer(2) ]],
                        const device uint& resultCount [[ buffer(3) ]],
                        
                        uint3 gid [[thread_position_in_grid]]) {
    
    const uint inputIndex = gid.x;
    const uint number = minVal + inputIndex;
    if (isPrimeNumber(number))
        results[inputIndex] = number;
}

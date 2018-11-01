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

kernel void compute(const device uint& minVal [[ buffer(0) ]],
                    const device uint& maxVal [[ buffer(1) ]],
                    device DataType* results [[ buffer(2) ]],
                    const device uint& resultCount [[ buffer(3) ]],
                   
                    ushort3 gid [[thread_position_in_grid]]) {
    
    int resultIndex = gid.x;
    results[0] = max(resultIndex, results[0]);
}

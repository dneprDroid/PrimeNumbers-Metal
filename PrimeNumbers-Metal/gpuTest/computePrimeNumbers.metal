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

constant uint textureSideSize [[function_constant(0)]];

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
                        
                           texture2d<UIntType, access::write> results [[texture(2)]],
                        
                           uint3 gid [[thread_position_in_grid]]) // Thread Index
{

    const uint x = gid.x;
    const uint y = gid.y;
    
    if (x >= textureSideSize || y >= textureSideSize) {
        return;
    }
    const UIntType inputIndex = x + y * textureSideSize;
    const UIntType number = minVal + (inputIndex << 1);
    
    if (number > maxVal)
        return;
    
    if (number == 1) {
        results.write(2, gid.xy, gid.z);
        return;
    }
    
    if (isPrimeNumber(number))
        results.write(number, gid.xy, gid.z);
}

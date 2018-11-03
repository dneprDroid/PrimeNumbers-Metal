//
//  PrimeNumbersGPU.swift
//  PrimeNumbers-Metal
//
//  Created by user on 10/31/18.
//  Copyright © 2018 Alex. All rights reserved.
//

import Metal


public final class PrimeNumbersTestGPU : PrimeNumbersTestProtocol {
    
    struct Constants {
        static let InvalidPrimeNumber:UInt32 = 0
    }
    
    private enum ParamsIndex : Int {
        case min = 0, max, resultsBuffer
    }
    
    public init() {}
    
    public func compute(min: UInt32, max: UInt32)->[UInt32] {
        return computePrimeNumbers(min: min % 2 == 0 ? min+1 : min,
                                   max: max)
    }
    
    private func computePrimeNumbers(min: UInt32, max: UInt32)->[UInt32] {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("This device doesn't support Metal")
        }
        let lib = try! device.makeDefaultLibrary(bundle: Bundle(for: type(of: self)))
        let compute = lib.makeFunction(name: "forEachNumbers")!
        let pipeline = try! device.makeComputePipelineState(function: compute)
        
        
        
        let queue = device.makeCommandQueue()!
        let cmds = queue.makeCommandBuffer()!
        let encoder = cmds.makeComputeCommandEncoder()!
        encoder.setComputePipelineState(pipeline)

        // Params:
        let resultsCount = primeNumbersCount(min: min, max: max)
        // Create array [0, 0, ..., 0]
        let resultsBuffer = device.makeBuffer(length: MemoryLayout<UInt32>.stride * resultsCount,
                                              options: [])!

        var minParam = min
        var maxParam = max

        let threadCount = resultsCount
        
        print("--------------------")
        print("Expected Thread Count : \(threadCount)")
        print("Expected results count : \(resultsCount)")
        print("--------------------")
        
        // Set params to kernel function
        encoder.setBytes(&minParam,
                         length: MemoryLayout.size(ofValue: minParam),
                         index: ParamsIndex.min.rawValue)
        encoder.setBytes(&maxParam,
                         length: MemoryLayout.size(ofValue: maxParam),
                         index: ParamsIndex.max.rawValue)
        encoder.setBuffer(resultsBuffer,
                          offset: 0,
                          index: ParamsIndex.resultsBuffer.rawValue)
        
        // Configure thread count according to count of numbers range
        encoder.configure(expectedThreadCount: threadCount,
                          pipeline: pipeline)
        encoder.endEncoding()
        
        cmds.commit()
        cmds.waitUntilCompleted()
        
        // Read output values
        let bufferContent:UnsafeMutablePointer<UInt32> = resultsBuffer.contents()
                                                                      .bindMemory(to: UInt32.self,
                                                                                  capacity: resultsCount)
        var resultArray:[UInt32] = []
        var i = 0
        while i <= resultsCount {
            let n = bufferContent[i]
            if n != Constants.InvalidPrimeNumber {
                resultArray.append(n)
            }
            i += 1
        }
        return resultArray
    }
    
    private func primeNumbersCount(min:UInt32, max:UInt32)->Int {
        return Int((max-min)/2 + 1)
    }
}


extension MTLComputeCommandEncoder {
    
    func configure(expectedThreadCount: Int, pipeline: MTLComputePipelineState) {
        let maxThreadCount = pipeline.threadExecutionWidth
        
        let threadgroupsCount:Int
        let threadsCountPerGroup:Int

        if expectedThreadCount < maxThreadCount {
            threadgroupsCount = 1
            threadsCountPerGroup = expectedThreadCount
        } else {
            threadgroupsCount = expectedThreadCount/maxThreadCount + 1
            threadsCountPerGroup = maxThreadCount
        }
        let threadgroupsPerGrid = MTLSize(width: threadgroupsCount,
                                          height: 1,
                                          depth: 1)

        let threadsPerThreadgroup = MTLSize(width: threadsCountPerGroup,
                                            height: 1, depth: 1)
        
//        print("----------------------------------------------------")
//        print("maxTotalThreadsPerThreadgroup = \(pipeline.maxTotalThreadsPerThreadgroup)")
//        print("threadExecutionWidth = \(pipeline.threadExecutionWidth)")
//        print("----------------------------------------------------")
        
        dispatchThreadgroups(threadgroupsPerGrid,
                             threadsPerThreadgroup: threadsPerThreadgroup)
    }
}

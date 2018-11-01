//
//  PrimeNumbersGPU.swift
//  PrimeNumbers-Metal
//
//  Created by user on 10/31/18.
//  Copyright © 2018 Alex. All rights reserved.
//

import Metal


public final class PrimeNumbersGPU : PrimeNumbersProtocol {
    
    struct Constants {
        static let InvalidPrimeNumber:CInt = -1
    }
    
    private enum Params : Int {
        case min = 0, max, resultsBuffer
    }
    
    public init() {}
    
    public func compute(min: CInt, max: CInt)->[CInt] {
        assert(min < max, "Error: min >= max, where min=\(min), max=\(max)")
        
        print("Current Range: min = \(min), max = \(max)")
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("This device doesn't support Metal")
        }
        let lib = device.newDefaultLibrary()!
        let compute = lib.makeFunction(name: "mapParallel")!
        let pipeline = try! device.makeComputePipelineState(function: compute)
        
        
        
        let queue = device.makeCommandQueue()
        let cmds = queue.makeCommandBuffer()
        let encoder = cmds.makeComputeCommandEncoder()
        encoder.setComputePipelineState(pipeline)

        // Params:
        let resultsCount = primeNumbersCount(min: min, max: max)
        var results = [CInt](repeating: Constants.InvalidPrimeNumber, count: resultsCount)
        let resultsBuffer = device.makeBuffer(bytes: &results,
                                              length: MemoryLayout<CInt>.stride * resultsCount,
                                              options: [])

        var minParam = CUnsignedInt(min)
        var maxParam = CUnsignedInt(max)

        let inputCount = CUnsignedInt(max-min+1)
        let threadCount = Int(inputCount)
        
        print("--------------------")
        print("Thread Count : \(threadCount)")
        print("Expected results count : \(resultsCount)")
        print("--------------------")
        
        encoder.setBytes(&minParam,
                         length: MemoryLayout.size(ofValue: minParam),
                         at: Params.min.rawValue)
        encoder.setBytes(&maxParam,
                         length: MemoryLayout.size(ofValue: maxParam),
                         at: Params.max.rawValue)        
        encoder.setBuffer(resultsBuffer, offset: 0, at: Params.resultsBuffer.rawValue)
        
        encoder.configure(expectedThreadCount: threadCount,
                          pipeline: pipeline)
        encoder.endEncoding()
        
        cmds.commit()
        cmds.waitUntilCompleted()
        let resultsOut = resultsBuffer.contents().bindMemory(to: CInt.self,
                                                             capacity: resultsCount)
        return Array(UnsafeBufferPointer(start: resultsOut, count: resultsCount))
              .filter { $0 != Constants.InvalidPrimeNumber}
    }
    
    
    private func primeNumbersCount(number: CInt)->Int {
        return Int(number)
        
        //        if number == 0 {
        //            return 0
        //        }
        //        let x = Double(number)
        //        // https://en.wikipedia.org/wiki/Prime-counting_function
        //        let result = x/log10(x - 1)
        //        return Int(result * 1.5)
    }
    
    private func primeNumbersCount(min:CInt, max:CInt)->Int {
        return abs(primeNumbersCount(number: max) - primeNumbersCount(number: min)) + 1
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
        
        print("----------------------------------------------------")
        print("maxTotalThreadsPerThreadgroup = \(pipeline.maxTotalThreadsPerThreadgroup)")
        print("threadExecutionWidth = \(pipeline.threadExecutionWidth)")
        print("----------------------------------------------------")
        
        dispatchThreadgroups(threadgroupsPerGrid,
                             threadsPerThreadgroup: threadsPerThreadgroup)


    }
}

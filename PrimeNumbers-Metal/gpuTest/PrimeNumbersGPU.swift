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
    private let thisBundle = Bundle(for: PrimeNumbersGPU.self)
    
    private enum ParamsIndex : Int {
        case resultsBuffer = 0
    }
    
//    #define minVal 1
//    #define maxVal 2
    

    public init() {}
    
    public func compute(min: CInt, max: CInt)->[CInt] {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("This device doesn't support Metal")
        }
        do {
            let libPath = thisBundle.path(forResource: "mapParallel.metal", ofType: "txt")!
            let libSource = try String(contentsOfFile: libPath, encoding: String.Encoding.utf8)
            
            let libOptions = MTLCompileOptions()
            libOptions.preprocessorMacros = ["minVal" : NSNumber(value: min),
                                             "maxVal" : NSNumber(value: max)] as [String : NSObject]
            libOptions.fastMathEnabled = true
            
            let lib = try device.makeLibrary(source: libSource, options: libOptions)
            let compute = lib.makeFunction(name: "mapParallel")!
            let pipeline = try device.makeComputePipelineState(function: compute)
            
            
            
            let queue = device.makeCommandQueue()!
            let cmds = queue.makeCommandBuffer()!
            let encoder = cmds.makeComputeCommandEncoder()!
            encoder.setComputePipelineState(pipeline)

            // Params:
            let resultsCount = primeNumbersCount(min: min, max: max)
            var results = [CInt](repeating: Constants.InvalidPrimeNumber, count: resultsCount)
            let resultsBuffer = device.makeBuffer(bytes: &results,
                                                  length: MemoryLayout<CInt>.stride * resultsCount,
                                                  options: [])!

            let inputCount = CUnsignedInt(max-min+1)
            let threadCount = Int(inputCount)
            
            print("--------------------")
            print("Expected Thread Count : \(threadCount)")
            print("Expected results count : \(resultsCount)")
            print("--------------------")
            encoder.setBuffer(resultsBuffer,
                              offset: 0,
                              index: ParamsIndex.resultsBuffer.rawValue)
            
            encoder.configure(expectedThreadCount: threadCount,
                              pipeline: pipeline)
            encoder.endEncoding()
            
            cmds.commit()
            cmds.waitUntilCompleted()
            let resultsOut = resultsBuffer.contents().bindMemory(to: CInt.self,
                                                                 capacity: resultsCount)
            return Array(UnsafeBufferPointer(start: resultsOut, count: resultsCount))
                  .filter { $0 != Constants.InvalidPrimeNumber}
        } catch {
            fatalError(error.localizedDescription)
        }
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
        
//        print("----------------------------------------------------")
//        print("maxTotalThreadsPerThreadgroup = \(pipeline.maxTotalThreadsPerThreadgroup)")
//        print("threadExecutionWidth = \(pipeline.threadExecutionWidth)")
//        print("----------------------------------------------------")
        
        dispatchThreadgroups(threadgroupsPerGrid,
                             threadsPerThreadgroup: threadsPerThreadgroup)


    }
}

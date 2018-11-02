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
        static let InvalidPrimeNumber:CInt = 0
    }
    
    private enum ParamsIndex : Int {
        case min = 0, max, resultsBuffer
    }
    
    public init() {}
    
    public func compute(min: CInt, max: CInt)->[CInt] {
        return computePrimeNumbers(min: min % 2 == 0 ? min+1 : min,
                                   max: max)
    }
    
    private func allocateTexture(device: MTLDevice, itemsCount: Int)->MTLTexture {
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .r32Uint,
                                                                         width: itemsCount,
                                                                         height: 1,
                                                                         mipmapped: false)
        textureDescriptor.usage = .shaderWrite
        return device.makeTexture(descriptor: textureDescriptor)!
    }
    
        
    private func computePrimeNumbers(min: CInt, max: CInt)->[CInt] {
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
        // Create Texture [0, 0, ..., 0]
        let resultTexture = allocateTexture(device: device, itemsCount: resultsCount)

        var minParam = CUnsignedInt(min)
        var maxParam = CUnsignedInt(max)

        let threadCount = Int(resultsCount)
        
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
        encoder.setTexture(resultTexture,
                           index: ParamsIndex.resultsBuffer.rawValue)
        
        // Configure thread count according to count of numbers range
        encoder.configure(expectedThreadCount: threadCount,
                          pipeline: pipeline)
        encoder.endEncoding()
        
        cmds.commit()
        cmds.waitUntilCompleted()
        
        // Read output values
        let resultsOut = resultTexture.toArray(width: resultsCount,
                                               height: 1,
                                               featureChannels: 1,
                                               initial: CInt(0))
        return resultsOut
              .filter { $0 != Constants.InvalidPrimeNumber }
    }
    
    
    private func primeNumbersCount(number: CInt)->Int {
        return Int(number/2)
        
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



extension MTLTexture {
    
    func toArray<T>(width: Int, height: Int, featureChannels: Int, initial: T) -> [T] {
        assert(featureChannels != 3 && featureChannels <= 4, "channels must be 1, 2, or 4")
        
        var bytes = [T](repeating: initial, count: width * height * featureChannels)
        let region = MTLRegionMake2D(0, 0, width, height)
        getBytes(&bytes, bytesPerRow: width * featureChannels * MemoryLayout<T>.stride,
                 from: region, mipmapLevel: 0)
        return bytes
    }
}

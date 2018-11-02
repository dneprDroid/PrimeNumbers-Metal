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
    
    private func allocateTexture(device: MTLDevice, itemsCount: Int, sizeSize: Int)->MTLTexture {
//        let maxSideSize = 16384
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .r32Uint,
                                                                         width:  sizeSize,
                                                                         height: sizeSize,
                                                                         mipmapped: false)
        textureDescriptor.usage = .shaderWrite
        return device.makeTexture(descriptor: textureDescriptor)!
    }
    
        
    private func computePrimeNumbers(min: CInt, max: CInt)->[CInt] {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("This device doesn't support Metal")
        }
        
        let resultsCount = primeNumbersCount(min: min, max: max)
        
        let sizeSize = Int(sqrt(Double(resultsCount)))+1
        var sizeSizeU = CUnsignedInt(sizeSize)
        
        let lib = try! device.makeDefaultLibrary(bundle: Bundle(for: type(of: self)))
        
        let constants = MTLFunctionConstantValues()
        constants.setConstantValue(&sizeSizeU, type: .uint, index: 0);
        
        let compute = try! lib.makeFunction(name: "forEachNumbers", constantValues: constants)
        let pipeline = try! device.makeComputePipelineState(function: compute)
        
        
        
        let queue = device.makeCommandQueue()!
        let cmds = queue.makeCommandBuffer()!
        let encoder = cmds.makeComputeCommandEncoder()!

        // Params:
        // Create Texture [0, 0, ..., 0]

        let resultTexture = allocateTexture(device: device, itemsCount: resultsCount, sizeSize: sizeSize)

        var minParam = CUnsignedInt(min)
        var maxParam = CUnsignedInt(max)
        
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
        encoder.dispatch(pipeline: pipeline, texture: resultTexture)
        encoder.endEncoding()
        
        cmds.commit()
        cmds.waitUntilCompleted()
        
        // Read output values
        let resultsOut = resultTexture.toArray(width: sizeSize,
                                               height: sizeSize,
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
        
        setComputePipelineState(pipeline)
        dispatchThreadgroups(threadgroupsPerGrid,
                             threadsPerThreadgroup: threadsPerThreadgroup)
    }
}

extension MTLComputeCommandEncoder {
    func dispatch(pipeline: MTLComputePipelineState, texture: MTLTexture) {
        let w = pipeline.threadExecutionWidth
        let h = pipeline.maxTotalThreadsPerThreadgroup / w
        let threadGroupSize = MTLSizeMake(w, h, 1)
        
        let threadGroups = MTLSizeMake(
            (texture.width       + threadGroupSize.width  - 1) / threadGroupSize.width,
            (texture.height      + threadGroupSize.height - 1) / threadGroupSize.height,
            (texture.arrayLength + threadGroupSize.depth  - 1) / threadGroupSize.depth)
        
        setComputePipelineState(pipeline)
        dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupSize)
    }
}

extension MTLComputeCommandEncoder {
    
    func set<T>(number: T, index: Int) {
        var n = number
        setBytes(&n,
                 length: MemoryLayout.size(ofValue: number),
                 index: index)
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

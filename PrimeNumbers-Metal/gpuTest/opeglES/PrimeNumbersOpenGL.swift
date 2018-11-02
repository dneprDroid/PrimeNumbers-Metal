//
//  PrimeNumbersOpenGL.swift
//  PrimeNumbers-Metal
//
//  Created by user on 11/2/18.
//  Copyright © 2018 Alex. All rights reserved.
//

import Foundation


public class PrimeNumbersOpenGL : PrimeNumbersProtocol {
    
    private var context: EAGLContext? = nil
    
    public init() {
        self.context = EAGLContext(api: .openGLES2)
        
    }
    
    public func compute(min: CInt, max: CInt) -> [CInt] {
        if self.context == nil {
            fatalError("Failed to create ES context")
        }
        EAGLContext.setCurrent(self.context)
        
        return []
    }
    
    
    deinit {
        if EAGLContext.current() === self.context {
            EAGLContext.setCurrent(nil)
        }
    }

}

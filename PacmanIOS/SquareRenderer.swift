//
//  SquareRenderer.swift
//  PacmanIOS
//
//  Created by Jack Armstrong on 12/29/18.
//  Copyright © 2018 Jack Armstrong. All rights reserved.
//

import Foundation
import Metal

class SquareRenderer {
    static var vertexBuffer: MTLBuffer!
    static var pipelineState: MTLRenderPipelineState!
    static var width: Float!
    static var height: Float!
    static func initSquare(device: MTLDevice!){
        let vertexData: [Float] = [
            0.0, 0.0, 0.0,
            1.0, 0.0, 0.0,
            1.0, 1.0, 0.0,
            
            0.0, 0.0, 0.0,
            0.0, 1.0, 0.0,
            1.0, 1.0, 0.0
        ]
        let dataSize=vertexData.count*MemoryLayout<Float>.size
        
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])
        
        let defaultLibrary = device.makeDefaultLibrary()
        let vertexShader = defaultLibrary?.makeFunction(name: "vertexShader")
        let fragmentShader = defaultLibrary?.makeFunction(name: "fragmentShader")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexShader
        pipelineStateDescriptor.fragmentFunction = fragmentShader
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
    }
    static func render(x: Float, y: Float, w: Float, h: Float, red: Float, green: Float, blue: Float, encoder: MTLRenderCommandEncoder){
        encoder.setRenderPipelineState(pipelineState)
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        let pos: [Float] = [x, y]
        let size: [Float] = [w, h]
        let wsize: [Float] = [width, height]
        let col: [Float] = [red, green, blue]
        let gsize: [Int] = [gridW, gridH]
        encoder.setVertexBytes(pos, length: 2*MemoryLayout<Float>.stride, index: 1)
        encoder.setVertexBytes(size, length: 2*MemoryLayout<Float>.stride, index: 2)
        encoder.setVertexBytes(wsize, length: 2*MemoryLayout<Float>.stride, index: 3)
        encoder.setVertexBytes(col, length: 4*MemoryLayout<Float>.stride, index: 4)
        encoder.setVertexBytes(gsize, length: 2*MemoryLayout<Int>.stride, index: 5)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
    }
}
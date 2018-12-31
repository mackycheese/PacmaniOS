//
//  TextRenderer.swift
//  PacmanIOS
//
//  Created by Jack Armstrong on 12/30/18.
//  Copyright © 2018 Jack Armstrong. All rights reserved.
//

import Foundation
import Metal

class MetalText {
    var atlas: MetalTexture!
    var str: String!
    var posBuffer: MTLBuffer!
    var uvBuffer: MTLBuffer!
    var samplerState: MTLSamplerState!
    var pipelineState: MTLRenderPipelineState!
    
    init(device: MTLDevice) {
        atlas = MetalTexture(device: device, name: "assets/font", ext: "png")
        let lib = device.makeDefaultLibrary()
        
        let descr = MTLRenderPipelineDescriptor()
        descr.vertexFunction = lib?.makeFunction(name: "textVertex")
        descr.fragmentFunction = lib?.makeFunction(name: "textFragment")
        descr.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        pipelineState = try! device.makeRenderPipelineState(descriptor: descr)
        
        let sampler = MTLSamplerDescriptor()
        sampler.minFilter = .nearest
        sampler.magFilter = .nearest
        sampler.mipFilter = .notMipmapped
        sampler.maxAnisotropy = 1
        sampler.sAddressMode = .clampToEdge
        sampler.tAddressMode = .clampToEdge
        sampler.rAddressMode = .clampToEdge
        sampler.normalizedCoordinates = true
        sampler.lodMinClamp = 0
        sampler.lodMaxClamp = .greatestFiniteMagnitude
        samplerState = device.makeSamplerState(descriptor: sampler)
    }
    
    func setText(device: MTLDevice, s: String) {
        str = s
        var posData: [Float] = []
        var uvData: [Float] = []
        var x: Float = 0
        var y: Float = 0
        var du: Float = 1.0/37.0
        for i in 0..<str.count {
            let c: Character = str.charAt(at: i)
            var tx: Float = -1
            switch c {
            case "0":
                tx = 0
            case "1":
                tx = 1
            case "2":
                tx = 2
            case "3":
                tx = 3
            case "4":
                tx = 4
            case "5":
                tx = 5
            case "6":
                tx = 6
            case "7":
                tx = 7
            case "8":
                tx = 8
            case "9":
                tx = 9
            case "A":
                tx = 10
            case "B":
                tx = 11
            case "C":
                tx = 12
            case "D":
                tx = 13
            case "E":
                tx = 14
            case "F":
                tx = 15
            case "G":
                tx = 16
            case "H":
                tx = 17
            case "I":
                tx = 18
            case "J":
                tx = 19
            case "K":
                tx = 20
            case "L":
                tx = 21
            case "M":
                tx = 22
            case "N":
                tx = 23
            case "O":
                tx = 24
            case "P":
                tx = 25
            case "Q":
                tx = 26
            case "R":
                tx = 27
            case "S":
                tx = 28
            case "T":
                tx = 29
            case "U":
                tx = 30
            case "V":
                tx = 31
            case "W":
                tx = 32
            case "X":
                tx = 33
            case "Y":
                tx = 34
            case "Z":
                tx = 35
            case "-":
                tx = 36
            default:
                break
            }
            if tx == -1 {
                x+=1
                continue
            }
            posData += [x, y]
            posData += [x+1, y]
            posData += [x+1, y+1]
            posData += [x, y]
            posData += [x, y+1]
            posData += [x+1, y+1]
            
            let u: Float = tx/37.0
            uvData += [u, 0]
            uvData += [u+du, 0]
            uvData += [u+du, 1]
            uvData += [u, 0]
            uvData += [u, 1]
            uvData += [u+du, 1]
            x+=1
        }
        
        let floatSize = MemoryLayout<Float>.stride
        posBuffer = device.makeBuffer(bytes: posData, length: floatSize*posData.count, options: [])
        uvBuffer = device.makeBuffer(bytes: uvData, length: floatSize*uvData.count, options: [])
    }
    
    func render(x:Float,y:Float,w:Float,h:Float,encoder:MTLRenderCommandEncoder) {
        encoder.setRenderPipelineState(pipelineState)
        encoder.setVertexBuffer(posBuffer, offset: 0, index: 0)
        encoder.setVertexBuffer(uvBuffer, offset: 0, index: 1)
        
        let pos: [Float] = [x,y]
        let size: [Float] = [w,h]
        let wsize: [Float] = [screenW, screenH]
        
        encoder.setVertexBytes(pos, length: 2*MemoryLayout<Float>.stride, index: 2)
        encoder.setVertexBytes(size, length: 2*MemoryLayout<Float>.stride, index: 3)
        encoder.setVertexBytes(wsize, length: 2*MemoryLayout<Float>.stride, index: 4)
        
        encoder.setFragmentTexture(atlas.texture, index: 0)
        encoder.setFragmentSamplerState(samplerState, index: 0)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: posBuffer.length/MemoryLayout<Float>.size)
    }
    
}

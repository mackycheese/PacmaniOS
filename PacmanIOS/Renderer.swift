//
//  Renderer.swift
//  PacmanIOS
//
//  Created by Jack Armstrong on 12/29/18.
//  Copyright © 2018 Jack Armstrong. All rights reserved.
//

// Our platform independent renderer class

import Metal
import MetalKit
import simd

class Renderer: NSObject, MTKViewDelegate {
    
    public let device: MTLDevice
    
    var metalLayer: CAMetalLayer!
    var commandQueue: MTLCommandQueue!
    var textureLoader: MTKTextureLoader
    
    let startTime = NSDate().timeIntervalSince1970
    
    func getTime() -> Float{
        return Float(NSDate().timeIntervalSince1970-startTime)
    }
    
    var player: Player!
    var blinky: GhostBlinky!
    var pinky: GhostPinky!
    var inky: GhostInky!
    var clyde: GhostClyde!
    
    init?(metalKitView: MTKView) {
        self.device = metalKitView.device!
        
        player = Player()
        blinky = GhostBlinky()
        pinky = GhostPinky()
        inky = GhostInky()
        clyde = GhostClyde()
        
        commandQueue = device.makeCommandQueue()
        
        textureLoader = MTKTextureLoader(device: device)
        
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = metalKitView.layer.frame
        metalKitView.layer.addSublayer(metalLayer)
        
        SquareRenderer.initSquare(device: device)
        
        print("Will view auto-resize: \(metalKitView.autoResizeDrawable)")
        
        super.init()
        
    }
    
    func draw(in view: MTKView) {
        guard let drawable = metalLayer.nextDrawable() else { return }
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red:0,green:0,blue:0,alpha:1)
        
        let commandBuffer=commandQueue.makeCommandBuffer()
        let renderEncoder=commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        
//        renderEncoder?.setViewport(MTLViewport(originX: 0, originY: 0, width: Double(SquareRenderer.width), height: Double(SquareRenderer.height), znear: 0.01, zfar: 10))
//        let gw: Float = 8
//        let gh: Float = 8
//        for ix in 0..<Int(gw){
//            for iy in 0..<Int(gh){
//                let x:Float=Float(ix)
//                let y:Float=Float(iy)
//                SquareRenderer.render(x: x/gw, y: y/gh, w: 1/gw, h: 1/gh, red: 1, green: 1encoder: renderEncoder!)
//            }
//        }
        
        let dx: Float = 1.0 / Float(gridW)
        let dy: Float = 1.0 / Float(gridH)
        for ix in 0..<gridW {
            for iy in 0..<gridH {
                let fx = Float(ix)
                let fy = Float(iy)
                if levelTiles[ix][iy] == WALL {
                    SquareRenderer.render(x: fx*dx, y: fy*dy, w: dx, h: dy, red: 0, green: 0, blue: 1, encoder: renderEncoder!)
                }
            }
        }
        
        player.render(renderEncoder!)
        player.update()
        
        blinky.render(renderEncoder!)
        blinky.update(player, blinky)
        
        pinky.render(renderEncoder!)
        pinky.update(player, blinky)
        
        inky.render(renderEncoder!)
        inky.update(player, blinky)
        
        clyde.render(renderEncoder!)
        clyde.update(player, blinky)
        
        renderEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
    
    func swipe(_ dir: Dir){
        print("Swipe with dir \(dir)")
        player.nextDir = dir
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        /// Respond to drawable size or orientation changes here
        SquareRenderer.width = Float(size.width)
        SquareRenderer.height = Float(size.height)
        metalLayer.frame = view.layer.frame
    }
}
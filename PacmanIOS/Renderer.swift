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
import UIKit

class Renderer: NSObject, MTKViewDelegate {
    
    public let device: MTLDevice
    
    var metalLayer: CAMetalLayer!
    var commandQueue: MTLCommandQueue!
    var textureLoader: MTKTextureLoader
    
    var scoreText: MetalText!
    
    let startTime = NSDate().timeIntervalSince1970
    
    func getTime() -> Float{
        return Float(NSDate().timeIntervalSince1970-startTime)
    }
    
    var player: Player!
    var blinky: GhostBlinky!
    var pinky: GhostPinky!
    var inky: GhostInky!
    var clyde: GhostClyde!
    
    var levelTex: MetalTexture!
    var lifeTex: MetalTexture!
    
    init?(metalKitView: MTKView) {
        self.device = metalKitView.device!
        initLevel()
        
        player = Player(device: device)
        blinky = GhostBlinky(device: device)
        pinky = GhostPinky(device: device)
        inky = GhostInky(device: device)
        clyde = GhostClyde(device: device)
        
        scoreText = MetalText(device: device)
        
        levelTex = MetalTexture(device: device, name: "assets/level1", ext: "png", factor: 1)
        lifeTex = MetalTexture(device: device, name: "assets/life", ext: "png")
        
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
        
        SquareRenderer.renderTex(tex: levelTex, x: 0, y: 0, w: 1, h: 1, encoder: renderEncoder!)
        let dx: Float = 1.0 / Float(gridW)
        let dy: Float = 1.0 / Float(gridH)
        for ix in 0..<gridW {
            for iy in 0..<gridH {
                let fx = Float(ix)
                let fy = Float(iy)
//                if levelTiles[ix][iy] == WALL {
//                    SquareRenderer.render(x: fx*dx, y: fy*dy, w: dx, h: dy, red: 0, green: 0, blue: 1, encoder: renderEncoder!)
//                }
                if levelDots[ix][iy] {
                    let m:Float=0.5-0.5*dotSize
                    SquareRenderer.render(x: (fx+m)*dx, y: (fy+m)*dy, w: dx*(1-2*m), h: dy*(1-2*m), red: 1, green: 1, blue: 1, encoder: renderEncoder!)
                }
                if levelPowerDots[ix][iy] {
                    let m:Float=0.5-0.5*powerDotSize
                    SquareRenderer.render(x: (fx+m)*dx, y: (fy+m)*dy, w: dx*(1-2*m), h: dy*(1-2*m), red: 1, green: 1, blue: 1, encoder: renderEncoder!)
                }
            }
        }
        
        player.render(renderEncoder!)

        blinky.render(renderEncoder!)
        
        pinky.render(renderEncoder!)
        
        inky.render(renderEncoder!)
        
        clyde.render(renderEncoder!)
        
        scoreText.setText(device: device, s: "SCORE "+String(levelScore))
        scoreText.render(x: -1, y: 1-textSize, w: textSize, h: textSize, encoder: renderEncoder!)
        
        let highScore: Int = UserDefaults.standard.integer(forKey: "PACMAN_HIGHSCORE")
        UserDefaults.standard.set(max(levelScore,highScore), forKey: "PACMAN_HIGHSCORE")
        
        let highScoreStr: String = "HIGH SCORE "+String(highScore)
        scoreText.setText(device: device, s: highScoreStr)
        scoreText.render(x: 1-textSize*Float(highScoreStr.count),y:1-textSize,w:textSize,h:textSize,encoder:renderEncoder!)

        if pauseTimer < 0 && levelLives > 0 {
            player.update(blinky: blinky, pinky: pinky, inky: inky, clyde: clyde)
            blinky.update(player, blinky)
            pinky.update(player, blinky)
            inky.update(player, blinky)
            clyde.update(player, blinky)
        }
        
        if levelLives <= 0 && pauseTimer < 0 {
            initLevel()
            player.justDied=false
            player.onInitLevel()
            pauseTimer = gameStartPause
        }
        
        if levelLives > 0 {
            for i in 0..<levelLives {
                SquareRenderer.renderTex(tex: lifeTex, x: 0+lifeSize*Float(i), y: 1-lifeSize, w: lifeSize, h: lifeSize, encoder: renderEncoder!)
            }
        }
        

        // TODO: Pacman death animation, pacman win animation, score, UI menus, high score 
        
        renderEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
        
        pauseTimer -= 1
    }
    
    func swipe(_ dir: Dir){
        print("Swipe with dir \(dir)")
        player.nextDir = dir
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        /// Respond to drawable size or orientation changes here
        screenW = Float(size.width)
        screenH = Float(size.height)
        metalLayer.frame = view.layer.frame
    }
}

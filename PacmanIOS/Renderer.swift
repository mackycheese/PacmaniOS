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
import CoreMotion
import AVFoundation

class Renderer: NSObject, MTKViewDelegate {
    
    public let device: MTLDevice
    
    var metalLayer: CAMetalLayer!
    var commandQueue: MTLCommandQueue!
    var textureLoader: MTKTextureLoader!
    
    var motionManager: CMMotionManager!
    
    var fruitTextures: [MetalTexture] = []
    
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
    
    var btnReset: MetalButton!
    var btnTiltToTurn: MetalButton!
    
    
    init?(metalKitView: MTKView) {
//        try! AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        try! AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
        try! AVAudioSession.sharedInstance().setActive(true)
        
        self.device = metalKitView.device!
        initLevel(resetScore: true)
        
        for i in 1...8 {
            fruitTextures.append(MetalTexture(device: device, name: "assets/fruit-"+String(i), ext: "png"))
        }
        
        motionManager = CMMotionManager()
        
        guard motionManager.isAccelerometerAvailable else { print("Accelerometer is not available."); super.init(); exit(1); }
//        guard motionManager.isAccelerometerActive else { print("Accelerometer is not active."); super.init(); exit(1); }
        guard motionManager.isGyroAvailable else { print("Gyrometer is not available."); super.init(); exit(1); }
        
        motionManager.startAccelerometerUpdates()
        motionManager.startGyroUpdates()
        motionManager.startDeviceMotionUpdates()
        
        player = Player(device: device)
        blinky = GhostBlinky(device: device)
        pinky = GhostPinky(device: device)
        inky = GhostInky(device: device)
        clyde = GhostClyde(device: device)
        
        btnReset=MetalButton(device: device)
        btnReset.setText(device: device, "RESET")
        btnReset.setState(on: false)
        btnReset.setBounds(x: 0, y: uiSize*4.1, w: uiSize, h: uiSize)
        
        btnTiltToTurn=MetalButton(device: device)
        btnTiltToTurn.setText(device: device, "YOU SHOULD NOT SEE THIS TEXT")
        btnTiltToTurn.setState(on: false)
        btnTiltToTurn.setBounds(x: 0, y: uiSize*3, w: uiSize, h: uiSize)
        
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
    
    func handleTilt() {
        let accRate: CMAcceleration = (motionManager.accelerometerData?.acceleration)!
        let x: Float = Float(accRate.x)
        let y: Float = Float(accRate.y)
        let amount: Float = 0.2
        //        let dm: CMDeviceMotion = motionManager.deviceMotion?.attitude
        if x < -amount {
            player.nextDir = .l
        }
        if x > amount {
            player.nextDir = .r
        }
        if y > amount {
            player.nextDir = .u
        }
        if y < -amount {
            player.nextDir = .d
        }
    }
    
    func draw(in view: MTKView) {
//        print(motionManager.gyroData?.rotationRate)
//        let rotRate: CMRotationRate = (motionManager.gyroData?.rotationRate)!
//        let x: Float = Float(rotRate.x)
//        let x: Float = Float(rotRate.y)
        if btnTiltToTurn.isOn {
            handleTilt()
        }
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
        
        if fruitSpawned {
            let dx:Float=1.0/Float(gridW)
            let dy:Float=1.0/Float(gridH)
            if fruitNumber > 8 {
                fruitNumber = 8
            }
            print("Fruit number: \(fruitNumber)")
            SquareRenderer.renderTex(tex: fruitTextures[fruitNumber-1], x: dx*(13-spriteExtra), y: dy*(17-spriteExtra), w: dx*(1+2*spriteExtra), h: dy*(1+2*spriteExtra), encoder: renderEncoder!)
        }
        
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
            initLevel(resetScore: true)
            player.justDied=false
            player.onInitLevel()
//            scoreText.setText(device: device, s: "SCORE 0")
            levelScore = 0
            pauseTimer = gameStartPause
        }
        
        if levelLives > 0 {
            for i in 0..<levelLives {
                SquareRenderer.renderTex(tex: lifeTex, x: 0+lifeSize*Float(i), y: 1-lifeSize, w: lifeSize, h: lifeSize, encoder: renderEncoder!)
            }
        }
        

        btnReset.render(encoder: renderEncoder!)
        btnTiltToTurn.render(encoder: renderEncoder!)
        
        if btnTiltToTurn.isOn {
            btnTiltToTurn.setText(device: device, "TILT TO TURN  Y")
        } else {
            btnTiltToTurn.setText(device: device, "TILT TO TURN  N")
        }
        // MARK: TODO: Pacman death animation, pacman win animation, score, UI menus, high score, sound effects, fix score buffers
        
        renderEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
        
        pauseTimer -= 1
        behaviourTimer -= 1
        if behaviourTimer < 0 {
            if scatterMode {
                scatterMode = false
                behaviourTimer = timeChase
            } else {
                scatterMode = true
                behaviourTimer = timeScatter
            }
        }
        
    }
    
    func swipe(_ dir: Dir){
        print("Swipe with dir \(dir)")
        player.nextDir = dir
    }
    
    func tap(x: Float, y: Float) {
        if btnTiltToTurn.containsPoint(x, y) {
            btnTiltToTurn.toggle()
        }
        if btnReset.containsPoint(x, y) {
            initLevel(resetScore: true)
            player.onInitLevel()
        }
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        /// Respond to drawable size or orientation changes here
        screenW = Float(size.width)
        screenH = Float(size.height)
        metalLayer.frame = view.layer.frame
    }
}

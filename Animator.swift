//
//  Animator.swift
//  PacmanIOS
//
//  Created by Jack Armstrong on 12/30/18.
//  Copyright © 2018 Jack Armstrong. All rights reserved.
//

import Foundation
import Metal

class Animator {
    
    var animL: [Texture] = []
    var animR: [Texture] = []
    var animU: [Texture] = []
    var animD: [Texture] = []
    
    var speed: Float!
    var numFrames: Int!
    var frame: Int!
    
    init(device: MTLDevice, name: String, numFrames: Int, speed: Float) {
        frame = 0
        self.numFrames = numFrames
        for i in 0..<self.numFrames {
            animL.append(Texture(device: device, name: "assets/"+String(name)+"-l"+String(i), ext: "png"))
            animR.append(Texture(device: device, name: "assets/"+String(name)+"-r"+String(i), ext: "png"))
            animU.append(Texture(device: device, name: "assets/"+String(name)+"-u"+String(i), ext: "png"))
            animD.append(Texture(device: device, name: "assets/"+String(name)+"-d"+String(i), ext: "png"))
        }
        self.speed=speed
    }
    
    func render(gx: Int, gy: Int, offx: Float, offy: Float, dir: Dir, encoder: MTLRenderCommandEncoder) {
        let dx: Float = 1.0/Float(gridW)
        let dy: Float = 1.0/Float(gridH)
        let t: Int = Int(Float(frame)*speed)%numFrames
        var tex=animL[t]
        switch dir {
        case .l:
            tex=animL[t]
        case .r:
            tex=animR[t]
        case .u:
            tex=animU[t]
        case .d:
            tex=animD[t]
        default: break
        }
        SquareRenderer.renderTex(tex: tex, x: (Float(gx)+offx-spriteExtra)*dx, y: (Float(gy)+offy-spriteExtra)*dy, w: (1+2*spriteExtra)*dx, h: (1+2*spriteExtra)*dy, encoder: encoder)
    }
    
    func step(){
        frame+=1
    }
    
}

//
//  Player.swift
//  PacmanIOS
//
//  Created by Jack Armstrong on 12/29/18.
//  Copyright © 2018 Jack Armstrong. All rights reserved.
//

import Foundation
import Metal

class Player: Entity {
    
    init(device: MTLDevice!){
        super.init()
        gx = 13
        gy = 17
        speed = playerSpeed
        anim=Animator(device: device, name: "pacman", numFrames: 2, speed: playerAnimSpeed)
    }
    
    var anim: Animator!
    
    func die(blinky: Ghost, pinky: Ghost, inky: Ghost, clyde: Ghost){
        gx=13
        gy=17
        offx=0
        offy=0
        blinky.reset()
        pinky.reset()
        inky.reset()
        clyde.reset()
    }
    
    override func render(_ encoder: MTLRenderCommandEncoder) {
        anim.render(gx: gx, gy: gy, offx: offx, offy: offy, dir: dir, encoder: encoder)
        anim.step()
    }
    
    func update(blinky: Ghost, pinky: Ghost, inky: Ghost, clyde: Ghost){
        if canMoveInDir(nextDir)&&offx==0&&offy==0{
            dir=nextDir
        }
        var possibleToWin: Bool = false
        if levelDots[gx][gy] {
            levelDots[gx][gy] = false
            possibleToWin = true
        }
        if levelPowerDots[gx][gy] {
            levelPowerDots[gx][gy] = false
            blinky.scare()
            pinky.scare()
            inky.scare()
            clyde.scare()
            possibleToWin = true
        }
        if possibleToWin {
            var dotsRemaining: Bool = false
            for x in 0..<gridW {
                for y in 0..<gridH {
                    dotsRemaining = dotsRemaining || levelDots[x][y] || levelPowerDots[x][y]
                }
            }
            if !dotsRemaining {
                initLevel()
                die(blinky: blinky, pinky: pinky, inky: inky, clyde: clyde)
            }
        }
        let ghosts: [Ghost] = [blinky, pinky, inky, clyde]
        for i in 0..<4 {
            let ghost: Ghost = ghosts[i]
            if hasHit(ghost) {
                if ghost.scared {
                    ghost.die()
                }else {
                    die(blinky: blinky, pinky: pinky, inky: inky, clyde: clyde)
                }
            }
        }
        moveInDir()
        resetOff()
    }
    
    func hasHit(_ ghost: Ghost) -> Bool {
        return gx == ghost.gx && gy == ghost.gy
    }
    
}

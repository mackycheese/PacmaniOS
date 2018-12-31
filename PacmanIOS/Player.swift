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
        gy = 23
        speed = playerSpeed
        bonusAmount = 0
        anim=Animator(device: device, name: "pacman", numFrames: 2, speed: playerAnimSpeed)
        animDie=Animator(device: device, name: "pacman-die", numFrames: 12, speed: 12/Float(gameLosePause), nodir: true)
    }
    
    var anim: Animator!
    var animDie: Animator!
    var bonusAmount: Int!
    var justDied: Bool! = false
    
    func die(blinky: Ghost, pinky: Ghost, inky: Ghost, clyde: Ghost){
        gx=13
        gy=23
        //TODO: Reset position after death animation
        offx=0
        offy=0
        blinky.reset()
        pinky.reset()
        inky.reset()
        clyde.reset()
        pauseTimer = gameStartPause
    }
    
    override func render(_ encoder: MTLRenderCommandEncoder) {
        if justDied {
            animDie.render(gx: gx, gy: gy, offx: offx, offy: offy, dir: .l, encoder: encoder)
            animDie.step()
        } else {
            anim.render(gx: gx, gy: gy, offx: offx, offy: offy, dir: dir, encoder: encoder)
        }
    }
    
    func update(blinky: Ghost, pinky: Ghost, inky: Ghost, clyde: Ghost){
        justDied=false
        anim.step()
        if canMoveInDir(nextDir)&&offx==0&&offy==0{
            dir=nextDir
        }
        var possibleToWin: Bool = false
        if levelDots[gx][gy] {
            levelDots[gx][gy] = false
            possibleToWin = true
            levelScore += scoreIncreaseDot
        }
        if levelPowerDots[gx][gy] {
            levelPowerDots[gx][gy] = false
            blinky.scare()
            pinky.scare()
            inky.scare()
            clyde.scare()
            bonusAmount=200
            possibleToWin = true
            levelScore += scoreIncreasePowerPellet
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
                pauseTimer = gameStartPause
            }
        }
        let ghosts: [Ghost] = [blinky, pinky, inky, clyde]
        for i in 0..<4 {
            let ghost: Ghost = ghosts[i]
            if hasHit(ghost) {
                if ghost.scared {
                    ghost.die()
                    pauseTimer = playerPauseEatGhost
                    levelScore+=bonusAmount
                    bonusAmount*=2
                }else {
                    die(blinky: blinky, pinky: pinky, inky: inky, clyde: clyde)
                    levelLives-=1
                    justDied=true
                    if levelLives <= 0 {
                        pauseTimer = gameLosePause
                        animDie.speed=12/Float(gameLosePause)
                        animDie.frame=0
                    } else {
                        pauseTimer = gameStartPause
                        animDie.speed=12/Float(gameStartPause)
                        animDie.frame=0
                    }
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

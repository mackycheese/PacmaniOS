//
//  Player.swift
//  PacmanIOS
//
//  Created by Jack Armstrong on 12/29/18.
//  Copyright © 2018 Jack Armstrong. All rights reserved.
//

import Foundation
import Metal
import AVFoundation

class Player: Entity {
    
    init(device: MTLDevice!){
        super.init()
        gx = 13
        gy = 23
        speed = playerSpeed
        bonusAmount = 0
        anim=Animator(device: device, name: "pacman", numFrames: 2, speed: playerAnimSpeed)
        animDie=Animator(device: device, name: "pacman-die", numFrames: 12, speed: 12/Float(gameDiePause), nodir: true)
        
        audioEat = try! AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "assets/sound/waza",withExtension:"mp3")!)
        audioEatGhost = try! AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "assets/sound/eat-ghost", withExtension: "mp3")!)
        audioEatPill = try! AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "assets/sound/eat-pill", withExtension: "mp3")!)
    }
    
    var audioEat: AVAudioPlayer!
    var audioEatGhost: AVAudioPlayer!
    var audioEatPill: AVAudioPlayer!
    
    var anim: Animator!
    var animDie: Animator!
    var bonusAmount: Int!
    var justDied: Bool! = false
    
    func onInitLevel(){
        gx=13
        gy=23
        offx=0
        offy=0
    }
    
    func die(blinky: Ghost, pinky: Ghost, inky: Ghost, clyde: Ghost){
        //TODO: Reset position after death animation, only do death animation if
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
        if Int(Float(animDie.frame)*animDie.speed) >= animDie.numFrames && justDied {
            gx=13
            gy=23
            offx=0
            offy=0
        }
        if justDied {
//            gx=13
//            gy=23
            justDied=false
        }
        anim.step()
        if canMoveInDir(nextDir)&&offx==0&&offy==0{
            dir=nextDir
        }
        var possibleToWin: Bool = false
        if levelDots[gx][gy] {
            levelDots[gx][gy] = false
            possibleToWin = true
            levelScore += scoreIncreaseDot
//            audioEat.play()
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
            audioEatPill.play()
        }
        if possibleToWin {
            var dotsRemaining: Bool = false
            for x in 0..<gridW {
                for y in 0..<gridH {
                    dotsRemaining = dotsRemaining || levelDots[x][y] || levelPowerDots[x][y]
                }
            }
            if !dotsRemaining {
                initLevel(resetScore: false)
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
                    audioEatGhost.play()
                }else {
                    die(blinky: blinky, pinky: pinky, inky: inky, clyde: clyde)
                    levelLives-=1
                    justDied=true
                    if levelLives <= 0 {
                        pauseTimer = gameDiePause
                        animDie.speed=12/Float(gameDiePause)
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

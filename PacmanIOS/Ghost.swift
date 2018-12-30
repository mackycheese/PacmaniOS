//
//  Ghost.swift
//  PacmanIOS
//
//  Created by Jack Armstrong on 12/29/18.
//  Copyright © 2018 Jack Armstrong. All rights reserved.
//

import Foundation

class Ghost: Entity {
    //player: 15,17
    //ghost: 12,13
    //ghost exit: 12,11
    
    override init() {
        super.init()
        gx = 11
        gy = 15
        speed = ghostNormalSpeed
        enterTimer = getEnterTime()
    }
    
    var enterTimer: Int! = 0
    var scared: Bool! = false
    var scaredTimer: Int! = 0
    var inGhostHouse: Bool! = true
    
    func getEnterTime() -> Int {
        return 0
    }
    
    func getGhostColor() -> [Float] {
        return [1,1,1]
    }
    
    func getTarget(_ player: Player, _ blinky: Ghost) -> [Int] {
        return [0,0]
    }
    
    override func getColor() -> [Float] {
        if scared {
            if scaredTimer<ghostFlashTime && (scaredTimer/ghostFlashSpeed)%2 == 0 {
                return [1,1,1]
            } else {
                return [0,0,1]
            }
        }
        return getGhostColor()
    }
    
    func reset(){
        enterTimer=getEnterTime()
        scared=false
        scaredTimer=0
        gx=12
        gy=13
        speed=ghostNormalSpeed
        offx=0
        offy=0
    }
    
    func scare(){
        scared=true
        scaredTimer=ghostScareTime
        if canMoveInDir(dir.getOpp()){
            dir=dir.getOpp()
        }
    }
    
    func die(){
        gx=11
        gy=15
        scared=false
        scaredTimer=0
        enterTimer=ghostDeathEnterTime
        speed=ghostNormalSpeed
        offx=0
        offy=0
    }
    
    func update(_ player: Player, _ blinky: Ghost){
        if scared {
            speed=ghostScaredSpeed
            scaredTimer-=1
            if scaredTimer<0{
                scared=false
            }
        }else{
            speed=ghostNormalSpeed
            if levelTiles[gx][gy] == GHOST_SLOWDOWN {
                speed = ghostSlowSpeed
            }
        }
        enterTimer-=1
        if enterTimer==0{
            gx=12
            gy=11
            offx=0
            offy=0
        }
        
        resetOff()
        
        let allDirs: [Dir] = [.l, .r, .u, .d]
        
        var dirs: [Dir] = []
        for i in 0..<4 {
            if canMoveInDir(allDirs[i]) && !dir.isOpp(allDirs[i]){
                dirs.append(allDirs[i])
            }
        }
        if scared {
            nextDir=dirs.randomElement()
        }else{
            if(offx==0&&offy==0){
                var target=getTarget(player, blinky)
                if enterTimer>0{
                    target=[  Int.random(in: -100...100), Int.random(in: -100...100)  ]
                }
                var noUp = false
                for i in 0..<levelGhostNoUp.count {
                    if gx == levelGhostNoUp[i][0] && gy == levelGhostNoUp[i][1]{
                        noUp=true
                    }
                }
                if noUp && dirs.contains(.u) {
                    dirs = dirs.filter {$0 != .u}
                }
                var weights: [Float] = []
                for i in 0..<dirs.count {
                    let x0: Float = Float(target[0])
                    let y0: Float = Float(target[1])
                    let x1: Float = Float(gx + dirs[i].getX())
                    let y1: Float = Float(gy + dirs[i].getY())
                    let comp1: Float = (x0-x1)*(x0-x1)
                    let comp2: Float = (y0-y1)*(y0-y1)
                    weights.append( comp1+comp2 )
                }
                let minWeight = weights.min()
                let index = weights.firstIndex(of: minWeight!)
                nextDir = dirs[index!]
            }
        }
        if canMoveInDir(nextDir)&&offx==0&&offy==0{
            dir=nextDir
        }
        moveInDir()
        resetOff()
    }
    
}
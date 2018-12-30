//
//  Player.swift
//  PacmanIOS
//
//  Created by Jack Armstrong on 12/29/18.
//  Copyright © 2018 Jack Armstrong. All rights reserved.
//

import Foundation

class Player: Entity {
    
    override init(){
        super.init()
        gx = 13
        gy = 17
        speed = playerSpeed
    }
    
    func update(){
        if canMoveInDir(nextDir)&&offx==0&&offy==0{
            dir=nextDir
        }
        moveInDir()
        resetOff()
    }
    
    override func getColor() -> [Float] {
        return [1,1,0]
    }
    
}

//
//  GhostClyde.swift
//  PacmanIOS
//
//  Created by Jack Armstrong on 12/29/18.
//  Copyright © 2018 Jack Armstrong. All rights reserved.
//

import Foundation

class GhostClyde: Ghost {
    
    override func getEnterTime() -> Int {
        return ghostEnterTimeClyde
    }
    
    override func getGhostColor() -> [Float] {
        return [1,0.4,0]
    }
    
    override func getTarget(_ player: Player, _ blinky: Ghost) -> [Int] {
        let px: Float = Float(player.gx)
        let py: Float = Float(player.gy)
        let x: Float = Float(gx)
        let y: Float = Float(gy)
        let dist: Float = sqrt( (x-px)*(x-px) + (y-py)*(y-py) )
        if dist > 8{
            return [player.gx, player.gy]
        }
        return [0,gridH]
    }
    
}

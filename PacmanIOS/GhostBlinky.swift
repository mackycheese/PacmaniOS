//
//  GhostBlinky.swift
//  PacmanIOS
//
//  Created by Jack Armstrong on 12/29/18.
//  Copyright © 2018 Jack Armstrong. All rights reserved.
//

import Foundation

class GhostBlinky: Ghost {
    
    override func getEnterTime() -> Int {
        return ghostEnterTimeBlinky
    }
    
    override func getGhostColor() -> [Float] {
        return [1,0,0]
    }
    
    override func getTarget(_ player: Player, _ blinky: Ghost) -> [Int] {
        return [player.gx, player.gy]
    }
    
}
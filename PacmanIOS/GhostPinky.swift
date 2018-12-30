//
//  GhostPinky.swift
//  PacmanIOS
//
//  Created by Jack Armstrong on 12/29/18.
//  Copyright © 2018 Jack Armstrong. All rights reserved.
//

import Foundation

class GhostPinky: Ghost {
    
    override func getGhostColor() -> [Float] {
        return [1,0,1]
    }
    
    override func getEnterTime() -> Int {
        return ghostEnterTimePinky
    }
    
    override func getTarget(_ player: Player, _ blinky: Ghost) -> [Int] {
        return [player.gx + 4*player.dir.getX(), player.gy+4*player.dir.getY()]
    }
    
}

//
//  GhostPinky.swift
//  PacmanIOS
//
//  Created by Jack Armstrong on 12/29/18.
//  Copyright © 2018 Jack Armstrong. All rights reserved.
//

import Foundation

class GhostPinky: Ghost {
    
    override func getName() -> String {
        return "pinky"
    }
    
    override func getEnterTime() -> Int {
        return ghostEnterTimePinky
    }
    
    override func getCorner() -> [Int] {
        return [0,0]
    }
    
    override func getTarget(_ player: Player, _ blinky: Ghost) -> [Int] {
        return [player.gx + 4*player.dir.getX(), player.gy+4*player.dir.getY()]
    }
    
}

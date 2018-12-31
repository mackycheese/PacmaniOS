//
//  GhostInky.swift
//  PacmanIOS
//
//  Created by Jack Armstrong on 12/29/18.
//  Copyright © 2018 Jack Armstrong. All rights reserved.
//

import Foundation

class GhostInky: Ghost {
    
    override func getEnterTime() -> Int {
        return ghostEnterTimeInky
    }
    
    override func getName() -> String {
        return "inky"
    }
    
    override func getCorner() -> [Int] {
        return [gridW,gridH]
    }
    
    override func getTarget(_ player: Player, _ blinky: Ghost) -> [Int] {
        let px: Int = player.gx+2*player.dir.getX()
        let py: Int = player.gy+2*player.dir.getY()
        let bx: Int = blinky.gx
        let by: Int = blinky.gy
        let dx: Int = px-bx
        let dy: Int = py-by
        return [bx+2*dx,by+2*dy]
    }
    
}

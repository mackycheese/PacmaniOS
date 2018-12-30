//
//  Entity.swift
//  PacmanIOS
//
//  Created by Jack Armstrong on 12/29/18.
//  Copyright © 2018 Jack Armstrong. All rights reserved.
//

import Foundation
import Metal

class Entity {
    
    var gx: Int!
    var gy: Int!
    
    var offx: Float!
    var offy: Float!
    
    var speed: Float!
    
    var dir: Dir!
    var nextDir: Dir!
    
    init(){
        gx = 0
        gy = 0
        offx = 0
        offy = 0
        speed = 0
        dir = .l
        nextDir = .l
    }
    
    func getColor() -> [Float] {
        return [1,1,1]
    }
    
    func render(_ encoder: MTLRenderCommandEncoder){
        let dx: Float = 1.0/Float(gridW)
        let dy: Float = 1.0/Float(gridH)
        let col: [Float] = getColor()
        SquareRenderer.render(x: (Float(gx)+offx)*dx, y: (Float(gy)+offy)*dy, w: dx, h: dy, red: col[0], green: col[1], blue: col[2], encoder: encoder)
    }
    
    func canMoveInDir(_ d: Dir) -> Bool {
        let x = gx + d.getX()
        let y = gy + d.getY()
        if x<0||y<0||x>=gridW||y>=gridH {
            return true
        }
        return levelTiles[x][y] != WALL
    }
    
    func moveInDir(){
        if canMoveInDir(dir){
            offx+=Float(dir.getX())*speed
            offy+=Float(dir.getY())*speed
        }
    }
    
    func resetOff(){
        if offx < -1{
            gx-=1
            offx=0
        }
        if offy < -1{
            gy-=1
            offy=0
        }
        if offx>1{
            gx+=1
            offx=0
        }
        if offy>1{
            gy+=1
            offy=0
        }
        
        if offx==0&&offy==0{
            if gx<0&&dir == .l{
                gx=gridW-1
            }
            if gx>=gridW&&dir == .r{
                gx=0
            }
        }
    }
    
    
    
}

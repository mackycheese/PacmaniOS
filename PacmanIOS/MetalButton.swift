//
//  MetalButton.swift
//  PacmanIOS
//
//  Created by Jack Armstrong on 12/31/18.
//  Copyright © 2018 Jack Armstrong. All rights reserved.
//

import Foundation
import Metal

class MetalButton {
    
    var text: MetalText!
    let colOn: [Float] = [0.5,0.5,0.5]
    let colOff: [Float] = [0.25,0.25,0.25]
    var str: String!
    var isOn: Bool!
    var x: Float = 0
    var y: Float = 0
    var w: Float = 1
    var h: Float = 1
    
    init(device: MTLDevice) {
        text = MetalText(device: device)
        isOn = false
    }
    
    func setBounds(x: Float, y: Float, w: Float, h: Float) {
        self.x=x
        self.y=y
        self.w=w
        self.h=h
    }
    
    func toggle() {
        isOn = !isOn
    }
    
    func containsPoint(_ px: Float, _ py: Float) -> Bool {
        return px>=x&&px<=x+w*Float(str.count)&&py>=y&&py<=y+h
    }
    
    func setState(on: Bool) {
        isOn = on
    }
    
    func setText(device: MTLDevice, _ str: String) {
        text.setText(device: device, s: str)
        self.str=str
    }
    
    func render(encoder: MTLRenderCommandEncoder){
        var col:[Float]=colOff
        if isOn {
            col=colOn
        }
        SquareRenderer.render(x: x, y: -y, w: Float(str.count)*w, h: -h, red: col[0], green: col[1], blue: col[2], encoder: encoder)
        text.render(x: x*2-1, y: y*2+1, w: w*2, h: h*2, encoder: encoder)
    }
    
}

//
//  Config.swift
//  PacmanIOS
//
//  Created by Jack Armstrong on 12/29/18.
//  Copyright © 2018 Jack Armstrong. All rights reserved.
//

import Foundation

var screenW: Float = 0
var screenH: Float = 0

let textSize: Float = 0.05
let lifeSize: Float = 0.025

let playerPauseEatGhost: Int = 20
let gameStartPause: Int = 100
let gameDiePause: Int = 200

let playerAnimSpeed: Float = 0.2
let ghostAnimSpeed: Float = 0.2
let ghostScaredAnimSpeed: Float = 0.1

let scoreIncreaseDot = 10
let scoreIncreasePowerPellet = 50

let spriteExtra: Float = 0.3

let dotSize: Float = 0.2
let powerDotSize: Float = 0.4

let speedScale: Float = 0.05

let playerSpeed: Float = 2 * speedScale
let ghostNormalSpeed: Float = 2 * speedScale
let ghostSlowSpeed: Float = 1.25 * speedScale
let ghostScaredSpeed: Float = 0.5 * speedScale
let ghostScareTime: Int = 400
let ghostDeathEnterTime: Int = 200
let ghostFlashTime: Int = 50
let ghostFlashSpeed: Int = 10
let ghostEnterTimeBlinky: Int = 1
let ghostEnterTimePinky: Int = 50
let ghostEnterTimeInky: Int = 100
let ghostEnterTimeClyde: Int = 150

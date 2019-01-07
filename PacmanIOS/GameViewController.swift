//
//  GameViewController.swift
//  PacmanIOS
//
//  Created by Jack Armstrong on 12/29/18.
//  Copyright © 2018 Jack Armstrong. All rights reserved.
//

import UIKit
import MetalKit

// Our iOS specific view controller
class GameViewController: UIViewController {

    var renderer: Renderer!
    var mtkView: MTKView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    @objc public func onSwipe(_ sender: UISwipeGestureRecognizer){
        print("Direction: \(sender.direction)")
        switch sender.direction {
        case .left:
            print("Swipe left")
            renderer.swipe(Dir.l)
        case .right:
            print("Swipe right")
            renderer.swipe(Dir.r)
        case .up:
            print("Swipe up")
            renderer.swipe(Dir.u)
        case .down:
            print("Swipe down")
            renderer.swipe(Dir.d)
        default:
            print("Undefined swipe")
        }
    }
    
    @objc public func onTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let point: CGPoint = sender.location(in: view)
            let gameTop: Float = (screenH - screenW)*0.25
            let x: Float = Float(point.x) / screenW*2
            let y: Float = (gameTop - Float(point.y))/screenW*2
            renderer.tap(x: x, y: y)
            print("Tap at \(x),\(y) with gameTop=\(gameTop)")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(GameViewController.onSwipe))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(GameViewController.onSwipe))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(GameViewController.onSwipe))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(GameViewController.onSwipe))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(GameViewController.onTap))
        view.addGestureRecognizer(tap)
        
        guard let mtkView = view as? MTKView else {
            print("View of Gameview controller is not an MTKView")
            return
        }

        // Select the device to render with.  We choose the default device
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported")
            return
        }
        
        mtkView.device = defaultDevice
        mtkView.backgroundColor = UIColor.black

        guard let newRenderer = Renderer(metalKitView: mtkView) else {
            print("Renderer cannot be initialized")
            return
        }

        renderer = newRenderer
        
        renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)

        mtkView.delegate = renderer
    }
}

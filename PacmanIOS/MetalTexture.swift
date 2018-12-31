//
//  Texture.swift
//  PacmanIOS
//
//  Created by Jack Armstrong on 12/30/18.
//  Copyright © 2018 Jack Armstrong. All rights reserved.
//

import Foundation
import Metal
import MetalKit

class MetalTexture {
    
    var path: String!
    var width: Int!
    var height: Int!
    var format: MTLPixelFormat! = .bgra8Unorm
    let bitsPerComponent: Int = 8
    let bytesPerPixel: Int = 4
    var texture: MTLTexture!
    var target: MTLTextureType!
    
    //https://www.raywenderlich.com/719-metal-tutorial-with-swift-3-part-3-adding-texture
    
    init(device: MTLDevice, name: String, ext: String, factor: Int) {
        
        path = Bundle.main.path(forResource: name, ofType: ext)
        print(path)
        let image: CGImage = (UIImage(contentsOfFile: path)?.cgImage)!
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        width = image.width/factor
        height = image.height/factor
        
        let rowBytes = width*bytesPerPixel
        
        let context=CGContext(data: nil,width:width,height:height,bitsPerComponent:bitsPerComponent,bytesPerRow:rowBytes,space:colorSpace,bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue)!
        let bounds=CGRect(x: 0,y:0,width:width,height:height)
        context.clear(bounds)
        
        context.draw(image, in: bounds)
        
        let texDescr=MTLTextureDescriptor.texture2DDescriptor(pixelFormat: format, width: width, height: height, mipmapped: false)
        target = texDescr.textureType
        
        texture=device.makeTexture(descriptor: texDescr)
        
        let pixelData=context.data!
        let region=MTLRegionMake2D(0, 0, width, height)
        texture.replace(region: region, mipmapLevel: 0, withBytes: pixelData, bytesPerRow: rowBytes)
    }
    
    init(device: MTLDevice, name: String, ext: String) {
        path = Bundle.main.path(forResource: name, ofType: ext)
        print(path)
        let image: CGImage = (UIImage(contentsOfFile: path)?.cgImage)!
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        width = image.width
        height = image.height
        
        let rowBytes = width*bytesPerPixel
        
        let context=CGContext(data: nil,width:width,height:height,bitsPerComponent:bitsPerComponent,bytesPerRow:rowBytes,space:colorSpace,bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue)!
        let bounds=CGRect(x: 0,y:0,width:width,height:height)
        context.clear(bounds)
        
        context.draw(image, in: bounds)
        
        let texDescr=MTLTextureDescriptor.texture2DDescriptor(pixelFormat: format, width: width, height: height, mipmapped: false)
        target = texDescr.textureType
        
        texture=device.makeTexture(descriptor: texDescr)
        
        let pixelData=context.data!
        let region=MTLRegionMake2D(0, 0, width, height)
        texture.replace(region: region, mipmapLevel: 0, withBytes: pixelData, bytesPerRow: rowBytes)
        
    }
    
}

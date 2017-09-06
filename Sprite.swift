//
//  Sprite.swift
//  Dive Jive
//
//  Created by Conrad Oei on 6/3/17.
//  Copyright © 2017 Coleman. All rights reserved.
//

import SpriteKit
import GameplayKit

protocol Sprite{
    var animation: [SKTexture] {get set}
    var spriteNode: SKSpriteNode {get set}
    
    func getNode() -> SKSpriteNode
    func createAnimation(atlasName: String) -> [SKTexture]
    func playAnimation()
}

extension Sprite{
    func createAnimation(atlasName: String) -> [SKTexture]{
        var diverAnimation = [SKTexture]()
        let diverAtlas = SKTextureAtlas(named: "\(atlasName)")
        
        for index in 1...diverAtlas.textureNames.count{
            let imgName = String(format: "\(atlasName)%01d", index)
            diverAnimation += [diverAtlas.textureNamed(imgName)]
        }
        return diverAnimation
    }
    
    
    func getNode() -> SKSpriteNode{
        return spriteNode
    }
}

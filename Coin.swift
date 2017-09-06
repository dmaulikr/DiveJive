//
//  Coin.swift
//  Dive Jive
//
//  Created by Conrad Oei on 6/2/17.
//  Copyright © 2017 Coleman. All rights reserved.
//

import SpriteKit
import GameplayKit

class Coin: Sprite {
    var animation = [SKTexture]()
    var spriteNode: SKSpriteNode
    let categoryBitmask: UInt32 = 0x1 << 5
    
    required init(node: SKSpriteNode) {
        spriteNode = node
        animation = createAnimation(atlasName: "Coin")
        spriteNode.xScale = 6
        spriteNode.yScale = 6
    }
    
    func playAnimation() {
        let animation = SKAction.animate(with: self.animation, timePerFrame: 0.5)
        let runRotate = SKAction.repeatForever(animation)
        spriteNode.run(runRotate)
    }
}

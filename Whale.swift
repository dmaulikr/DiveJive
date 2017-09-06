//
//  Whale.swift
//  Dive Jive
//
//  Created by Conrad Oei on 5/31/17.
//  Copyright © 2017 Coleman. All rights reserved.
//

import SpriteKit
import GameplayKit

class Whale: Mob {
    var animation = [SKTexture]()
    var spriteNode: SKSpriteNode
    var spawnOnRight: Bool
    var swimDirection: Int = 0
    var swimMag = 700
    let categoryBitmask: UInt32 = 0x1 << 2
    
    required init(node: SKSpriteNode) {
        spriteNode = node
        spriteNode.xScale = 6
        spriteNode.yScale = 6
        spawnOnRight = arc4random_uniform(2) == 0 //randomly decide whether the mob should spawn on the right or left
        swimDirection = createSwimMag()
        spriteNode.physicsBody = SKPhysicsBody(texture: spriteNode.texture!, alphaThreshold: 0, size: spriteNode.size)
        spriteNode.physicsBody?.isDynamic = true
        spriteNode.physicsBody?.affectedByGravity = false
        spriteNode.physicsBody?.allowsRotation = false
        spriteNode.physicsBody?.categoryBitMask = BitMask.whale
        spriteNode.physicsBody?.collisionBitMask = 0
        spriteNode.physicsBody?.contactTestBitMask = BitMask.diver
        spriteNode.physicsBody?.usesPreciseCollisionDetection = true
        animation = createAnimation(atlasName: "Whale")
    }
}

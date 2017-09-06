//
//  Swordfish.swift
//  Dive Jive
//
//  Created by Conrad Oei on 6/1/17.
//  Copyright © 2017 Coleman. All rights reserved.
//

import SpriteKit
import GameplayKit

class Swordfish: Mob {
    var animation = [SKTexture]()
    var spriteNode: SKSpriteNode
    var spawnOnRight: Bool
    var swimDirection: Int = 0
    var swimMag = 70
    let categoryBitmask: UInt32 = 0x1 << 4
    
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
        spriteNode.physicsBody?.categoryBitMask = BitMask.swordfish
        spriteNode.physicsBody?.collisionBitMask = 0
        spriteNode.physicsBody?.contactTestBitMask = BitMask.diver
        spriteNode.physicsBody?.usesPreciseCollisionDetection = true
        animation = createAnimation(atlasName: "PufferFish")
    }
}

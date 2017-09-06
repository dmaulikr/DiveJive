//
//  Mob.swift
//  Dive Jive
//
//  Created by Conrad Oei on 5/30/17.
//  Copyright © 2017 Coleman. All rights reserved.
//

import SpriteKit
import GameplayKit

protocol Mob: Character{
    var spawnOnRight: Bool {get set}
    var swimDirection: Int {get set}
    var swimMag: Int {get}
}

extension Mob {
    
    func createSwimMag() -> Int{
        if(spawnOnRight){
            return -1
        }
        else {
            return 1
        }
    }
    
    func playAnimation(){
        let animation = SKAction.animate(with: self.animation, timePerFrame: 0.5)
        let pause = SKAction.wait(forDuration: 0.5)
        let swimAnimation = SKAction.sequence([animation, pause])
        let runSwim = SKAction.repeatForever(swimAnimation)
        spriteNode.run(runSwim)
    }
    
    func swim(){
        let move = SKAction.run {
            self.spriteNode.physicsBody?.applyForce(CGVector(dx: self.swimDirection * self.swimMag, dy: 0))
        }
        //let move = SKAction.applyForce(CGVector(dx: self.swimMag, dy: 0), duration: 0.1)
//        let swimAni = SKAction.run {
//            self.swimAnimation()
//        }
        let animation = SKAction.animate(with: self.animation, timePerFrame: 0.5)
        let pause = SKAction.wait(forDuration: 0.5)
        let swim = SKAction.sequence([move, animation, pause])
        let runSwim = SKAction.repeatForever(swim)
        spriteNode.run(runSwim)
    }
}

//
//  Diver.swift
//  Dive Jive
//
//  Created by Coleman Oei on 1/7/17.
//  Copyright © 2017 Coleman. All rights reserved.
//

import SpriteKit
import GameplayKit

class Diver: Character {
    
    internal let numBubbles = 10
    internal var spriteNode: SKSpriteNode
    internal var animation = [SKTexture]()
    internal var deathAnimation = [SKTexture]()
    internal var canSwim = true
    internal var airMeter: AirMeter
    
    let categoryBitmask:UInt32 = 0x1 << 0
    
    required init(node: SKSpriteNode) {
        airMeter = AirMeter(numberBubbles: numBubbles)
        spriteNode = node
        animation = createAnimation(atlasName: "DiveJivePlayer")
        deathAnimation = createAnimation(atlasName: "DiverDeath")
    }
    
    func getAir() -> Int{
        return airMeter.getNumBubbles()
    }
    
    func popBubble() -> Int {
        return airMeter.popBubble()
    }
    
    func shouldSwim() -> Bool{
        return canSwim;
    }
    
//actions
    
    func swimOn(){
        canSwim = true
    }
    func swimOff(){
        canSwim = false
    }
    //func toggleSwimming(){
   //     canSwim = !canSwim
    //}
    
    func playAnimation() {
        playAnimation(animation: animation)
    }
    
    func playAnimation(animation: [SKTexture]){ //TODO maybe clean this up and move it to a different file
        let animation = SKAction.animate(with: animation, timePerFrame: 0.1)
        //let runAnimationForever = SKAction.repeatForever(animation)
        spriteNode.run(animation)
    }
    
    func swim(){
        if(canSwim){
            self.getNode().physicsBody?.applyForce(CGVector(dx: 0, dy: -50))
            playAnimation()
        }
    }
    
    func die(){
        playAnimation(animation: deathAnimation)
    }
    
    func touchedWhale(){
        self.getNode().physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        self.getNode().physicsBody?.applyImpulse(CGVector(dx:0, dy: 5))
    }
    
    func touchedSquid(){
        
    }
    
    func touchedEel(){
        let pre = SKAction.run {
            self.getNode().physicsBody?.velocity = CGVector(dx: 0, dy: -50)
            self.canSwim = false
        }
        let pause = SKAction.wait(forDuration: 5)
        let post = SKAction.run {
            self.canSwim = true
        }
        let runEel = SKAction.sequence([pre, pause, post])
        self.spriteNode.run(runEel)
    }
    
    func touchedSwordfish(){
    
    }
}

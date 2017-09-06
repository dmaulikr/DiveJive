//
//  StartScene.swift
//  Dive Jive
//
//  Created by Conrad Oei on 7/8/17.
//  Copyright © 2017 Coleman. All rights reserved.
//

import SpriteKit
import GameplayKit

class StartScene: SKScene {
    private var jellyfish: Eels?
    private var blowfish: Swordfish?
    private var squid: Squid?
    private var whale: Whale?
    private var coin: Coin?
    private var sprites = [Sprite]()
    private var startText: SKLabelNode?
    
    override func didMove(to view: SKView) {
        jellyfish = Eels(node: self.childNode(withName: "jellyfish") as! SKSpriteNode)
        blowfish = Swordfish(node: self.childNode(withName: "blowfish") as! SKSpriteNode)
        squid = Squid(node: self.childNode(withName: "squid") as! SKSpriteNode)
        whale = Whale(node: self.childNode(withName: "whale") as! SKSpriteNode)
        whale?.spriteNode.xScale = 2
        whale?.spriteNode.yScale = 2
        coin = Coin(node: self.childNode(withName: "coin") as! SKSpriteNode)
        sprites.append(jellyfish!)
        sprites.append(blowfish!)
        sprites.append(squid!)
        sprites.append(whale!)
        sprites.append(coin!)
        for sprite in sprites {
            sprite.playAnimation()
        }
        
        startText = self.childNode(withName: "start") as? SKLabelNode
        EightBit.flash(node: startText!)
    }
    
    /* on tap */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let gameScene = GameScene(fileNamed: "GameScene")
        gameScene?.scaleMode = .aspectFill
        self.scene?.view?.presentScene(gameScene)
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        for sprite in sprites {
            sprite.getNode().texture?.filteringMode = .nearest
        }
    }
}

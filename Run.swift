//
//  Run.swift
//  Dive Jive
//
//  Created by Coleman Oei on 1/8/17.
//  Copyright © 2017 Coleman. All rights reserved.
//

import SpriteKit
import GameplayKit

class Run {
    //TODO maybe add the divers variable in here so then all of it's atributes are reset with a new run
    private var level: Int
    private var score: Int
    private let baseFloor:CGFloat = -100000000
    
    init(){
        level = 1
        score = 0
    }
    
    func resetRun (){
        level = 1
        score = 0
    }
    
    func nextLevel(){
        level += 1
    }
    
    func getFloorDepth() -> CGFloat{
        let ret = -(CGFloat(level) * baseFloor)
        return -(ret.squareRoot())
    }
    
    func getLevel() ->Int{
        return level
    }
    
    func getMaxCamDepth(frameHeight: CGFloat) -> CGFloat{
        return getFloorDepth() + (frameHeight/2)
    }
    
    func getNumMobs() -> Int{
        return Int(getFloorDepth() / CGFloat(-250))
    }
    
    func getNumCoins() -> Int{
        return Int(getFloorDepth() / CGFloat(-200))
    }
    
    func getScore() -> Int{
        return score
    }
    
    func coinCollected() {
        score += 100
    }
    
}

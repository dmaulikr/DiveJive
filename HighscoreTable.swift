//
//  HighscoreTable.swift
//  Dive Jive
//
//  Created by Coleman Oei on 7/19/17.
//  Copyright © 2017 Coleman. All rights reserved.
//

import SpriteKit
import GameplayKit

class HighscoreTable: SKScene {
    private var scores = [SKLabelNode]()
    private var names = [SKLabelNode]()
    
    override func didMove(to view: SKView) {
        for index in 0...((HighscoreTableModel.scoreTable.sortedScores().count) - 1) {
            let score = self.childNode(withName: "score\(index)") as? SKLabelNode
            score?.text = String(HighscoreTableModel.scoreTable.sortedScores()[index].score)
            
            let name = self.childNode(withName: "name\(index)") as? SKLabelNode
            name?.text = HighscoreTableModel.scoreTable.sortedScores()[index].name
        }
    }
    override func update(_ currentTime: TimeInterval) {
    }
}

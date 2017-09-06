//
//  HighscoreTableModel.swift
//  Dive Jive
//
//  Created by Coleman Oei on 7/19/17.
//  Copyright © 2017 Coleman. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class HighscoreTableModel {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    static let scoreTable = HighscoreTableModel()
    
    var highscores = [Score]()
    
    func saveScore(highscore: Int, name: String, level: Int) {
        let score = Score(context:context)
        score.score = Int64(highscore)
        score.level = Int16(level)
        score.name = name
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    func sortedScores() -> [Score] { //TODO probably inefficient to constantly sort
        do {
            highscores = try context.fetch(Score.fetchRequest())
        }catch {
            print("Error fetching data from CoreData")
        }
        return highscores.sorted(by: {$0.score > $1.score})
    }

}

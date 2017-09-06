//
//  GameScene.swift
//  Dive Jive
//
//  Created by Coleman Oei on 1/7/17.
//  Copyright © 2017 Coleman. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

/* bit masks used for detecting collisions */
struct BitMask {
    static let diver: UInt32 = 0x1 << 0
    static let whale: UInt32 = 0x1 << 1
    static let coin: UInt32 = 0x1 << 2
    static let eel: UInt32 = 0x1 << 3
    static let squid: UInt32 = 0x1 << 4
    static let swordfish: UInt32 = 0x1 << 5
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var diver: Diver?
    private var curFloor = SKSpriteNode()
    private var cam = SKCameraNode()
    private let motionManager = CMMotionManager()
    private var xAcceleration:CGFloat = 0
    private var curRun: Run?
    private var depth: CGFloat?
    private var mobsOnScreen = [Mob]()
    private var coins = [Coin]()
    private var air = [SKSpriteNode]()
    private var lives = [SKSpriteNode]()
    private var scoreLabel: SKLabelNode?
    private var playerLabel: SKLabelNode?
    private var gameOverBool: Bool?
    let ink = SKSpriteNode()
    let gameOverText = SKLabelNode()
    let font = "8bit"
    var isFirstTouch = true
    
    /* computed properties */
    var topScreen: CGFloat{
        get{
            return self.position.y + (self.size.height/2)
        }
    }
    
    var bottomScreen: CGFloat{
        get{
            return self.position.y - (self.size.height/2)
        }
    }
    
    var rightScreen: CGFloat{
        get{
            return self.position.x + (self.size.width/2)
        }
    }
    
    var leftScreen: CGFloat{
        get{
            return self.position.x - (self.size.width/2)
        }
    }
    
    /* moved to the games main view so do some set up */
    override func didMove(to view: SKView) {
        gameOverBool = false
        
        /* set up the camera */
        addChild(cam)
        camera = cam
        camera?.zPosition = 1
        
        diver = Diver(node: self.childNode(withName: "diver") as! SKSpriteNode) //create a diver associated with the game scene sprite
        curRun = Run()
        curFloor = self.childNode(withName: "floor") as! SKSpriteNode //associate the gamescene sprite and the sknode
        setUpScene(floor: curFloor) //set up the map
        self.physicsWorld.contactDelegate = self //assign the contact delegate for collisions
        
        setUpInk()
        setUpGameOver()
        setUpMeters()
        
        //motion init
        setUpMotionManager()
    }
    
    /* on tap */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        diver?.swim() //make the diver swim
        if(isFirstTouch){
            airCountdown()
            isFirstTouch = false
        }
    }
    
    //TODO what the fuck is this doing
    override func didSimulatePhysics() {
        diver?.getNode().position.x += xAcceleration * 40
        
        if (diver?.getNode().position.x)! < (-1 * CGFloat((self.size.width / 2))){
            diver?.getNode().position = CGPoint(x: (self.size.width / 2), y: (diver?.getNode().position.y)!)
        }else if(diver?.getNode().position.x)! > CGFloat(self.size.width / 2){
            diver?.getNode().position = CGPoint(x: -(self.size.width / 2), y: (diver?.getNode().position.y)!)
        }
    }
    
    /* called before each frame is rendered */
    override func update(_ currentTime: TimeInterval) {
        /* check if the diver is at the win depth yet */
        let winDepth: CGFloat = ((curRun?.getFloorDepth())! + (curFloor.size.height/2) + ((diver?.getNode().size.height)!/2))
        if (curRun?.getMaxCamDepth(frameHeight: self.size.height))!  - (curFloor.size.height/2) <= cam.position.y {
            cam.position.y = (diver?.getNode().position.y)! // update the camera to follow the player
        }
        else if (diver?.getNode().position.y)! <= winDepth{
            self.curRun?.nextLevel()
            setUpScene(floor: curFloor)
        }
        
        /* no anti aliasing on the divers texture */
        diver?.getNode().texture?.filteringMode = .nearest //find a better spot for this
        
        /* make the score label follow the camera */ //TODO take out the constants
        scoreLabel?.position = CGPoint(x: (scoreLabel?.position.x)!, y: cam.position.y + (topScreen - 100))
        playerLabel?.position = CGPoint(x: leftScreen + 100, y: cam.position.y + (topScreen - 100))
        
        for coin in coins{
            //iterate through all the coins
            coin.getNode().texture?.filteringMode = .nearest //no anti aliasing on coin textures
        }
        
        for bubble in air{
            bubble.texture?.filteringMode = .nearest
        }
        
        for life in lives{
            life.texture?.filteringMode = .nearest
        }
        
        for mob in mobsOnScreen{
            //iterate through all the mobs
            mob.getNode().texture?.filteringMode = .nearest //no anti aliasing on mob textures
            
            /* check if the mob is off the screen yet */
            if (mob.swimDirection < 0){
                if (mob.spriteNode.position.x < self.leftScreen){
                    replaceMob(mob: mob) //if it is then move it to another random spot
                }
            }
            else if (mob.swimDirection > 0){
                if (mob.spriteNode.position.x > self.rightScreen){
                    replaceMob(mob: mob) //if it is then move it to another random spot
                }
            }
        }
    }
    
    /* a collision happend */
    func didBegin(_ contact: SKPhysicsContact) {
        var diverBody: SKPhysicsBody
        var otherBody: SKPhysicsBody
        if (contact.bodyA.categoryBitMask == BitMask.diver) {
            diverBody = contact.bodyA
            otherBody = contact.bodyB
        }
        else {
            diverBody = contact.bodyB
            otherBody = contact.bodyA
            if (diverBody.categoryBitMask != BitMask.diver){
                print("DIVER BODY NOT CORRECT")
            }
        }
        switch (otherBody.categoryBitMask){
        case BitMask.coin:
            otherBody.node?.removeFromParent()
            addToScore()
            otherBody.categoryBitMask = 0 //TODO fix this very jank solution
        case BitMask.whale:
            diver?.touchedWhale()
        case BitMask.eel:
            print("touched jfish")
            diver?.touchedEel()
        case BitMask.squid:
            let inked = SKAction.run {
                self.ink.isHidden = false
            }
            let uninked = SKAction.run{
                self.ink.isHidden = true
            }
            let pause = SKAction.wait(forDuration: 5)
            let ranIntoSquid = SKAction.sequence([inked, pause, uninked])
            diver?.spriteNode.run(ranIntoSquid)
        case BitMask.swordfish:
            //otherBody.categoryBitMask = 0
            died()
            otherBody.categoryBitMask = 0 //TODO fix this very jank solution
        default:
            break
        }
        //otherBody.categoryBitMask = 0 //TODO fix this very jank solution
        
    }
    
//    func didEnd(_ contact: SKPhysicsContact) {
//        var diverBody: SKPhysicsBody
//        var otherBody: SKPhysicsBody
//        if (contact.bodyA.categoryBitMask == BitMask.diver) {
//            diverBody = contact.bodyA
//            otherBody = contact.bodyB
//        }
//        else {
//            diverBody = contact.bodyB
//            otherBody = contact.bodyA
//            if (diverBody.categoryBitMask != BitMask.diver){
//                print("DIVER BODY NOT CORRECT")
//            }
//        }
//        otherBody.categoryBitMask = BitMask.swordfish
//    }
    
/* helpers */
    
    /* set up functions */
    
    func setUpMeters(){
        //set up the black bg
        let blackBG = SKSpriteNode(color: UIColor.black, size: CGSize(width: self.size.width, height: 320))
        blackBG.position.y = topScreen - (blackBG.size.height/2)
        blackBG.zPosition = 1
        cam.addChild(blackBG)
        
        scoreLabel = self.childNode(withName: "score") as? SKLabelNode //associate the score label
        scoreLabel?.zPosition = 2
        
        playerLabel = self.childNode(withName: "1UP") as? SKLabelNode
        playerLabel?.zPosition = 2
        EightBit.flash(node: playerLabel!)
        
        setUpAir()
        setUpLives()
    }
    
    func setUpInk(){
        ink.size = self.size
        ink.position = CGPoint(x: 0, y: 0)
        ink.color = UIColor.black
        self.cam.addChild(ink)
        ink.isHidden = true
    }
    
    func setUpGameOver(){
        gameOverText.text = "Game Over"
        gameOverText.fontSize = 64
        gameOverText.fontName = font
        gameOverText.position = CGPoint(x: 0, y: 0)
        self.cam.addChild(gameOverText)
        gameOverText.isHidden = true
    }
    
    func setUpLives(){ //TODO probabbly put this stuff into a func so no copied code
        var lifePos = self.leftScreen + 75
        for _ in 1...3{ //TODO make a constant for the number of lives
            let life = SKSpriteNode(imageNamed: "diverLife")
            life.position = CGPoint(x: lifePos, y: ((playerLabel?.position.y)! - 150))
            life.xScale = 6
            life.yScale = 6
            lifePos += 55
            cam.addChild(life)
            lives.append(life)
            life.zPosition = 2
        }
    }
    
    func setUpAir(){
        var bubblePos = self.leftScreen + 75
        for _ in (air.count + 1)...(diver?.numBubbles)!{
            let bubble = SKSpriteNode(imageNamed: "bubble")
            bubble.position = CGPoint(x: bubblePos, y: ((playerLabel?.position.y)! - 75))
            bubble.xScale = 6
            bubble.yScale = 6
            bubblePos += 55
            cam.addChild(bubble)
            air.append(bubble)
            bubble.zPosition = 2
        }
    }
    
    func setUpScene(floor: SKSpriteNode){
        depth = (curRun?.getFloorDepth())!
        floor.position.y = depth! - (floor.size.height/2)
        floor.size.width = self.size.width
        diver?.getNode().position = CGPoint(x: 0, y: 0)
        //TODO clean this up
        diver?.getNode().physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        diver?.getNode().physicsBody?.categoryBitMask = BitMask.diver
        diver?.getNode().physicsBody?.collisionBitMask = 0
        diver?.getNode().physicsBody?.contactTestBitMask = BitMask.coin
        diver?.getNode().physicsBody?.usesPreciseCollisionDetection = true
        for mob in mobsOnScreen {
            mob.getNode().removeFromParent()
        }
        mobsOnScreen = [Mob]()
        placeMobs()
        for coin in coins {
            coin.getNode().removeFromParent()
        }
        coins = [Coin]()
        placeCoins()
        for coin in coins{
            coin.playAnimation()
        }
        resetBubbles()
    }
    
    /* set up the motion manager */
    func setUpMotionManager(){
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) {(data: CMAccelerometerData?, error: Error?) in
            if(self.diver?.shouldSwim())!{
                //diver not frozen
                if let accelerometerData = data {
                    let acceleration = accelerometerData.acceleration
                    self.xAcceleration = CGFloat(acceleration.x) * 0.75 + self.xAcceleration * 0.25
                }
            }
            else{
                //diver is frozen
                self.xAcceleration = 0
            }
        }
    }
    
/* end of set up functions */
    
    func died(){
        diver?.die()
        if(lives.count > 0){
            restartLevel()
        }else{
            gameOver()
        }
    }
    
    func restartLevel(){
        let prep = SKAction.run {
            self.diver?.swimOff()
            //self.diver?.toggleSwimming()
            self.diver?.getNode().physicsBody?.pinned = true
        }
        let pause = SKAction.wait(forDuration: 5)
        let restartLevel = SKAction.run {
            self.diver?.spriteNode.position.x = 0
            self.diver?.spriteNode.position.y = 0
            self.diver?.getNode().physicsBody?.pinned = false
            //self.diver?.toggleSwimming()
            self.diver?.swimOn()
            self.resetBubbles()
            let life = self.lives.remove(at: self.lives.count-1)
            life.removeFromParent()
        }
        let run = SKAction.sequence([prep, pause, restartLevel])
        self.run(run)
    }
    
    func airCountdown(){
        let pause = SKAction.wait(forDuration: 5)
        let popBubble = SKAction.run {
            for (index, bubble) in self.air.reversed().enumerated() {
                if !bubble.isHidden {
                    bubble.isHidden = true
                    print(index)
                    if index == (self.air.count - 1) {
                        print("reached 0")
                        self.died()
                    }
                    break
                }
            }
        }
        let run = SKAction.sequence([pause, popBubble])
        let repeatRun = SKAction.repeatForever(run)
        //let repeatRun = SKAction.repeat(run, count: air.count)
        self.run(repeatRun)
    }
    
    func gameOver(){
        if(!(gameOverBool)!){
            let displayGameOver = SKAction.run {
                //display game over text
                self.gameOverText.isHidden = false
                //freeze the player
                self.diver?.getNode().physicsBody?.pinned = true
                self.diver?.swimOff()
                //self.diver?.toggleSwimming()
            }
            let pause = SKAction.wait(forDuration: 5)
            let restartGame = SKAction.run {
                let finalScore = self.curRun?.getScore()
                var scores = HighscoreTableModel.scoreTable.sortedScores()
                if scores.count > 0 {
                    let highscore = scores[scores.count - 1].score
                    if finalScore! > Int(highscore) {
                        HighscoreTableModel.scoreTable.saveScore(highscore: finalScore!, name: "bob", level: self.curRun!.getLevel())
                    }
                }else{
                    HighscoreTableModel.scoreTable.saveScore(highscore: finalScore!, name: "bob", level: self.curRun!.getLevel())
                }
                scores = HighscoreTableModel.scoreTable.sortedScores()
                let highscoreScene = SKScene(fileNamed: "HighscoreTable")
                highscoreScene?.scaleMode = .aspectFill
                self.scene?.view?.presentScene(highscoreScene)
                for score in scores {
                    print(score)
                }
                //let gameScene = GameScene(fileNamed: "GameScene")
                //gameScene?.scaleMode = .aspectFill
                //self.scene?.view?.presentScene(gameScene)
            }
            let run = SKAction.sequence([displayGameOver, pause, restartGame])
            self.run(run)
            
        }
        
    }
    
    func resetBubbles(){
        for bubble in air{
            bubble.isHidden = false
        }
    }
    
    /* add to the score and update the label */
    func addToScore(){
        curRun?.coinCollected()
            refreshScoreLabel()
    }
    
    func refreshScoreLabel(){
        if let score = curRun?.getScore() {
            scoreLabel?.text = String(score)
        }
    }
    
    /* place all the mobs in random spots */
    func placeMobs() {
        if let numMobsOnScreen = curRun?.getNumMobs() {
            for _ in 0...numMobsOnScreen {
                let randomMob = getRandomMob()
                addMob(mob: randomMob)
                mobsOnScreen.append(randomMob)
            }
        }
    }
    
    /* place all the coins in random spots */
    func placeCoins(){
        if let numCoins = curRun?.getNumCoins(){
            for _ in 0...numCoins{
                let coin = Coin(node: SKSpriteNode(imageNamed: "Coin1"))
                coin.getNode().position = getRandPos()
                coin.getNode().physicsBody = SKPhysicsBody(texture: coin.spriteNode.texture!, alphaThreshold: 0, size: coin.getNode().size)
                coin.getNode().physicsBody?.affectedByGravity = false
                coin.getNode().physicsBody?.categoryBitMask = BitMask.coin
                coin.getNode().physicsBody?.collisionBitMask = 0
                coin.getNode().physicsBody?.contactTestBitMask = BitMask.diver
                coin.getNode().physicsBody?.usesPreciseCollisionDetection = true
                self.addChild(coin.getNode())
                coins.append(coin)
            }
        }
    }
    
    /* randomly pick a type of mob */
    func getRandomMob() -> Mob{
        //TODO maybe clean this up so dont have to add to this everytime you add a mob
        let ranNum = arc4random_uniform(100)
        if ranNum <= 10 {
            return Swordfish(node: SKSpriteNode(imageNamed: "Swordfish1"))
        }else if ranNum <= 20 {
            return Whale(node: SKSpriteNode(imageNamed: "Whale1"))
        }else if ranNum <= 60{
            return Eels(node: SKSpriteNode(imageNamed: "Eels1"))
        }else {
            return Squid(node: SKSpriteNode(imageNamed: "Squid1"))
        }
    }
    
    /* add a new mob to the scene */
    func addMob(mob:Mob){
        placeMob(mob: mob)
        self.addChild(mob.getNode())
        mob.spriteNode.xScale = (CGFloat(6 * -1 * mob.swimDirection)) //TODO fix this
        mob.swim()
    }
    
    /* place the mob anywhere random */
    func placeMob(mob: Mob){
        let yPos:CGFloat = -1 * (CGFloat(arc4random_uniform(UInt32(-1 * depth!-600))) + 100) //TODO maybe change this to a func
        let xPos:CGFloat = CGFloat((arc4random_uniform(UInt32(self.size.width)))) - CGFloat(self.size.width/2)
        mob.getNode().position = CGPoint(x: xPos, y: yPos)
    }
    
    /* place the mob at a random height offscreen */
    func replaceMob(mob: Mob){
        let yPos:CGFloat = -1 * (CGFloat(arc4random_uniform(UInt32(-1 * depth!-600))) + 100) //TODO
        let xPos:CGFloat = self.size.width * CGFloat(mob.swimDirection) * -1 //TODO: fix this messy ass shit
        mob.getNode().position = CGPoint(x: xPos, y: yPos)
    }
    
    /* get a random position to place a mob at */
    func getRandPos()->CGPoint{
        let xPos:CGFloat = CGFloat((arc4random_uniform(UInt32(self.size.width)))) - CGFloat(self.size.width/2)
        let yPos:CGFloat = -1 * CGFloat(arc4random_uniform(UInt32(-1 * depth!))) //TODO
        return CGPoint(x: xPos, y: yPos)
    }
}

//
//  LoadingScene.swift
//  NewGame
//
//  Created by CHANG JIN LEE on 2023/03/20.
//

import Foundation

import SpriteKit

class LoadingScene: SKScene {
    
    var background = SKSpriteNode()
    
    let playBtn = "start-button"
    let titleImage = "player"
    
    override func didMove(to view: SKView) {
        
        
        setUpBackground()
        addcrawlingPlayer()
        addplayBtn()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let location = touch?.location(in: self) {
            let nodesArray = self.nodes(at: location)
            if nodesArray.first?.name == self.playBtn {
                let scene = GameScene(size: self.size)
                //                scene.background = self.background
                scene.scaleMode = .resizeFill
                self.view?.presentScene(scene)
            }
        }
    }
    
    func setUpBackground(){
        let images = [
            UIImage(named: "background 1")!,
            UIImage(named: "background 2")!,
            UIImage(named: "background 3")!,
            UIImage(named: "background 4")!
        ]
        let scroller = InfiniteScrollingBackground(images: images,
                                                   scene: self,
                                                   scrollDirection: .bottom,
                                                   transitionSpeed: 3)
        
        scroller?.scroll()
        scroller?.zPosition = -1
    }
    
    func addplayBtn(){
        let playBtn = SKSpriteNode(imageNamed: self.playBtn)
        playBtn.name = self.playBtn
        playBtn.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.3)
        playBtn.zPosition = 1
        self.addChild(playBtn)
    }
    
    
    func addcrawlingPlayer(){
        
        let titleLabel = SKSpriteNode(imageNamed: self.titleImage)
        titleLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.6)
        titleLabel.zPosition = 1
        self.addChild(titleLabel)
        
//        let actionMove = SKAction.move(to: CGPoint(x: calc_position_x(T: actualX), y: destY),
//                                       duration: TimeInterval(actualDuration))
//        let actionMoveDone = SKAction.removeFromParent()
//        titleLabel.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
}

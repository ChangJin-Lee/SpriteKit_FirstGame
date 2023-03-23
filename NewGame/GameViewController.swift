//
//  GameViewController.swift
//  NewGame
//
//  Created by CHANG JIN LEE on 2023/03/16.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
//
            let scene = LoadingScene(size: view.bounds.size)
            scene.scaleMode = .resizeFill
            view.presentScene(scene)
            
//            if let scene = SKScene(fileNamed: "GameScene") {
////            if let scene = SKScene(size: view.bounds.size) {
//                // Set the scale mode to scale to fit the window
//                scene.scaleMode = .resizeFill
//
//                // Present the scene
//                view.presentScene(scene)
//            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
}

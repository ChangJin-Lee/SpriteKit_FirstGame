//
//  GameScene.swift
//  NewGame
//
//  Created by CHANG JIN LEE on 2023/03/16.
//

import Foundation
import SpriteKit
import GameplayKit
import SwiftUI
import GameController


struct PhysicsCategory {
    static let none      : UInt32 = 0
    static let all       : UInt32 = UInt32.max
    static let monster   : UInt32 = 0b1       // 1
    static let projectile: UInt32 = 0b10      // 2
}



func +(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func *(point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func /(point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
func sqrt(a: CGFloat) -> CGFloat {
    return CGFloat(sqrtf(Float(a)))
}
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    let player = SKSpriteNode(imageNamed: "player")
    var background1 = SKSpriteNode(imageNamed: "background 1")
    var background2 = SKSpriteNode(imageNamed: "background 2")
    var background3 = SKSpriteNode(imageNamed: "background 3")
    var background4 = SKSpriteNode(imageNamed: "background 4")
    
    let joystick = SKShapeNode(circleOfRadius: 50)
    
    var virtualController: GCVirtualController?
    var playerPosx : CGFloat = 0
    var playerPosy : CGFloat = 0
    var projectile_dict: [Int : String] = [ 0 : "egg",
                                            1 : "projectile"]
    var projectileSelector : Int = 0
    
    override func didMove(to view: SKView) {
        
        addPlayer()
//        addjoystick()
        setUpBackground()
        
        // collision detection
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        runforever()
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        
        let projectile = SKSpriteNode(imageNamed: projectile_dict[projectileSelector]!)
        projectile.position = player.position
        projectile.color = .white
        
        let offset = touchLocation - projectile.position
        
        // Bail out if you are shooting down or backwards
        //      if offset.x < 0 { return }
        
        addChild(projectile)
        
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.isDynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.monster
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.none
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        let direction = offset.normalized()
        
        let shootAmount = direction * 1000
        
        let realDest = shootAmount + projectile.position
        
        let actionMove = SKAction.move(to: realDest, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        projectile.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    private func addPlayer(){
        // background color
        backgroundColor = SKColor.white
        
        player.position = CGPoint(x: size.width / 2, y: size.height / 2)
        
        dump(size)
        
        
        player.zPosition = 1
        
        addChild(player)
        
        connectVirtuellController()
        
    }
    
    
    
    func random_CGFloat() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random_min_to_max(min: CGFloat, max: CGFloat) -> CGFloat {
        return random_CGFloat() * (max - min) + min
    }
    
    func random_x_or_y(x: CGFloat, y: CGFloat) -> CGFloat{
        return arc4random_uniform(2) == 0 ? x : y
    }
    
    func calc_position_x(T: CGFloat) -> CGFloat {
        return T > 0 ? -size.width : size.width
    }
    
    func addMonster() {
        
        // Create sprite
        let monster = SKSpriteNode(imageNamed: "monster")
        
        // Determine where to spawn the monster along the Y axis
        let actualY = random_min_to_max(min: -size.height, max: size.height)
        let destY = random_min_to_max(min: -size.height, max: size.height)
        
        let actualX = random_x_or_y(x: -size.width, y: size.width)
        
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        monster.position = CGPoint(x: actualX, y: actualY)
        
        
        let mul_factor = random_min_to_max(min: 1, max: 3)
        
        let newSize = CGSize(width: monster.size.width * mul_factor, height: monster.size.height * mul_factor)
        monster.size = newSize
        
        monster.zPosition = 1
        
        // Add the monster to the scene
        addChild(monster)
        
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size) // 1
        monster.physicsBody?.isDynamic = true // 2
        monster.physicsBody?.categoryBitMask = PhysicsCategory.monster // 3
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.projectile // 4
        monster.physicsBody?.collisionBitMask = PhysicsCategory.none // 5
        
        // Determine speed of the monster
        let actualDuration = random_min_to_max(min: CGFloat(1.0), max: CGFloat(5.0))
        
        // Create the actions
        let actionMove = SKAction.move(to: CGPoint(x: calc_position_x(T: actualX), y: destY),
                                       duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        monster.run(SKAction.sequence([actionMove, actionMoveDone]))
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
    
    
    func projectileDidCollideWithMonster(projectile: SKSpriteNode, monster: SKSpriteNode) {
        print("Hit")
        projectile.removeFromParent()
        monster.removeFromParent()
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        collisiondetection(contact)
    }
    
    override func update(_ currentTime: TimeInterval) {
        playerPosx = CGFloat ( (virtualController?.controller?.extendedGamepad?.leftThumbstick.xAxis.value)!)
        playerPosy = CGFloat ( (virtualController?.controller?.extendedGamepad?.leftThumbstick.yAxis.value)!)
        if playerPosx >= 0.5 {
            player.position.x += 3
        }
        if playerPosx <= -0.5 {
            player.position.x -= 3
        }
        
        if playerPosy >= 0.5 {
            player.position.y += 3
        }
        if playerPosy <= -0.5 {
            player.position.y -= 3
        }
        
        if virtualController?.controller?.extendedGamepad?.buttonB.isTouched == true{
            projectileSelector = 1
        }
        if virtualController?.controller?.extendedGamepad?.buttonA.isTouched == true{
            projectileSelector = 0
        }
        
        print(virtualController?.controller?.extendedGamepad?.buttonB.isTouched)
        print(projectileSelector)
    }
    func connectVirtuellController(){
        let controllerConfic = GCVirtualController.Configuration()
        controllerConfic.elements = [GCInputLeftThumbstick, GCInputButtonA, GCInputButtonB]
        
        
        let controller = GCVirtualController(configuration: controllerConfic)
        
        controller.updateConfiguration(forElement: GCInputButtonA, configuration: { _ in
          let starPath = GCVirtualController.ElementConfiguration()
            
            let offX = -25.0
            let offY = -26.0
            starPath.path = UIBezierPath()
            starPath.path!.move(to: CGPoint(x: 25+offX, y: 1+offY))
            starPath.path!.addLine(to: CGPoint(x: 33.82+offX, y: 13.86+offY))
            starPath.path!.addLine(to: CGPoint(x: 48.78+offX, y: 18.27+offY))
            starPath.path!.addLine(to: CGPoint(x: 39.27+offX, y: 30.64+offY))
            starPath.path!.addLine(to: CGPoint(x: 39.69+offX, y: 46.23+offY))
            starPath.path!.addLine(to: CGPoint(x: 25+offX, y: 41+offY))
            starPath.path!.addLine(to: CGPoint(x: 10.31+offX, y: 46.23+offY))
            starPath.path!.addLine(to: CGPoint(x: 10.73+offX, y: 30.64+offY))
            starPath.path!.addLine(to: CGPoint(x: 1.22+offX, y: 18.27+offY))
            starPath.path!.addLine(to: CGPoint(x: 16.18+offX, y: 13.86+offY))
            starPath.path!.close()
            UIColor.blue.setFill()
            starPath.path!.fill()
            

          return starPath
        })
        
        controller.updateConfiguration(forElement: GCInputButtonB, configuration: { _ in
          let starPath = GCVirtualController.ElementConfiguration()
            
            let offX = -25.0
            let offY = -26.0
            starPath.path = UIBezierPath()
            starPath.path!.move(to: CGPoint(x: 25+offX, y: 1+offY))
            starPath.path!.addLine(to: CGPoint(x: 33.82+offX, y: 13.86+offY))
            starPath.path!.addLine(to: CGPoint(x: 48.78+offX, y: 18.27+offY))
            starPath.path!.addLine(to: CGPoint(x: 39.27+offX, y: 30.64+offY))
            starPath.path!.addLine(to: CGPoint(x: 39.69+offX, y: 46.23+offY))
            starPath.path!.addLine(to: CGPoint(x: 25+offX, y: 41+offY))
            starPath.path!.addLine(to: CGPoint(x: 10.31+offX, y: 46.23+offY))
            starPath.path!.addLine(to: CGPoint(x: 10.73+offX, y: 30.64+offY))
            starPath.path!.addLine(to: CGPoint(x: 1.22+offX, y: 18.27+offY))
            starPath.path!.addLine(to: CGPoint(x: 16.18+offX, y: 13.86+offY))
            starPath.path!.close()
            UIColor.red.setFill()
            starPath.path!.fill()
            

          return starPath
        })
        
        
//        controller.position(x: UIScene.main.bounds.width / 2, y: UIScene.main.bounds.height / 2)
        controller.connect()
        virtualController = controller
    }
    
    func collisiondetection(_ contact: SKPhysicsContact){
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.monster != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.projectile != 0)) {
            if let monster = firstBody.node as? SKSpriteNode,
               let projectile = secondBody.node as? SKSpriteNode {
                projectileDidCollideWithMonster(projectile: projectile, monster: monster)
            }
        }
    }
    
    
    func runforever(){
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addMonster),
                SKAction.wait(forDuration: 0.25)
            ])
        ))
    }
    
}

//
//  GameScene.swift
//  NewGame
//
//  Created by CHANG JIN LEE on 2023/03/16.
//

import SpriteKit
import GameplayKit


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
    
    override func didMove(to view: SKView) {
        
        
        addPlayer()
        addjoystick()
        setUpBackground()
        
        // collision detection
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        runforever()
    }
    
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for touch in touches {
//                let location = touch.location(in: self)
//                let node = self.atPoint(location)
//                if node == joystick {
//                    let dx = location.x - joystick.position.x
//                    let dy = location.y - joystick.position.y
//                    let angle = atan2(dy, dx)
//                    let distance = joystick.size.width / 2
//                    let offsetX = distance * cos(angle)
//                    let offsetY = distance * sin(angle)
//                    let newPosition = CGPoint(x: joystick.position.x + offsetX, y: joystick.position.y + offsetY)
//                    player.position = newPosition
//                }
//            }
//    }
    
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        
        let projectile = SKSpriteNode(imageNamed: "egg")
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
        
//        for touch in touches {
//                let location = touch.location(in: self)
//                let node = self.atPoint(location)
//                if node == joystick {
//                    let move = SKAction.move(to: player.position, duration: 0.2)
//                    player.run(move)
//                }
//            }
    }
//
//    override func update(_ currentTime: TimeInterval) {
//        let dx = joystick.position.x - player.position.x
//        let dy = joystick.position.y - player.position.y
//        let distance = sqrt(dx*dx + dy*dy)
//        if distance > joystick.size.width / 2 {
//            let angle = atan2(dy, dx)
//            let offsetX = joystick.size.width / 2 * cos(angle)
//            let offsetY = joystick.size.width / 2 * sin(angle)
//            joystick.position = CGPoint(x: player.position.x + offsetX, y: player.position.y + offsetY)
//        }
//    }
//
    
    private func addPlayer(){
        // background color
        backgroundColor = SKColor.white
        
        player.position = CGPoint(x: size.width / 2, y: size.height / 2)
        
        dump(size)
        
        
        player.zPosition = 1
        
        addChild(player)
        
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
    
    
    func addjoystick(){
        joystick.strokeColor = .white
        joystick.fillColor = .gray
        joystick.alpha = 0.5
        joystick.position = CGPoint(x: joystick.frame.width / 2 + 30, y: joystick.frame.height / 2 + 30)
        addChild(joystick)
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

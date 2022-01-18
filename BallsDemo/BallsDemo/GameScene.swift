//
//  GameScene.swift
//  BallsDemo
//
//  Created by shenjie on 2022/1/14.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private let nodeName = "hello"
    private var spinnyNode : SKShapeNode!
    private var lastTouch: CGPoint? = nil
    private var selected: Bool = false
    
    let BallCategory   : UInt32 = 0x1 << 0
    let BorderCategory : UInt32 = 0x1 << 4
    
    var ball = SKSpriteNode()
    
    override func sceneDidLoad() {
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        self.spinnyNode.name = nodeName
        self.spinnyNode.lineWidth = 2.5
        self.spinnyNode?.position = CGPoint(x: 100.0, y: 100.0)
    }
    
    override func didMove(to view: SKView) {
        
        let screenBorder = SKPhysicsBody(edgeLoopFrom: self.frame)
        screenBorder.friction = 0 /// So doesn't slow down the objects that collide
        screenBorder.restitution = 1 /// So the ball bounces when hitting the screen borders
        self.physicsBody = screenBorder
        
        ball = self.childNode(withName: "ball") as! SKSpriteNode
        ball.physicsBody?.applyImpulse(CGVector(dx: 100, dy: 100))
        
//        if let spinnyNode = self.spinnyNode {
//            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
//        }
        
        // 边界碰撞
//        let screenBorder = SKPhysicsBody(edgeLoopFrom: self.frame)
////        screenBorder.friction = 0
////        screenBorder.restitution = 1
//        self.physicsBody = screenBorder
//        self.physicsBody?.categoryBitMask = BorderCategory
//
//        // 给球添加推力
//        let ball = self.childNode(withName: "ball") as! SKSpriteNode
//        ball.physicsBody?.affectedByGravity = false
//        ball.physicsBody?.categoryBitMask = BallCategory
//        ball.physicsBody?.contactTestBitMask = BorderCategory
//        ball.physicsBody?.collisionBitMask = BorderCategory
//        ball.physicsBody?.restitution = 1.0
//        ball.physicsBody?.friction = 0
//        ball.physicsBody?.linearDamping = 0
//        ball.physicsBody?.angularDamping = 0
//
//        ball.physicsBody?.applyImpulse(CGVector(dx: 50, dy: 50))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let position = t.location(in: self)
            lastTouch = position
            if selectedNodeForTouch(touchLocation: position) {
                self.selected = true
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let position = t.location(in: self)
            lastTouch = position
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouch = nil
        self.selected = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouch = nil
        self.selected = false
    }
    
    
    override func update(_ currentTime: TimeInterval) {
//        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
//        if ball.position.y <= self.frame.minY{
//            ball.physicsBody?.applyImpulse(CGVector(dx: 20 * (-1), dy: 20 * (-1)))
//        }
//        else if ball.position.y >= self.frame.maxY {
//            ball.physicsBody?.applyImpulse(CGVector(dx: 20, dy: 20))
//        } else if
    }
    
    func selectedNodeForTouch(touchLocation: CGPoint) -> Bool{
        let touchedNode = self.atPoint(touchLocation)
        if touchedNode is SKShapeNode {
            if self.spinnyNode.isEqual(to: touchedNode) {
                if touchedNode.name == nodeName {
                    return true
                }
            }
        }
        return false
    }
    
    func randomFloat(from:CGFloat, to:CGFloat) -> CGFloat {
      let rand:CGFloat = CGFloat(Float(arc4random()) / 0xFFFFFFFF)
      return (rand) * (to - from) + from
    }
    
    func randomDirection() -> CGFloat {
        let speedFactor: CGFloat = 3.0
        if self.randomFloat(from: 0.0, to: 100.0) >= 50 {
          return -speedFactor
        } else {
          return speedFactor
        }
      }
}

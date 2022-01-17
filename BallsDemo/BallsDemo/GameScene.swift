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
    private var nodeTouch: UITouch?
    
    override func sceneDidLoad() {
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        self.spinnyNode.name = nodeName
        self.spinnyNode.lineWidth = 2.5
        self.spinnyNode?.position = CGPoint(x: 100.0, y: 100.0)
        
    }
    
    override func didMove(to view: SKView) {
//        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("handlePanFrom:"))
//        self.view?.addGestureRecognizer(gestureRecognizer)
        
        self.addChild(self.spinnyNode)
        if let spinnyNode = self.spinnyNode {
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
        }
    }
    
    func touchDown(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.green
//            n.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
//                                              SKAction.fadeOut(withDuration: 0.5),
//                                              SKAction.removeFromParent()]))
//            self.addChild(n)
//        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            self.spinnyNode.position = pos
//            n.strokeColor = SKColor.blue
//            n.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
//                                              SKAction.fadeOut(withDuration: 0.5),
//                                              SKAction.removeFromParent()]))
//            self.addChild(n)
//        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            self.spinnyNode.position = pos
//            n.strokeColor = SKColor.red
//            n.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
//                                              SKAction.fadeOut(withDuration: 0.5),
//                                              SKAction.removeFromParent()]))
//
//            self.addChild(n)
//        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let position = t.location(in: self)
            if selectedNodeForTouch(touchLocation: position) {
//                nodeTouch = t
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.spinnyNode.removeAllActions()
//            if nodeTouch != nil {
//                if t as UITouch == nodeTouch! {
//                    let position = t.location(in: self)
//                    let node = self.atPoint(position)
//                    node.position = position
//                }
//            }
            let position = t.location(in: self)
            if selectedNodeForTouch(touchLocation: position) {
//                self.touchMoved(toPoint: t.location(in: self))
                self.spinnyNode.position = position
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let position = t.location(in: self)
            if selectedNodeForTouch(touchLocation: position) {
//                self.touchUp(atPoint: t.location(in: self))
                self.spinnyNode.position = position
                self.spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches {
//            self.touchUp(atPoint: t.location(in: self))
//
//        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
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
    
//    func handlePanFrom(recognizer: UIPanGestureRecognizer) {
//        if recognizer.state == .began {
//            var touchPosition = recognizer.location(in: recognizer.view)
//            self.covert()
//
//        } else if recognizer.state == .changed {
//
//
//        } else if recognizer.state == .ended {
//
//
//        }
//
//    }
    
}

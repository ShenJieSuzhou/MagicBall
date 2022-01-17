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
    
    override func sceneDidLoad() {
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        self.spinnyNode.name = nodeName
        self.spinnyNode.lineWidth = 2.5
        self.spinnyNode?.position = CGPoint(x: 100.0, y: 100.0)
    }
    
    override func didMove(to view: SKView) {
        self.addChild(self.spinnyNode)
        if let spinnyNode = self.spinnyNode {
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
        }
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
        // Called before each frame is rendered
        if let touch = lastTouch {
            if self.selected {
                self.spinnyNode.position = touch
            }
        }
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
}

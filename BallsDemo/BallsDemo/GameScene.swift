//
//  GameScene.swift
//  BallsDemo
//
//  Created by shenjie on 2022/1/14.
//

import SpriteKit
import GameplayKit

struct uMsg {
    var type: Int
    var x: Int
    var y: Int
    var z: Int
}


class GameScene: SKScene {
    private var lastTouch: CGPoint? = nil
    private var selected: Bool = false
    private var joinButton: SKSpriteNode!
    private var connectButton: SKSpriteNode!
    private var nodeArray: [SKSpriteNode] = []
    private var clientSocket: OKNetManager!
    
    let BallCategory   : UInt32 = 0x1 << 0
    let BorderCategory : UInt32 = 0x1 << 4
    
    let host: String = "10.200.22.126"
    let port: UInt16 = 5555
    
    var ball = SKSpriteNode()
    let colors = [UIColor.red, UIColor.green, UIColor.blue, UIColor.brown, UIColor.cyan, UIColor.orange]
    
    let nodeNames = ["qq", "ww", "ss", "rr", "tt", "yy", "uu"]
    var count = 0
    
    override func didMove(to view: SKView) {
        
        self.clientSocket = OKNetManager()
        self.clientSocket.delegate = self
        
        // 添加按钮
        joinButton = self.childNode(withName: "JoinButton") as? SKSpriteNode
        joinButton?.isUserInteractionEnabled = true
        connectButton = self.childNode(withName: "ConnectButton") as? SKSpriteNode
        connectButton.isUserInteractionEnabled = true
        
        // 边界碰撞
        let screenBorder = SKPhysicsBody(edgeLoopFrom: self.frame)
        screenBorder.friction = 0 /// So doesn't slow down the objects that collide
        screenBorder.restitution = 1 /// So the ball bounces when hitting the screen borders
        self.physicsBody = screenBorder
        
        ball = self.childNode(withName: "ball") as! SKSpriteNode
        ball.physicsBody?.applyImpulse(CGVector(dx: 100, dy: 100))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let position = t.location(in: self)
            lastTouch = position
//            if selectedNodeForTouch(touchLocation: position) {
//                self.selected = true
//            }
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
        
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            
            if self.connectButton.contains(location) {
                self.clientSocket.connect(host: host, port: port)
                
            } else if self.joinButton.contains(location){
                print("+++++++++ generate new node +++++++++")
                let random = Int(arc4random_uniform(UInt32(self.colors.count)))
                count = count + 1
                if count > 10 {
                    return
                }
                if generateNewSpriteNode(id: String(count), name: String(count), color: colors[random]) {
                    
                }
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouch = nil
        self.selected = false
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        //print("position: x = \(self.ball.position.x)  y = \(self.ball.position.y)")
        // socket 发送坐标
    }
    
    
    
    /// 生成新的节点
    /// - Parameters:
    ///   - id: 标识
    ///   - name: 名称
    ///   - color: 颜色
    /// - Returns: 是否成功
    func generateNewSpriteNode(id: String, name: String, color: UIColor) -> Bool{
        let node = SKSpriteNode(color: color, size: CGSize(width: 30, height: 30))
        node.name = id
        node.position = CGPoint(x: -100, y: 100)
        node.physicsBody = SKPhysicsBody(circleOfRadius: 30)
        node.physicsBody?.isDynamic = true
        node.physicsBody?.restitution = 1
        
        let fire = SKEmitterNode(fileNamed: "Fire")
        fire?.targetNode = self
        fire?.particleColorBlendFactor = 1.0
        fire?.particleColorSequence = nil
        fire?.particleColor = color
        node.addChild(fire!)
        
        self.addChild(node)
        nodeArray.append(node)
        
        node.physicsBody?.applyImpulse(CGVector(dx: 100, dy: 50))
        return true
    }
    
//    func selectedNodeForTouch(touchLocation: CGPoint) -> Bool{
//        let touchedNode = self.atPoint(touchLocation)
//        if touchedNode is SKShapeNode {
//            if self.spinnyNode.isEqual(to: touchedNode) {
//                if touchedNode.name == nodeName {
//                    return true
//                }
//            }
//        }
//        return false
//    }
//
//    func randomFloat(from:CGFloat, to:CGFloat) -> CGFloat {
//      let rand:CGFloat = CGFloat(Float(arc4random()) / 0xFFFFFFFF)
//      return (rand) * (to - from) + from
//    }
//
//    func randomDirection() -> CGFloat {
//        let speedFactor: CGFloat = 3.0
//        if self.randomFloat(from: 0.0, to: 100.0) >= 50 {
//          return -speedFactor
//        } else {
//          return speedFactor
//        }
//      }
}

extension GameScene: OKNetManagerDelegate {

    func connectSuccess() {
        
    }
    
    
    func connectFailed() {
        
    }
    
    // 根据哈希表得到对应的线程更新坐标
    func updateWithPosition(pos: CGPoint) {
        
    }
    
    // 新开一个线程并加入哈希表
    func newClientJoinIn() {
        
    }
    
    // 客户端离开
    func clientLeave() {
        
    }
}

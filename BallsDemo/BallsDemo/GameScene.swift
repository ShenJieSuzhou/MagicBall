//
//  GameScene.swift
//  BallsDemo
//
//  Created by shenjie on 2022/1/14.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    // 客户端唯一ID
    private var uuid: Int32?
    // 名称
    private var account: String?
    
    private var lastTouch: CGPoint? = nil
    private var selected: Bool = false
    private var joinButton: SKSpriteNode!
    private var connectButton: SKSpriteNode!
    private var nodeArray: [SKSpriteNode] = []
    
    
    let BallCategory   : UInt32 = 0x1 << 0
    let BorderCategory : UInt32 = 0x1 << 4
    
    var ball = SKSpriteNode()
    let colors = [UIColor.red, UIColor.green, UIColor.blue, UIColor.brown, UIColor.cyan, UIColor.orange]
    
    let nodeNames = ["qq", "ww", "ss", "rr", "tt", "yy", "uu"]
    var count = 0
    
    override func didMove(to view: SKView) {
        // State 回调
        
        self.account = "zhangsan"
        
        OKNetManager.sharedManager.stateDelegate = self
        
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
                OKNetManager.sharedManager.disconnect()
                
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
        if nodeArray.count == 0 {
            return
        }
        let node = nodeArray.first!
        print("position: x = \(node.position.x)  y = \(node.position.y)")
        
        // socket 发送坐标
        self.sendPositionToFriends(x: node.position.x, y: node.position.y)
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
    
    // 给服务器发送坐标信息
    func sendPositionToFriends(x: CGFloat, y: CGFloat) -> Void {
        // 消息结构如下
        // 包长度           totalLength
        // 消息类型         type
        // 唯一ID          uuid
        // 玩家名称长度      nameLen
        // 玩家名称         account
        // x 坐标          xPos
        // y 坐标          yPos
        
        // 发送数据缓存
        var sendData: [UInt8] = [UInt8]()
             
        var type = UInt32(201)
        let typeData = Data(bytes: &type, count: MemoryLayout<UInt32>.stride)
        
        var uuid = UInt32(12345)
        let uuidData = Data(bytes: &uuid, count: MemoryLayout<UInt32>.stride)
        
        var nameLen = UInt32(self.account!.count)
        let nameLenData = Data(bytes: &nameLen, count: MemoryLayout<UInt32>.stride)
        
        let nameData = self.account!.data(using: .utf8)
        
        var xPos = Double(x)
        let xPosData = Data(bytes: &xPos, count: MemoryLayout<Double>.stride)
        
        var yPos = Double(y)
        let yPosData = Data(bytes: &yPos, count: MemoryLayout<Double>.stride)
        
        var totalLength = UInt32(MemoryLayout<UInt32>.stride) + UInt32(MemoryLayout<UInt32>.stride) + UInt32(MemoryLayout<UInt32>.stride) + UInt32(nameData!.count) + UInt32(MemoryLayout<Double>.stride) + UInt32(MemoryLayout<Double>.stride)
        
        // 消息总长度
        let totalLengthData = Data(bytes: &totalLength, count: MemoryLayout<UInt32>.stride)
        
        sendData.append(contentsOf: [UInt8](totalLengthData))
        sendData.append(contentsOf: [UInt8](typeData))
        sendData.append(contentsOf: [UInt8](uuidData))
        sendData.append(contentsOf: [UInt8](nameLenData))
        sendData.append(contentsOf: [UInt8](nameData!))
        sendData.append(contentsOf: [UInt8](xPosData))
        sendData.append(contentsOf: [UInt8](yPosData))
        
        let dd: Data = Data(bytes: sendData, count: sendData.count)
        OKNetManager.sharedManager.sendData(content: dd)
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

extension GameScene: OKNetManagerStateDelegate {
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

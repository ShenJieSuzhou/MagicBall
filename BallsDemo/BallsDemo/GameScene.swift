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
    private var selfNode: NodeModel?
    private var currentColor: UIColor?
    private var isLive: Bool = false
    
    // store other player node
    private var nodeArray: [NodeModel] = []
    
    // room manager
    private var roomManager: RoomManager!
    
    let BallCategory   : UInt32 = 0x1 << 0
    let BorderCategory : UInt32 = 0x1 << 4
    
    var ball = SKSpriteNode()
    let colors = [UIColor.red, UIColor.green, UIColor.blue, UIColor.brown, UIColor.cyan, UIColor.orange]
    
    let nodeNames = ["qq", "ww", "ss", "rr", "tt", "yy", "uu"]
    var count = 0
    
    override func didMove(to view: SKView) {

        self.isLive = false
        OKNetManager.sharedManager.stateDelegate = self
        self.roomManager = RoomManager()
        
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
                if !isLive {
                    print("+++++++++ generate new node +++++++++")
                    let random = Int(arc4random_uniform(UInt32(self.colors.count)))
                    let uuid = UUID().uuidString
                    print(uuid)
                    
                    // create particle
                    self.selfNode = generateNewSpriteNode(id: uuid, name: nodeNames[random], color: colors[random])
                    self.isLive = true
                }
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouch = nil
        self.selected = false
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // 广播坐标
        if self.selfNode == nil {
            return
        }
        
        print("position: x = \(self.selfNode!.node.position.x)  y = \(self.selfNode!.node.position.y)")
        self.sendPositionToFriends(x: self.selfNode!.node.position.x, y: self.selfNode!.node.position.y)
        
        if self.nodeArray.count == 0 {
            return
        }
        
        for node in self.nodeArray {
            // 更新其他玩家的位置
            self.updateOtherPlayerPosition(model: node)
        }
    }
    
    /// 生成新的节点
    /// - Parameters:
    ///   - id: 标识
    ///   - name: 名称
    ///   - color: 颜色
    /// - Returns: 是否成功
    func generateNewSpriteNode(id: String, name: String, color: UIColor) -> NodeModel{
        self.account = name
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
        node.physicsBody?.applyImpulse(CGVector(dx: 100, dy: 50))
        
        let nodeModel = NodeModel(id: id, node: node)
        return nodeModel
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
    
    // 更新其他例子对象的坐标
    func updateOtherPlayerPosition(model: NodeModel) {
        let id: String = model.id
        
        guard self.roomManager.isExisted(playerID: id) else {
            return
        }
    
        let posList: [CGPoint] = self.roomManager.playerDataMap[id]!
        let skNode: SKSpriteNode = model.node
        skNode.position = posList[0]
        self.roomManager.playerDataMap[id]?.remove(at: 0)
    }
}

extension GameScene: OKNetManagerStateDelegate {
    // 根据哈希表得到对应的线程更新坐标
    func updateWithPosition(uuid: String, pos: CGPoint) {
        if self.roomManager.isExisted(playerID: uuid) {
            self.roomManager.playerDataMap[uuid]?.append(pos)
        }
    }
    
    // 为每个玩家新开一个缓存并用哈希表管理
    func newClientJoinIn(uuid: String, account: String, color: Int) {
        var posArr: [CGPoint] = []
        if !self.roomManager.isExisted(playerID: uuid) {
            self.roomManager.playerDataMap[uuid] = posArr
        
            // 创建例子
            let color = self.getColor(color: color)
            let node = self.generateNewSpriteNode(id: uuid, name: account, color: color)
            // 添加到队列中
            self.nodeArray.append(node)
        }
    }
    
    // 客户端离开
    func clientLeave(uuid: String) {
        if self.roomManager.isExisted(playerID: uuid) {
            self.roomManager.playerDataMap.removeValue(forKey: uuid)
        }
    }
    
    func getColor(color: Int) -> UIColor {
        switch color {
        case 1:
            return UIColor.red
        case 2:
            return UIColor.green
        case 3:
            return UIColor.blue
        case 4:
            return UIColor.brown
        case 5:
            return UIColor.cyan
        case 6:
            return UIColor.orange
        default:
            return UIColor.white
        }
    }
}


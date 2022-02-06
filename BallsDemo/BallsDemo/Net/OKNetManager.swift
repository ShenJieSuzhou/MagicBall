//
//  OKNetManager.swift
//  BallsDemo
//
//  Created by shenjie on 2022/1/20.
//

import UIKit
import CocoaAsyncSocket

protocol OKNetManagerConnDelegate {
    func connectSuccess()
    
    func connectFailed()
}

protocol OKNetManagerStateDelegate {
    func updateWithPosition(uuid: String, pos: CGPoint)
    
    func newClientJoinIn(uuid: String, account: String, color: Int)
    
    func clientLeave(uuid: String)
}


class OKNetManager: NSObject {

    // 全局变量
    static var sharedManager: OKNetManager = {
        let shared = OKNetManager()
        return shared
    }()
    
    private var clientSocket: GCDAsyncSocket!
    //数据缓冲
    fileprivate var receiveData: [UInt8] = []
    
    var connDelegate: OKNetManagerConnDelegate!
    var stateDelegate: OKNetManagerStateDelegate!
        
    // 连接服务器
    func connect(host: String, port: UInt16) -> Void {
        self.clientSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        do {
            try self.clientSocket.connect(toHost: host, onPort: port)
        } catch let error {
            print("try connect error: \(error)")
        }
    }
    
    // 像服务器发送数据
    func sendData(content: Data?) {
        if let data = content {
            self.clientSocket.write(data, withTimeout: -1, tag: 0)
        } else {
            print("Content nil")
        }
    }
    
    // 断开连接
    func disconnect() {
        self.clientSocket.disconnect()
    }
}

extension OKNetManager: GCDAsyncSocketDelegate {
    // 连接服务器成功
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        print("Connect to server success")
        
        self.clientSocket.readData(withTimeout: -1, tag: 0)
        // 回调 生成 node
        connDelegate.connectSuccess()
    }
    
    // 与服务器断开连接
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        // 回调 pop alert
        print("Lost connection with server")
        connDelegate.connectFailed()
    }
    
    // 处理服务器发来的消息
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        print("--- Data Recv ---")
        
        let bytes: [UInt8]! = [UInt8](data)
        self.receiveData.append(contentsOf: bytes)
        
        if self.receiveData.count < 4{
            self.clientSocket.readData(withTimeout: -1, tag: 0)
            return
        }
        
        // 数据总长度
        let totalLength = bytes.count
        
        var type: UInt32 = 0
        var length: Int = 0
        //var readLength: Int = 0
        
        // data header
        let lengthBytesArr: [UInt8] = Array(self.receiveData[0..<4])
        let lenData = Data.init(lengthBytesArr)
        length = Int(UInt32(bigEndian: lenData.withUnsafeBytes { $0.load(as: UInt32.self) }))
        // body content
        // 如果总的数据没有达到数据头的长度，继续获取数据
        if length > totalLength {
            self.clientSocket.readData(withTimeout: -1, tag: 0)
            return
        }
        
        // 否则，解析数据
        let typeBytesArr: [UInt8] = Array(self.receiveData[4..<8])
        let tData = Data.init(typeBytesArr)
        // 消息类型 200：新客户端连接  201: 坐标数据
        type = UInt32(bigEndian: tData.withUnsafeBytes { $0.load(as: UInt32.self) })
        
        if type == 200 {
            let bodyBytesArr: [UInt8] = Array(self.receiveData[8..<length+8])
            let message: String = String(data: Data(bodyBytesArr), encoding: .utf8)!
            print(message)
        } else if type == 201 {
            // body
            let bodyBytesArr: [UInt8] = Array(self.receiveData[8..<length+8])
            // uuidLen
            let uuidLenBytesArr: [UInt8] = Array(bodyBytesArr[0..<4])
            let uuidLenData = Data.init(uuidLenBytesArr)
            let uuidLen: Int = Int(UInt32(bigEndian: uuidLenData.withUnsafeBytes { $0.load(as: UInt32.self) }))
            // uuid
            let uuidBytesArr: [UInt8] = Array(bodyBytesArr[4..<uuidLen+4])
            let uuid: String = String(data: Data(uuidBytesArr), encoding: .utf8)!
            // accLen
            let accPosStart:Int = uuidLen+4
            let accLenBytesArr: [UInt8] = Array(bodyBytesArr[accPosStart..<accPosStart+4])
            let accLenData = Data.init(accLenBytesArr)
            let accLen: Int = Int(UInt32(bigEndian: accLenData.withUnsafeBytes { $0.load(as: UInt32.self) }))
            // account
            let accBytesArr: [UInt8] = Array(bodyBytesArr[accPosStart+4..<accPosStart+4+accLen])
            let account: String = String(data: Data(accBytesArr), encoding: .utf8)!
            // color
            let colorPosStart: Int = accPosStart+4+accLen
            let colorBytesArr: [UInt8] = Array(bodyBytesArr[colorPosStart..<colorPosStart+4])
            let colorData = Data.init(colorBytesArr)
            let color: Int = Int(UInt32(bigEndian: colorData.withUnsafeBytes { $0.load(as: UInt32.self) }))
            
            // according uuid to generate paticle object
            stateDelegate.newClientJoinIn(uuid: uuid, account: account, color: color)
            
        } else if type == 202 {
            // body
            let bodyBytesArr: [UInt8] = Array(self.receiveData[8..<length+8])
            // uuidLen
            let uuidLenBytesArr: [UInt8] = Array(bodyBytesArr[0..<4])
            let uuidLenData = Data.init(uuidLenBytesArr)
            let uuidLen: Int = Int(UInt32(bigEndian: uuidLenData.withUnsafeBytes { $0.load(as: UInt32.self) }))
            // uuid
            let uuidBytesArr: [UInt8] = Array(bodyBytesArr[4..<uuidLen+4])
            let uuid: String = String(data: Data(uuidBytesArr), encoding: .utf8)!
            // accLen
            let accPosStart:Int = uuidLen+4
            let accLenBytesArr: [UInt8] = Array(bodyBytesArr[accPosStart..<accPosStart+4])
            let accLenData = Data.init(accLenBytesArr)
            let accLen: Int = Int(UInt32(bigEndian: accLenData.withUnsafeBytes { $0.load(as: UInt32.self) }))
            // account
            let accBytesArr: [UInt8] = Array(bodyBytesArr[accPosStart+4..<accPosStart+4+accLen])
            let account: String = String(data: Data(accBytesArr), encoding: .utf8)!
            // color
            let colorPosStart: Int = accPosStart+4+accLen
            let colorBytesArr: [UInt8] = Array(bodyBytesArr[colorPosStart..<colorPosStart+4])
            let colorData = Data.init(colorBytesArr)
            let color: Int = Int(UInt32(bigEndian: colorData.withUnsafeBytes { $0.load(as: UInt32.self) }))
            // position
            var xPos: CGFloat = 0.0
            var yPos: CGFloat = 0.0
            let xposStart = colorPosStart+4
            let xPosBytesArr: [UInt8] = Array(bodyBytesArr[xposStart..<xposStart+8])
            let xPosData = Data.init(xPosBytesArr)
            xPos = xPosData.withUnsafeBytes { $0.load(as: CGFloat.self) }
            
            let yposStart = xposStart+8
            let yPosBytesArr: [UInt8] = Array(bodyBytesArr[yposStart..<yposStart+8])
            let yPosData = Data.init(yPosBytesArr)
            yPos = yPosData.withUnsafeBytes { $0.load(as: CGFloat.self) }
            
            // Transfer position data
            stateDelegate.updateWithPosition(uuid: uuid, pos: CGPoint(x: xPos, y: yPos))
        } else if type == 203 {
            // body
            let bodyBytesArr: [UInt8] = Array(self.receiveData[8..<length+8])
            // uuidLen
            let uuidLenBytesArr: [UInt8] = Array(bodyBytesArr[0..<4])
            let uuidLenData = Data.init(uuidLenBytesArr)
            let uuidLen: Int = Int(UInt32(bigEndian: uuidLenData.withUnsafeBytes { $0.load(as: UInt32.self) }))
            // uuid
            let uuidBytesArr: [UInt8] = Array(bodyBytesArr[4..<uuidLen+4])
            let uuid: String = String(data: Data(uuidBytesArr), encoding: .utf8)!
            
            // There is a client leave my room
            stateDelegate.clientLeave(uuid: uuid)
        }
        
        // 从缓存中移除数据
        self.receiveData.removeSubrange(0..<length+4)
        self.clientSocket.readData(withTimeout: -1, tag: 0)
    }
    
    func socket(_ sock: GCDAsyncSocket, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
        
    }
 
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        print("write data")
    }
}

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
    func updateWithPosition(pos: CGPoint)
    
    func newClientJoinIn()
    
    func clientLeave()
}


class OKNetManager: NSObject {

    // 全局变量
    static var sharedManager: OKNetManager = {
        let shared = OKNetManager()
        return shared
    }()
    
    private var clientSocket: GCDAsyncSocket!
    //数据缓冲
    fileprivate var receiveData: Data = Data.init();
    
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
        if bytes == nil || bytes.count < 4{
            self.clientSocket.readData(withTimeout: -1, tag: 0)
            return
        }
        
        // 数据总长度
        let totalLength = bytes.count
        
        var type: UInt32 = 0
        var length: UInt32 = 0
        var readLength: Int = 0
        
        var typeBytesArr: [UInt8] = Array(bytes[0..<4])
        let tData = Data.init(typeBytesArr)
        type = UInt32(bigEndian: tData.withUnsafeBytes { $0.load(as: UInt32.self) })
        readLength += typeBytesArr.count
        
        if readLength + 4 < totalLength {
            var lengthBytesArr: [UInt8] = Array(bytes[4..<8])
            let lenData = Data.init(lengthBytesArr)
            length = UInt32(bigEndian: lenData.withUnsafeBytes { $0.load(as: UInt32.self) })
            readLength += lengthBytesArr.count
        }
        
        var bodyBytesArr:[UInt8] = Array(bytes[8..<totalLength])
        readLength += bodyBytesArr.count
        
        if readLength == totalLength {
            if type == 200 {
                let message: String = String(data: Data(bodyBytesArr), encoding: .utf8)!
                print(message)

            } else if type == 201 {
                print(bodyBytesArr)
            }
        }
        
//        for byte in bytes {
//            if i < 4 {
//                typeBytesArr.append(byte)
//            } else {
//                let tData = Data.init(typeBytesArr)
//                type = UInt32(bigEndian: tData.withUnsafeBytes { $0.load(as: UInt32.self) })
//                print(type)
//            }
//
//            if i >= 4 && i < 8 {
//                lengthBytesArr.append(byte)
//            } else {
//                let lenData = Data.init(lengthBytesArr)
//                length = UInt32(bigEndian: lenData.withUnsafeBytes { $0.load(as: UInt32.self) })
//            }
//
//            if i >= 8 && i < length + 7 {
//                bodyBytesArr.append(byte)
//            }
//
//            i = i + 1
//        }
        
        
        
        
        self.clientSocket.readData(withTimeout: -1, tag: 0)
    }
    
    func socket(_ sock: GCDAsyncSocket, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
        
    }
 
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        print("write data")
    }
}

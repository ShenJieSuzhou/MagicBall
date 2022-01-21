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
        
        let msg = String(data: data, encoding: String.Encoding.utf8)
        print("recv data:\(msg)")
        
//        // 回调 update position
//        stateDelegate.updateWithPosition(pos: CGPoint(x: 0, y: 0))
//        // 新加入了客户端
//        stateDelegate.newClientJoinIn()
//        // 客户端离开
//        stateDelegate.clientLeave()
        self.clientSocket.readData(withTimeout: -1, tag: 0)
    }
    
    func socket(_ sock: GCDAsyncSocket, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
        
    }
 
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        print("write data")
    }
}

//
//  OKNetManager.swift
//  BallsDemo
//
//  Created by shenjie on 2022/1/20.
//

import UIKit
import CocoaAsyncSocket

protocol OKNetManagerDelegate {
    func connectSuccess()
    
    func connectFailed()
    
    func updateWithPosition(pos: CGPoint)
    
    func newClientJoinIn()
    
    func clientLeave()
}


class OKNetManager: NSObject {

    private var clientSocket: GCDAsyncSocket!
    var delegate: OKNetManagerDelegate!
        
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
        // 回调 生成 node
        delegate.connectSuccess()
    }
    
    // 与服务器断开连接
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        // 回调 pop alert
        delegate.connectFailed()
    }
    
    // 处理服务器发来的消息
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        // 回调 update position
        delegate.updateWithPosition(pos: CGPoint(x: 0, y: 0))
        // 新加入了客户端
        delegate.newClientJoinIn()
        // 客户端离开
        delegate.clientLeave()
    }
}

//
//  GameViewController.swift
//  BallsDemo
//
//  Created by shenjie on 2022/1/14.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    private var clientSocket: OKNetManager!
    let host: String = "10.200.22.126"
//    let host: String = "192.168.0.113"
    let port: UInt16 = 5555
    
    override func viewDidLoad() {
        super.viewDidLoad()
        OKNetManager.sharedManager.connDelegate = self
        
//        var xPos = Double(-14.29188346862793)
//        let xPosData = Data(bytes: &xPos, count: MemoryLayout<Double>.stride)
//        let xPosData = Data(buffer: UnsafeBufferPointer(start: &xPos, count: 1))
        
//        var yPos = Double(133.60305786132812)
//        let yPosData = Data(bytes: &yPos, count: MemoryLayout<Double>.stride)
//        let len1 = MemoryLayout<Float>.stride
//        let len2 = MemoryLayout<CGFloat>.stride
        
//        let typeBytesArr: [UInt8] = [0, 0, 200, 194]
//        let tData = Data.init(typeBytesArr)
//        // 消息类型 200：新客户端连接  201: 坐标数据
//        let type = UInt32(littleEndian: tData.withUnsafeBytes { $0.load(as: UInt32.self) })
//
//        print(type)
        
//        var len: Int = MemoryLayout<UInt>.stride
//        print(len)
        
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    

    @IBAction func connectToServer(_ sender: Any) {
        OKNetManager.sharedManager.connect(host: host, port: port)
    }
}

extension GameViewController: OKNetManagerConnDelegate {
    
    func connectSuccess() {
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                // Present the scene
                view.presentScene(scene)
            }

            view.ignoresSiblingOrder = true

            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    
    func connectFailed() {
        let alert = UIAlertController(title: "Alert", message: "lost connection with server", preferredStyle: .alert)
        self.present(alert, animated: false) {
            
        }
    }
}

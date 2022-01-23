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
    let host: String = "192.168.0.119"
    let port: UInt16 = 5555
    
    override func viewDidLoad() {
        super.viewDidLoad()
        OKNetManager.sharedManager.connDelegate = self
        
        let typeBytesArr: [UInt8] = [224, 38, 94, 0]
        let tData = Data.init(typeBytesArr)
        // 消息类型 200：新客户端连接  201: 坐标数据
        let type = UInt32(littleEndian: tData.withUnsafeBytes { $0.load(as: UInt32.self) })

        print(type)
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

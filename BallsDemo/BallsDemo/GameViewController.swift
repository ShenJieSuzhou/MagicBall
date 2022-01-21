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
    let port: UInt16 = 5555
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        OKNetManager.sharedManager.connDelegate = self
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

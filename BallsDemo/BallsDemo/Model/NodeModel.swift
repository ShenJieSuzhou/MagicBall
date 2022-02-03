//
//  NodeModel.swift
//  BallsDemo
//
//  Created by snaigame on 2022/2/3.
//

import UIKit
import SpriteKit

class NodeModel: NSObject {
    var id: String
    var node: SKSpriteNode
    
    init(id: String, node: SKSpriteNode) {
        self.id = id
        self.node = node
    }
}

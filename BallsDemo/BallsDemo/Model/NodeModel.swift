//
//  NodeModel.swift
//  BallsDemo
//
//  Created by snaigame on 2022/2/3.
//

import UIKit
import SpriteKit

class NodeModel: NSObject {
    var id: Int
    var node: SKSpriteNode
    
    init(id: Int, node: SKSpriteNode) {
        self.id = id
        self.node = node
    }
}

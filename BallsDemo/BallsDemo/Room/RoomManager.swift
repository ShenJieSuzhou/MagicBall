//
//  RoomManager.swift
//  BallsDemo
//
//  Created by snaigame on 2022/2/2.
//

import UIKit

class RoomManager: NSObject {

    var playerDataMap: [Int: [CGPoint]] = [:]
    
    override init() {
        super.init()
        
    }
    
    func setPlayerData(uuid: Int, posArr: [CGPoint]) {
        if !self.isExisted(playerID: uuid) {
            self.playerDataMap[uuid] = posArr
        }
    }
    
//    func getPlayerData(uuid: Int) ->
    
    func isExisted(playerID: Int) -> Bool {
        if self.playerDataMap[playerID] != nil {
            return true;
        }
        
        return false
    }
    
    // 玩家进入房间
    func enterRoom(playerId: Int) {
        
        if self.playerDataMap[playerId] != nil {
            
        } else {
            //
            
        }
    }
    
    // 玩家离开房间
    func leaveRoom(playerId: Int) {
        
    }
}


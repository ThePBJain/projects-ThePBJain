//
//  Message.swift
//  Peerify
//
//  Created by Pranav Jain on 12/30/18.
//  Copyright © 2018 Pranav Jain. All rights reserved.
//

import Foundation
import UIKit
//Learned about Equatable from Apple Docs: https://developer.apple.com/documentation/swift/equatable
class Message : Codable , Equatable{
    var id : String
    var text : String
    var timestamp : Date
    var sender : String
    var image : UIImage?
    
    init(sender: String, text: String) {
        self.sender = sender
        self.text = text
        self.timestamp = Date.init()
        self.id = "\(sender)-\(self.timestamp.description)"
    }
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case text
        case timestamp
        case sender
    }
    
    
}

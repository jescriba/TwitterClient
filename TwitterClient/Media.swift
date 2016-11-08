//
//  Media.swift
//  TwitterClient
//
//  Created by joshua on 11/7/16.
//  Copyright © 2016 Joshua. All rights reserved.
//

import UIKit

class Media: NSObject {
    var id: Int?
    var urlString: String?
    var mediaUrl: URL?
    var type: String?
    
    init(dictionary: NSDictionary) {
        id = dictionary["id"] as? Int
        type = dictionary["type"] as? String
        urlString = dictionary["url"] as? String
        let mediaUrlString = dictionary["media_url_https"] as? String
        if let mediaUrlString = mediaUrlString {
            mediaUrl = URL(string: mediaUrlString)
        }
    }
}

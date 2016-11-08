//
//  Entity.swift
//  TwitterClient
//
//  Created by joshua on 11/7/16.
//  Copyright © 2016 Joshua. All rights reserved.
//

import UIKit

class Entity: NSObject {
    
    var media = [Media]()
    init(dictionary: NSDictionary) {
        
        let mediaDictionaryArray = dictionary["media"] as? [NSDictionary]
        if let array = mediaDictionaryArray {
            for mediaDict in array {
                media.append(Media(dictionary: mediaDict))
            }
        }
    }
    
}

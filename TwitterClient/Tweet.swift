//
//  Tweet.swift
//  TwitterClient
//
//  Created by Joshua Escribano on 10/27/16.
//  Copyright © 2016 Joshua. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    var id: Int?
    var text: String?
    var user: User?
    var retweeted: Bool?
    var favorited: Bool?
    var timeStamp: Date?
    var retweetCount: Int = 0
    var favoritesCount: Int = 0
    
    init(dictionary: NSDictionary) {
        id = dictionary["id"] as? Int
        text = dictionary["text"] as? String
        retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        favoritesCount = (dictionary["favourites_count"] as? Int) ?? 0
        retweeted = (dictionary["retweeted"] as? Bool) ?? false
        favorited = (dictionary["favorited"] as? Bool) ?? false
        
        let timeStampString = dictionary["created_at"] as? String
        if let timeStampString = timeStampString {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MMM d HH::mm::ss Z y"
            timeStamp = formatter.date(from: timeStampString)
        }
        
        let userDictionary = dictionary["user"] as? NSDictionary
        if let userDictionary = userDictionary {
            user = User(dictionary: userDictionary)
        }
    }
    
    class func tweetsWithArray(dictionaries: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for dictionary in dictionaries {
            let tweet = Tweet(dictionary: dictionary)
            tweets.append(tweet)
        }
        
        return tweets
    }
}

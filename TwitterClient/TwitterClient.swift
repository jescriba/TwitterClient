//
//  TwitterClient.swift
//  TwitterClient
//
//  Created by Joshua Escribano on 10/27/16.
//  Copyright © 2016 Joshua. All rights reserved.
//

import Foundation
import BDBOAuth1Manager

class TwitterClient: BDBOAuth1SessionManager {
    static let sharedInstance = TwitterClient(baseURL: URL(string: "https://api.twitter.com")!, consumerKey: "X3jm3IYfpcy2bI6beHeXjDss8", consumerSecret: 	"ZGJOT0d5UmXXLiZ2sTAK7LrfNiGHjqWbY4aJQqXIdWV7oHdnvU")
    
    var loginSuccess: (() -> ())?
    var loginFailure: ((Error?) -> ())?
    
    func handleOpenUrl(_ url: URL) {
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        login(requestToken: requestToken!)
    }
    
    func login(success: @escaping () -> (), failure: @escaping (Error?) -> ()) {
        loginSuccess = success
        loginFailure = failure
     
        deauthorize()
        fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: URL(string: "twitter://"), scope: nil, success: {
                (requestToken: BDBOAuth1Credential?) -> () in
                let url = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken!.token!)")!
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }, failure: {
                (error: Error?) -> () in
                self.loginFailure?(error)
                
        })
    }
    
    func login(user: User) {
        if let requestToken = user.requestToken {
            login(requestToken: requestToken)
        }
    }
    
    func login(requestToken: BDBOAuth1Credential) {
        fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: requestToken, success: {
            (accessToken: BDBOAuth1Credential?) -> () in
            self.currentAccount(success: {
                (user: User) -> () in
                user.requestToken = requestToken
                User.currentUser = user
                self.loginSuccess?()
                }, failure: {
                    (error: Error) -> () in
                    self.loginFailure?(error)
            })
            }, failure: {
                (error: Error?) -> () in
                self.loginFailure?(error)
        })
    }
    
    func logout() {
        User.currentUser = nil
        deauthorize()
        
        NotificationCenter.default.post(name: User.userDidLogOutNotification, object: nil)
    }
    
    func homeTimeline(success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        get("1.1/statuses/home_timeline.json", parameters: nil, progress: nil, success: {
            (task: URLSessionDataTask, response: Any?) -> () in
                let dictionaries = response as! [NSDictionary]
                let tweets = Tweet.tweetsWithArray(dictionaries: dictionaries)
            
                success(tweets)
            }, failure: {
                (task: URLSessionDataTask?, error: Error) -> () in
                failure(error)
        })
    }
    
    func currentAccount(success: @escaping (User) -> (), failure: @escaping (Error) -> ()) {
        get("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: {
                (task: URLSessionDataTask, response: Any?) -> () in
                let userDictionary = response as! NSDictionary
                let user = User(dictionary: userDictionary)
                success(user)
            }, failure: {
                (task: URLSessionDataTask?, error: Error) -> () in
                failure(error)
        })
    }
    
    func tweet(_ message: String, success: () -> (), failure: (Error) -> ()) {
        let endPoint = "1.1/statuses/update.json?status=\(message.urlEncode())"
        post(endPoint, parameters: nil, progress: nil, success: {
            (task: URLSessionDataTask, response: Any?) -> () in
            //
            }, failure: {
                (task: URLSessionDataTask?, error: Error) -> () in
                // TODO
                
        })
    }
    
    func retweet(tweet: Tweet, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        let endPoint = "1.1/statuses/retweet/\(tweet.id!).json"
        post(endPoint, parameters: nil, progress: nil, success: {
            (task: URLSessionDataTask, response: Any?) -> () in
                success()
            }, failure: {
                (task: URLSessionDataTask?, error: Error) -> () in
                failure(error)
        })
    }
    
    func removeRetweet(tweet: Tweet) {
        // TODO
    }
    
    func favorite(tweet: Tweet, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        let endPoint = "1.1/favorites/create.json?id=\(tweet.id!)"
        post(endPoint, parameters: nil, progress: nil, success: {
            (task: URLSessionDataTask, response: Any?) -> () in
                success()
            }, failure: {
                (task: URLSessionDataTask?, error: Error) -> () in
                failure(error)
        })
    }
    
    func removeFavorite(tweet: Tweet) {
        // TODO
    }
    
    func reply() {
        // TODO
    }
    
}

extension String {
    func urlEncode() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
}

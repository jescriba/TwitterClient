//
//  TweetsTableView.swift
//  TwitterClient
//
//  Created by Joshua Escribano on 11/6/16.
//  Copyright © 2016 Joshua. All rights reserved.
//

import UIKit
import CircularSpinner

enum Timeline:Int {
    case home, user, mentions
}

protocol TweetsTableViewDelegate {
    func onProfileImageTap(user: User)
}

class TweetsTableView: UITableView {
    internal var timeline: Timeline? = nil {
        didSet {
            reload()
        }
    }
    internal var tweetDelegate: TweetsTableViewDelegate?
    internal var isLoading = false
    internal var hasMoreTweets = true
    internal var tweets = [Tweet]()
    internal let tweetsRefreshControl = UIRefreshControl()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.delegate = self
        self.dataSource = self

        tableFooterView = UIView()
        estimatedRowHeight = 100
        rowHeight = UITableViewAutomaticDimension
        
        timeline = .home
        insertSubview(tweetsRefreshControl, at: 0)
        
        tweetsRefreshControl.addTarget(self, action: #selector(reload), for: .valueChanged)
    }
    
    @objc internal func reload(maxId: Int = -1) {
        loadTimeline(timeline!)
    }
    
    private func loadTimeline(_ timeline: Timeline) {
        // TODO
        var maxId: Int?
        isLoading = true
        tweetsRefreshControl.beginRefreshing()
        CircularSpinner.show("Loading tweets...", animated: true, type: .indeterminate)
        TwitterClient.sharedInstance?.homeTimeline(maxId: maxId, success: {
            (tweets: [Tweet]) -> () in
            if tweets.count == 0 {
                self.hasMoreTweets = false
            }
            if maxId == nil {
                self.tweets = tweets
            } else {
                self.tweets += tweets
            }
            self.reloadData()
            CircularSpinner.hide()
            self.tweetsRefreshControl.endRefreshing()
            self.isLoading = false
        }, failure: {
            (error: Error) -> () in
            CircularSpinner.hide()
            self.tweetsRefreshControl.endRefreshing()
            self.isLoading = false
            //self.present(Alert.controller(error: error), animated: true, completion: nil)
        })
    }
    
}

extension TweetsTableView: TweetCellDelegate {
    func onReply(tweetCell: TweetCell) {
        //
    }
    
    func onFavorite(tweetCell: TweetCell) {
        //
    }
    
    func onRetweet(tweetCell: TweetCell) {
        //
    }
    
    func onProfileImageTap(tweetCell: TweetCell) {
        let user = tweetCell.tweet!.user!
        tweetDelegate?.onProfileImageTap(user: user)
    }
}

extension TweetsTableView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        cell.delegate = self as? TweetCellDelegate
        cell.tweet = tweets[indexPath.row]
        
        if indexPath.row == tweets.count - 1 && !isLoading && hasMoreTweets && tableView.isDragging {
            let lastTweet = tweets.last!
            let maxId = lastTweet.id!
            
            reload(maxId: maxId)
        }
        
        return cell
    }
}

extension TweetsTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


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
    func didSelect(tweet: Tweet)
    func onReply(tweet: Tweet)
    func onProfileImageTap(user: User)
    func present(viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?)
}

class TweetsTableView: UITableView {
    internal var timeline: Timeline? = nil {
        didSet {
            reload()
        }
    }
    internal var user: User? = nil {
        didSet {
            reload()
        }
    }
    internal var tweetDelegate: TweetsTableViewDelegate?
    internal var isLoading = false
    internal var hasMoreTweets = true
    internal var tweets = [Tweet]()
    internal let tweetsRefreshControl = UIRefreshControl()
    internal var maxId: Int?
    func timelineSuccess(tweets: [Tweet]) {
        if tweets.count == 0 {
            hasMoreTweets = false
        }
        if maxId == nil {
            self.tweets = tweets
        } else {
            self.tweets += tweets
        }
        reloadData()
        CircularSpinner.hide()
        tweetsRefreshControl.endRefreshing()
        isLoading = false
    }
    func timelineFailure(error: Error) {
        CircularSpinner.hide()
        tweetsRefreshControl.endRefreshing()
        isLoading = false
        present(viewControllerToPresent: Alert.controller(error: error), animated: true, completion: nil)
    }
    
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
        loadTimeline(timeline!, maxId: maxId)
    }
    
    internal func present(viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        tweetDelegate?.present(viewControllerToPresent: viewControllerToPresent, animated: animated, completion: completion)
    }
    
    private func loadTimeline(_ timeline: Timeline, maxId offsetId: Int = -1) {
        var maxId: Int?
        if offsetId != -1 {
            maxId = offsetId
        }
        isLoading = true
        tweetsRefreshControl.beginRefreshing()
        CircularSpinner.show("Loading tweets...", animated: true, type: .indeterminate)
        self.maxId = maxId
        switch timeline {
        case .home:
            TwitterClient.sharedInstance?.homeTimeline(maxId: maxId, success: timelineSuccess, failure: timelineFailure)
        case .mentions:
            TwitterClient.sharedInstance?.mentionsTimeline(maxId: maxId, success: timelineSuccess, failure: timelineFailure)
        case .user:
            let userId = (user ?? User.currentUser!).id!
            TwitterClient.sharedInstance?.userTimeline(userId: userId, success: timelineSuccess, failure: timelineFailure)
        }

    }
    
}

extension TweetsTableView: TweetCellDelegate {
    
    func onReply(tweetCell: TweetCell) {
        tweetDelegate?.onReply(tweet: tweetCell.tweet!)
    }
    
    func onRetweet(tweetCell: TweetCell) {
        let tweet = tweetCell.tweet
        TwitterClient.sharedInstance?.toggleRetweet(tweet: tweet!, success: {
            (tweet: Tweet) -> () in
            tweetCell.tweet = tweet
        }, failure: {
            (error: Error) -> () in
            self.present(viewControllerToPresent: Alert.controller(error: error), animated: true, completion: nil)
        })
    }
    
    func onFavorite(tweetCell: TweetCell) {
        let tweet = tweetCell.tweet
        TwitterClient.sharedInstance?.toggleFavorite(tweet: tweet!, success: {
            (tweet: Tweet) -> () in
            tweetCell.tweet = tweet
        }, failure: {
            (error: Error) -> () in
            self.present(viewControllerToPresent: Alert.controller(error: error), animated: true, completion: nil)
        })
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
        cell.delegate = self
        cell.tweet = tweets[indexPath.row]
        
        if indexPath.row == tweets.count - 1 && !isLoading && hasMoreTweets && isDragging {
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
        
        let cell = tableView.cellForRow(at: indexPath) as! TweetCell
        tweetDelegate?.didSelect(tweet: cell.tweet!)
    }
}


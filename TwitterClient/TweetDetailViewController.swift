//
//  TweetDetailViewController.swift
//  TwitterClient
//
//  Created by Joshua Escribano on 10/28/16.
//  Copyright © 2016 Joshua. All rights reserved.
//

import UIKit

class TweetDetailViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var retweetLabel: UILabel!
    @IBOutlet weak var favoritesLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    
    internal var tweet: Tweet? {
        didSet {
            setupTweetUI()
        }
    }
    
    private func setupTweetUI() {
        if let tweet = tweet {
            guard tweetLabel != nil else { return }
            tweetLabel.text = tweet.text
            nameLabel.text = tweet.user!.name
            favoritesLabel.text = "\(tweet.favoritesCount)"
            retweetLabel.text = "\(tweet.retweetCount)"
            screenNameLabel.text = "@\(tweet.user!.screenName!)"
            profileImageView.setImageWith(tweet.user!.profileUrl!)
            profileImageView.layer.cornerRadius = 10
            if tweet.favorited ?? false {
                favoriteButton.setImage(#imageLiteral(resourceName: "red_heart"), for: .normal)
            } else {
                favoriteButton.setImage(#imageLiteral(resourceName: "heart"), for: .normal)
            }
            if tweet.retweeted ?? false {
                retweetButton.setImage(#imageLiteral(resourceName: "green_retweet"), for: .normal)
            } else {
                retweetButton.setImage(#imageLiteral(resourceName: "retweet"), for: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTweetUI()
    }

    @IBAction func onReplyButton(_ sender: AnyObject) {
        // TODO
    }
    
    @IBAction func onRetweetButton(_ sender: AnyObject) {
        if tweet?.retweeted ?? false {
            TwitterClient.sharedInstance?.removeRetweet(tweet: tweet!)
        } else {
            TwitterClient.sharedInstance?.retweet(tweet: tweet!, success: {
                    () -> () in
                    self.tweet?.retweeted = true
                    self.tweet?.retweetCount += 1
                    self.setupTweetUI()
                }, failure: {
                    (error: Error) -> () in
                    // TODO show failure
            })
        }
    }
    
    @IBAction func onFavoriteButton(_ sender: AnyObject) {
        if tweet?.favorited ?? false {
            TwitterClient.sharedInstance?.removeFavorite(tweet: tweet!)
        } else {
            TwitterClient.sharedInstance?.favorite(tweet: tweet!, success: {
                () -> () in
                    self.tweet?.favorited = true
                    self.tweet?.favoritesCount += 1
                    self.setupTweetUI()
                }, failure: {
                    (error: Error) -> () in
                    // TODO show failure
            })
        }
    }
    
}

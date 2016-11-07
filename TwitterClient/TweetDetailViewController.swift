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
    internal var delegate: NewTweetDelegate?
    
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
            favoritesLabel.text = tweet.favoritesCount.simpleDescription()
            retweetLabel.text = tweet.retweetCount.simpleDescription()
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
            dateLabel.text = tweet.timeStamp?.simpleDescription() ?? ""
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTweetUI()
    }
    
    @IBAction func onRetweetButton(_ sender: AnyObject) {
        TwitterClient.sharedInstance?.toggleRetweet(tweet: tweet!, success: {
            (tweet: Tweet) -> () in
                self.tweet = tweet
                self.delegate?.newTweet(tweet)
                self.navigationController?.popToRootViewController(animated: true)
            }, failure: {
                (error: Error) -> () in
                self.present(Alert.controller(error: error), animated: true, completion: nil)
        })
    }
    
    @IBAction func onFavoriteButton(_ sender: AnyObject) {
        TwitterClient.sharedInstance?.toggleFavorite(tweet: tweet!, success: {
            (tweet: Tweet) -> () in
                self.tweet = tweet
            }, failure: {
                (error: Error) -> () in
                self.present(Alert.controller(error: error), animated: true, completion: nil)
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let replyVC = segue.destination as? ReplyViewController
        if let vc = replyVC {
            vc.respondingToTweet = tweet
        }
    }
    
}

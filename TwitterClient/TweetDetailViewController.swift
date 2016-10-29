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

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTweetUI()
    }

    @IBAction func onReplyButton(_ sender: AnyObject) {
        // TODO
    }
}

//
//  TweetCell.swift
//  TwitterClient
//
//  Created by Joshua Escribano on 10/28/16.
//  Copyright © 2016 Joshua. All rights reserved.
//

import UIKit

protocol TweetCellDelegate {
    func onReply(tweetCell: TweetCell)
    func onRetweet(tweetCell: TweetCell)
    func onFavorite(tweetCell: TweetCell)
    func onProfileImageTap(tweetCell: TweetCell)
}

class TweetCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favoritesCountLabel: UILabel!
    @IBOutlet weak var timeSincePostLabel: UILabel!
    
    var delegate: TweetCellDelegate?
    
    internal var tweet: Tweet? {
        didSet {
            guard nameLabel != nil else { return }

            setupTweetUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let profileTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onProfileImageTap))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(profileTapRecognizer)
    }
    
    private func setupTweetUI() {
        if let tweet = tweet {
            messageLabel.text = tweet.text
            nameLabel.text = tweet.user!.name
            retweetCountLabel.text = tweet.retweetCount.simpleDescription()
            favoritesCountLabel.text = tweet.favoritesCount.simpleDescription()
            screenNameLabel.text = "@\(tweet.user!.screenName!)"
            timeSincePostLabel.text = tweet.timeStamp?.timeSinceDescription() ?? "..."
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        let bgView = UIView()
        bgView.backgroundColor = UIColor(red:0.67, green:0.94, blue:1.00, alpha:1.0)
        selectedBackgroundView = bgView
    }
    
    func onProfileImageTap() {
        delegate?.onProfileImageTap(tweetCell: self)
    }
    
    @IBAction func onReplyButton(_ sender: AnyObject) {
        delegate?.onReply(tweetCell: self)
    }
    
    @IBAction func onRetweetButton(_ sender: AnyObject) {
        delegate?.onRetweet(tweetCell: self)
    }
    
    @IBAction func onFavoriteButton(_ sender: AnyObject) {
        delegate?.onFavorite(tweetCell: self)
    }
}

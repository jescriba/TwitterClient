//
//  TweetCell.swift
//  TwitterClient
//
//  Created by Joshua Escribano on 10/28/16.
//  Copyright © 2016 Joshua. All rights reserved.
//

import UIKit

class TweetCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    internal var tweet: Tweet? {
        didSet {
            setupTweetUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    private func setupTweetUI() {
        if let tweet = tweet {
            messageLabel.text = tweet.text
            nameLabel.text = tweet.user!.name
            screenNameLabel.text = "@\(tweet.user!.screenName!)"
            profileImageView.setImageWith(tweet.user!.profileUrl!)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

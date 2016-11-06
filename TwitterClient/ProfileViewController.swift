//
//  ProfileViewController.swift
//  TwitterClient
//
//  Created by Joshua Escribano on 11/4/16.
//  Copyright © 2016 Joshua. All rights reserved.
//

import UIKit
import CircularSpinner

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var followersNumberLabel: UILabel!
    @IBOutlet weak var followingNumberLabel: UILabel!
    @IBOutlet weak var tweetsNumberLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerImageView: UIImageView!
    internal var user: User! {
        didSet {
            view.layoutIfNeeded()
            
            followingNumberLabel.text = "\(user.friendsCount.simpleDescription())"
            followersNumberLabel.text = "\(user.followersCount.simpleDescription())"
            tweetsNumberLabel.text = "\(user.statusesCount.simpleDescription())"
            navigationItem.title = user.name
            if let bannerUrl = user.bannerUrl {
                headerImageView.setImageWith(bannerUrl)
            }
        }
    }
    internal weak var delegate: MenuViewController!
    internal var tweets = [Tweet]()
    private var isLoading = false
    private var hasMoreTweets = true
    private var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        if user == nil {
            let menuImage = UIImage(named: "menu")
            let menuButton = UIBarButtonItem(image: menuImage, style: .plain, target: self, action: #selector(onToggleMenu))
            navigationItem.leftBarButtonItem = menuButton
            user = User.currentUser!
        }
        refreshControl = UIRefreshControl()
        loadUserTimeLine(userId: user.id!)
    }
    
    @objc internal func loadUserTimeLine(userId: Int, maxId offsetId: Int = -1) {
        // For Obj C
        var maxId: Int?
        if offsetId != -1 {
            maxId = offsetId
        }
        
        isLoading = true
        refreshControl.beginRefreshing()
        CircularSpinner.show("Loading tweets...", animated: true, type: .indeterminate)
        TwitterClient.sharedInstance?.userTimeline(userId: userId, maxId: maxId, success: {
            (tweets: [Tweet]) -> () in
            if tweets.count == 0 {
                self.hasMoreTweets = false
            }
            if maxId == nil {
                self.tweets = tweets
            } else {
                self.tweets += tweets
            }
            self.tableView.reloadData()
            CircularSpinner.hide()
            self.refreshControl.endRefreshing()
            self.isLoading = false
        }, failure: {
            (error: Error) -> () in
            CircularSpinner.hide()
            self.refreshControl.endRefreshing()
            self.isLoading = false
            self.present(Alert.controller(error: error), animated: true, completion: nil)
        })
    }
}

extension ProfileViewController: MenuViewControllerDelegate {
    internal func onToggleMenu() {
        delegate?.onToggleMenu()
    }
}

extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tweetDetailVC = storyboard.instantiateViewController(withIdentifier: "TweetDetailViewController") as! TweetDetailViewController
        tweetDetailVC.delegate = self
        let cell = tableView.cellForRow(at: indexPath) as! TweetCell
        tweetDetailVC.tweet = cell.tweet
        
        navigationController?.pushViewController(tweetDetailVC, animated: true)
    }
    
}

extension ProfileViewController: TweetsViewControllerDelegate {
    func newTweet(_ tweet: Tweet) {
        //
    }
}

extension ProfileViewController: TweetCellDelegate {
    
    internal func onProfileImageTap(tweetCell: TweetCell) {
        //
    }


    func onReply(tweetCell: TweetCell) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ReplyViewController") as! ReplyViewController
        vc.respondingToTweet = tweetCell.tweet
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func onRetweet(tweetCell: TweetCell) {
        let tweet = tweetCell.tweet
        TwitterClient.sharedInstance?.toggleRetweet(tweet: tweet!, success: {
            (tweet: Tweet) -> () in
            tweetCell.tweet = tweet
        }, failure: {
            (error: Error) -> () in
            self.present(Alert.controller(error: error), animated: true, completion: nil)
        })
    }
    
    func onFavorite(tweetCell: TweetCell) {
        let tweet = tweetCell.tweet
        TwitterClient.sharedInstance?.toggleFavorite(tweet: tweet!, success: {
            (tweet: Tweet) -> () in
            tweetCell.tweet = tweet
        }, failure: {
            (error: Error) -> () in
            self.present(Alert.controller(error: error), animated: true, completion: nil)
        })
    }
}

extension ProfileViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        cell.delegate = self
        cell.tweet = tweets[indexPath.row]
        
        return cell
    }
}

//
//  MentionsViewController.swift
//  TwitterClient
//
//  Created by Joshua Escribano on 11/6/16.
//  Copyright © 2016 Joshua. All rights reserved.
//

import UIKit
import CircularSpinner

class MentionsViewController: UIViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    internal weak var delegate: MenuViewController!
    internal var tweets = [Tweet]()
    internal var hasMoreTweets = true
    internal var isLoading = false
    internal var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        menuButton.target = self
        menuButton.action = #selector(onToggleMenu)
        refreshControl = UIRefreshControl()
        loadMentionsTimeLine()
    }
    
    @objc internal func loadMentionsTimeLine(maxId offsetId: Int = -1) {
        var maxId: Int?
        if offsetId != -1 {
            maxId = offsetId
        }
        
        isLoading = true
        refreshControl.beginRefreshing()
        CircularSpinner.show("Loading tweets...", animated: true, type: .indeterminate)
        TwitterClient.sharedInstance?.mentionsTimeline(maxId: maxId, success: {
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

extension MentionsViewController: TweetCellDelegate {
    
    func onProfileImageTap(tweetCell: TweetCell) {
        let user = tweetCell.tweet!.user!
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        vc.user = user
        navigationController?.pushViewController(vc, animated: true)
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

extension MentionsViewController: TweetsViewControllerDelegate {
    func newTweet(_ tweet: Tweet) {
        //
    }
}

extension MentionsViewController: UITableViewDelegate {
    
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

extension MentionsViewController: UITableViewDataSource {
    
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

extension MentionsViewController:MenuViewControllerDelegate {
    internal func onToggleMenu() {
        delegate?.onToggleMenu()
    }
}

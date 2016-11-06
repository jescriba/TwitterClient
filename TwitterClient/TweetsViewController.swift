//
//  TweetsViewController.swift
//  TwitterClient
//
//  Created by Joshua Escribano on 10/28/16.
//  Copyright © 2016 Joshua. All rights reserved.
//

import UIKit
import CircularSpinner

protocol TweetsViewControllerDelegate {
    func newTweet(_ tweet: Tweet)
}

class TweetsViewController: UIViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    internal weak var delegate: MenuViewController!
    internal var hasMoreTweets = true
    internal var tweets = [Tweet]()
    internal var isLoading = false
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.insertSubview(refreshControl, at: 0)
        refreshControl.addTarget(self, action: #selector(loadTimeLine(maxId:)), for: .valueChanged)
        menuButton.target = self
        menuButton.action = #selector(onToggleMenu)
        loadTimeLine()
    }
    
    @objc internal func loadTimeLine(maxId offsetId: Int = -1) {
        // For Obj C
        var maxId: Int?
        if offsetId != -1 {
            maxId = offsetId
        }
        
        isLoading = true
        refreshControl.beginRefreshing()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let tweetDetailVC = segue.destination as? TweetDetailViewController
        let navigationController = segue.destination as? UINavigationController
        
        if let vc = tweetDetailVC {
            tweetDetailVC?.delegate = self
            
            let cell = sender as! TweetCell
            vc.tweet = cell.tweet
        } else if let navVC = navigationController {
            let composeVC = navVC.topViewController as? ComposeTweetViewController
            if let vc = composeVC {
                vc.delegate = self
            }
        }
    }
    
}

extension TweetsViewController: TweetsViewControllerDelegate {
    internal func newTweet(_ tweet: Tweet) {
        self.tweets.insert(tweet, at: 0)
        tableView.reloadData()
    }
}

extension TweetsViewController: MenuViewControllerDelegate {
    
    internal func onToggleMenu() {
        delegate?.onToggleMenu()
    }
    
}

extension TweetsViewController: TweetCellDelegate {
    
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
        vc.delegate = self
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

extension TweetsViewController: UITableViewDataSource {
    
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
            
            loadTimeLine(maxId: maxId)
        }
        
        return cell
    }
}

extension TweetsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

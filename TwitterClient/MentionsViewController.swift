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
    @IBOutlet weak var tableView: TweetsTableView!
    internal weak var delegate: MenuViewController!
    internal var tweets = [Tweet]()
    internal var hasMoreTweets = true
    internal var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuButton.target = self
        menuButton.action = #selector(onToggleMenu)

        tableView.timeline = .mentions
        tableView.user = User.currentUser
        tableView.tweetDelegate = self
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
extension MentionsViewController:MenuViewControllerDelegate {
    internal func onToggleMenu() {
        delegate?.onToggleMenu()
    }
}

extension MentionsViewController: NewTweetDelegate {
    func newTweet(_ tweet: Tweet) {
        tweets.append(tweet)
        tableView.reloadData()
    }
}

extension MentionsViewController: TweetsTableViewDelegate {
    func didSelect(tweet: Tweet) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TweetDetailViewController") as! TweetDetailViewController
        vc.tweet = tweet
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    func onProfileImageTap(user: User) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        vc.user = user
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func onReply(tweet: Tweet) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ReplyViewController") as! ReplyViewController
        vc.respondingToTweet = tweet
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func present(viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        present(viewControllerToPresent, animated: animated, completion: completion)
    }
    
}

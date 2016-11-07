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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuButton.target = self
        menuButton.action = #selector(onToggleMenu)

        tableView.timeline = .mentions
        tableView.user = User.currentUser
        tableView.tweetDelegate = self
    }
    
}

extension MentionsViewController:MenuViewControllerDelegate {
    internal func onToggleMenu() {
        delegate?.onToggleMenu()
    }
}

extension MentionsViewController: NewTweetDelegate {
    func newTweet(_ tweet: Tweet) {
        tableView.tweets.insert(tweet, at: 0)
        tableView.reloadData()
        let topIndexPath = IndexPath(row: 0, section: 0)
        tableView.scrollToRow(at: topIndexPath, at: .top, animated: true)
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

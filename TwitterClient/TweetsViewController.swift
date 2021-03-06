//
//  TweetsViewController.swift
//  TwitterClient
//
//  Created by Joshua Escribano on 10/28/16.
//  Copyright © 2016 Joshua. All rights reserved.
//

import UIKit
import CircularSpinner

class TweetsViewController: UIViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var tableView: TweetsTableView!
    internal weak var delegate: MenuViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tweetDelegate = self
        tableView.timeline = .home

        menuButton.target = self
        menuButton.action = #selector(onToggleMenu)
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

extension TweetsViewController: NewTweetDelegate {
    func newTweet(_ tweet: Tweet) {
        tableView.tweets.insert(tweet, at: 0)
        tableView.reloadData()
        let topIndexPath = IndexPath(row: 0, section: 0)
        tableView.scrollToRow(at: topIndexPath, at: .top, animated: true)
    }
}

extension TweetsViewController: TweetsTableViewDelegate {
    func didSelect(tweet: Tweet) {
        //
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

extension TweetsViewController: MenuViewControllerDelegate {
    
    func onToggleMenu() {
        delegate?.onToggleMenu()
    }
}

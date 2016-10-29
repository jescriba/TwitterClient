//
//  TweetsViewController.swift
//  TwitterClient
//
//  Created by Joshua Escribano on 10/28/16.
//  Copyright © 2016 Joshua. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    internal var tweets = [Tweet]()
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.insertSubview(refreshControl, at: 0)
        refreshControl.addTarget(self, action: #selector(loadTimeLine), for: .valueChanged)
        loadTimeLine()
    }
    
    @objc private func loadTimeLine() {
        refreshControl.beginRefreshing()
        TwitterClient.sharedInstance?.homeTimeline(success: {
            (tweets: [Tweet]) -> () in
                self.tweets = tweets
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }, failure: {
                (error: Error) -> () in
                // TODO
                print("Home timeline error \(error.localizedDescription)")
        })

    }
    
    @IBAction func onLogoutButton(_ sender: AnyObject) {
        TwitterClient.sharedInstance?.logout()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let tweetDetailVC = segue.destination as? TweetDetailViewController
        
        if let vc = tweetDetailVC {
            let cell = sender as! TweetCell
            vc.tweet = cell.tweet
        }
    }
    
}

extension TweetsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        cell.tweet = tweets[indexPath.row]
        
        return cell
    }
}

extension TweetsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

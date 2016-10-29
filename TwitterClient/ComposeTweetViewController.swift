//
//  ComposeTweetViewController.swift
//  TwitterClient
//
//  Created by Joshua Escribano on 10/28/16.
//  Copyright © 2016 Joshua. All rights reserved.
//

import UIKit

class ComposeTweetViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var charactersBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let user = User.currentUser {
            nameLabel.text = user.name
            screenNameLabel.text = user.screenName
            if let profileUrl = user.profileUrl {
                profileImageView.setImageWith(profileUrl)
            }
        }
        
        tweetTextView.delegate = self
    }
    
    @IBAction func onCancelButton(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTweetButton(_ sender: AnyObject) {
        // TODO
        let message = tweetTextView.text!
        TwitterClient.sharedInstance?.tweet(message, success: {
                () -> () in
                //
            }, failure: {
                (error: Error) -> () in
                //
        })
        dismiss(animated: true, completion: nil)
    }
}

extension ComposeTweetViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        // Remove placeholder
        textView.text = ""
        textView.textColor = UIColor.black
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text.characters.count > 140 {
            return false
        }
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        charactersBarButtonItem.title = "\(140 - textView.text.characters.count)"
    }
}

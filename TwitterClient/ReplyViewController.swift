//
//  ReplyViewController.swift
//  TwitterClient
//
//  Created by Joshua Escribano on 10/30/16.
//  Copyright © 2016 Joshua. All rights reserved.
//

import UIKit

class ReplyViewController: UIViewController {

    @IBOutlet weak var charactersBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var responseTextView: UITextView!
    weak var delegate: TweetsViewController?
    
    internal var respondingToTweet: Tweet? {
        didSet {
            guard profileImageView != nil else { return }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        responseTextView.delegate = self
        responseTextView.becomeFirstResponder()
        setupUI()
    }
    
    private func setupUI() {
        if let user = User.currentUser {
            if let profileUrl = user.profileUrl {
                profileImageView.setImageWith(profileUrl)
                profileImageView.layer.cornerRadius = 10
            }
        }
    }

    @IBAction func onReplyButton(_ sender: AnyObject) {
        let message = responseTextView.text!
        TwitterClient.sharedInstance?.reply(message, respondingToTweet: respondingToTweet!, success: {
            () -> () in
                let params = NSDictionary()
                params.setValue(message, forKey: "text")
                self.newTweet(Tweet(dictionary: params))
                self.navigationController?.popToRootViewController(animated: true)
            }, failure: {
                (error: Error) in
                self.present(Alert.controller(error: error), animated: true, completion: nil)
        })
    }
    
}

extension ReplyViewController: TweetsViewControllerDelegate {
    
    func newTweet(_ tweet: Tweet) {
        delegate?.newTweet(tweet)
    }
    
}

extension ReplyViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = "@\(respondingToTweet!.user!.screenName!) "
        charactersBarButtonItem.title = "\(140 - textView.text.characters.count)"
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text.isEmpty {
            return true
        }
        
        if textView.text.characters.count > 139 {
            return false
        }
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        charactersBarButtonItem.title = "\(140 - textView.text.characters.count)"
    }
}

//
//  LoginViewController.swift
//  TwitterClient
//
//  Created by Joshua Escribano on 10/26/16.
//  Copyright © 2016 Joshua. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLoginButton(_ sender: AnyObject) {
        TwitterClient.sharedInstance?.login(success: {
            () -> () in
                self.performSegue(withIdentifier: "HamburgerSegue", sender: self)
            }, failure: {
                (error: Error?) -> () in
                self.present(Alert.controller(error: error), animated: true, completion: nil)
        })
    }

}

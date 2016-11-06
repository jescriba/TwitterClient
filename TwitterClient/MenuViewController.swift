//
//  MenuViewController.swift
//  TwitterClient
//
//  Created by Joshua Escribano on 11/2/16.
//  Copyright © 2016 Joshua. All rights reserved.
//

import UIKit

enum Page:Int {
    case profile, timeline, mentions, logout
    
    func simpleDescription() -> String {
        switch self {
        case .profile:
            return "Profile"
        case .timeline:
            return "Timeline"
        case .mentions:
            return "Mentions"
        case .logout:
            return "Logout"
        }
    }
}

protocol MenuViewControllerDelegate {
    func onToggleMenu()
}

class MenuViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    internal var hamburgerViewController: HamburgerViewController!
    internal var viewControllers = [UIViewController]()
    private var timelineNavigationController: UINavigationController!
    private var profileNavigationController: UINavigationController!
    private var mentionsNavigationController: UINavigationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red:0.00, green:0.52, blue:1.00, alpha:1.0)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = view.backgroundColor
        tableView.tableFooterView = UIView()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        profileNavigationController = storyboard.instantiateViewController(withIdentifier: "ProfileNavigationController") as! UINavigationController
        (profileNavigationController.topViewController as! ProfileViewController).delegate = self
        viewControllers.append(profileNavigationController)
        
        timelineNavigationController = storyboard.instantiateViewController(withIdentifier: "TimelineNavigationController") as! UINavigationController
        (timelineNavigationController.topViewController as! TweetsViewController).delegate = self
        viewControllers.append(timelineNavigationController)
        
        mentionsNavigationController = storyboard.instantiateViewController(withIdentifier: "MentionsNavigationController") as! UINavigationController
        (mentionsNavigationController.topViewController as! MentionsViewController).delegate = self
        viewControllers.append(mentionsNavigationController)
        
        hamburgerViewController.contentViewController = timelineNavigationController
    }
    
    func onToggleMenu() {
        if hamburgerViewController.hasMenuOpen {
            hamburgerViewController.closeMenu()
        } else {
            hamburgerViewController.openMenu()
        }
    }

}

extension MenuViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuCell
        cell.title = Page(rawValue: index)!.simpleDescription()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
}

extension MenuViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
        
        if index == 3 {
            TwitterClient.sharedInstance?.logout()
        } else {
            hamburgerViewController.contentViewController = viewControllers[indexPath.row]
        }
    }
    
}

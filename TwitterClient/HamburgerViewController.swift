//
//  HamburgerViewController.swift
//  TwitterClient
//
//  Created by Joshua Escribano on 11/2/16.
//  Copyright © 2016 Joshua. All rights reserved.
//

import UIKit

class HamburgerViewController: UIViewController {
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var leftMarginConstraint: NSLayoutConstraint!
    private var openMenuMarginConstraint: CGFloat = 120
    internal var hasMenuOpen = false
    internal var menuViewController: MenuViewController! {
        didSet {
            view.layoutIfNeeded()
            
            menuViewController.willMove(toParentViewController: self)
            menuView.addSubview(menuViewController.view)
            menuViewController.didMove(toParentViewController: self)
        }
    }
    internal var contentViewController: UIViewController! {
        didSet(oldContentViewController) {
            view.layoutIfNeeded()
            
            if oldContentViewController != nil {
                oldContentViewController.willMove(toParentViewController: nil)
                oldContentViewController.view.removeFromSuperview()
                oldContentViewController.didMove(toParentViewController: nil)
            }
            
            contentViewController.willMove(toParentViewController: self)
            contentView.addSubview(contentViewController.view)
            contentViewController.didMove(toParentViewController: self)
            
            closeMenu()
        }
    }
    private var originalLeftMargin: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let menuViewController = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        menuViewController.hamburgerViewController = self
        self.menuViewController = menuViewController
        
        contentView.layer.shadowRadius = 10
        contentView.layer.shadowOpacity = 0.5
    }
    
    internal func openMenu() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
            self.leftMarginConstraint.constant = self.openMenuMarginConstraint
            self.view.layoutIfNeeded()
        }, completion: nil)
        hasMenuOpen = true
    }
    
    internal func closeMenu() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
            self.leftMarginConstraint.constant = 0
            self.view.layoutIfNeeded()
        }, completion: nil)
        hasMenuOpen = false
    }

    @IBAction func onPanGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        let velocity = sender.velocity(in: view)
        
        if sender.state == .began {
            originalLeftMargin = leftMarginConstraint.constant
        } else if sender.state == .changed {
            let newConstraint = originalLeftMargin + translation.x
            if newConstraint >= 0 && newConstraint < self.openMenuMarginConstraint + 20 {
                leftMarginConstraint.constant = originalLeftMargin + translation.x
            }
        } else if sender.state == .ended {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: velocity.x, options: .curveEaseIn, animations: {
                if velocity.x > 0 {
                    self.leftMarginConstraint.constant = self.openMenuMarginConstraint
                    self.hasMenuOpen = true
                } else {
                    self.leftMarginConstraint.constant = 0
                    self.hasMenuOpen = false
                }
            }, completion: nil)
        }
    }
}

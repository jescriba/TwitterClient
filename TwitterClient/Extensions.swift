//
//  Extensions.swift
//  TwitterClient
//
//  Created by Joshua Escribano on 11/6/16.
//  Copyright © 2016 Joshua. All rights reserved.
//

import UIKit
import Foundation

extension UIImageView {
    func blurView() -> UIVisualEffectView? {
        for subView in self.subviews {
            if subView is UIVisualEffectView {
                return subView as? UIVisualEffectView
            }
        }
        
        return nil
    }
    
    func addBlur() {
        let effect = UIBlurEffect(style: .light)
        let effectView = UIVisualEffectView(effect: effect)
        effectView.frame = self.frame
        effectView.layer.cornerRadius = 5
        effectView.clipsToBounds = true
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(effectView)
    }
    
    func removeBlur() {
        for subView in self.subviews {
            if subView is UIVisualEffectView {
                subView.removeFromSuperview()
            }
        }
    }
}

extension Int {
    // In pratice most users don't have billions of likes/retweets...yet
    func simpleDescription() -> String {
        switch self {
        case 1000...999999:
            let val = Double(self) / 1000.0
            return String(format: "%.01fK", val)
        case 1000000...999999999:
            let val = Double(self) / 1000000.0
            return String(format: "%.01fM", val)
        default:
            return"\(self)"
        }
    }
}

extension Date {
    func timeSinceDescription() -> String {
        let interval = -1 * self.timeIntervalSinceNow
        let mins = interval / 60
        let hours = interval / 3600
        let days = interval / (3600 * 24)
        
        if interval < 60 {
            return "\(Int(interval)) s"
        } else if mins < 60 {
            return "\(Int(mins)) m"
        } else if hours < 24 {
            return "\(Int(hours)) hr"
        } else if days < 7 {
            return "\(Int(days)) d"
        } else {
            return "wk+"
        }
    }
    func simpleDescription() -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/d/yy, HH:mm"
        return formatter.string(from: self)
    }
}


extension String {
    func urlEncode() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
}




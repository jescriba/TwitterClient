//
//  MenuCell.swift
//  TwitterClient
//
//  Created by Joshua Escribano on 11/2/16.
//  Copyright © 2016 Joshua. All rights reserved.
//

import UIKit

class MenuCell: UITableViewCell {
    internal var title: String? {
        didSet {            
            textLabel?.text = title
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        textLabel?.textColor = UIColor.white
        backgroundColor = UIColor(red:0.00, green:0.52, blue:1.00, alpha:1.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        let bgView = UIView()
        bgView.backgroundColor = UIColor(red:0.49, green:0.36, blue:1.00, alpha:1.0)
        selectedBackgroundView = bgView
    }

}

//
//  SearchTableViewCell.swift
//  labox
//
//  Created by 周依琳 on 2020/04/18.
//  Copyright © 2020 Yilin. All rights reserved.
//

import UIKit

protocol SearchUserTableViewCellDelegate {
    func didTapFollowButton(tableViewCell: UITableViewCell, button: UIButton)
}

class SearchTableViewCell: UITableViewCell {
    
    var delegate: SearchUserTableViewCellDelegate?
    
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var followButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func tapFollowButton(button: UIButton) {
        self.delegate?.didTapFollowButton(tableViewCell: self, button: button)
    }
    
}

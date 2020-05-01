//
//  Timeline_2_TableViewCell.swift
//  labox
//
//  Created by 周依琳 on 2020/04/18.
//  Copyright © 2020 Yilin. All rights reserved.
//

import UIKit

protocol Timeline_2_TableViewCellDelegate {
    func didTapLikeButton(tableViewCell: UITableViewCell, button: UIButton)
    func didTapMenuButton(tableViewCell: UITableViewCell, button: UIButton)
}

class Timeline_2_TableViewCell: UITableViewCell {
    
    var delegate: Timeline_2_TableViewCellDelegate?
    
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var doDateLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var up1ImageView: UIImageView!
    @IBOutlet var up2ImageView: UIImageView!
    @IBOutlet var countLikeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func like(button: UIButton) {
        self.delegate?.didTapLikeButton(tableViewCell: self, button: button)
    }

    @IBAction func openMenu(button: UIButton) {
        self.delegate?.didTapMenuButton(tableViewCell: self, button: button)
    }
    
}

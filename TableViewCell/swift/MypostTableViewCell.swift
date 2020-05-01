//
//  MypostTableViewCell.swift
//  labox
//
//  Created by 周依琳 on 2020/04/21.
//  Copyright © 2020 Yilin. All rights reserved.
//

import UIKit

protocol MyPostTableViewCellDelegate {
    func didTapLikeButton(tableViewCell: UITableViewCell, button: UIButton)
    func didTapMenuButton(tableViewCell: UITableViewCell, button: UIButton)
}
class MypostTableViewCell: UITableViewCell {
    
    var delegate: MyPostTableViewCellDelegate?
    
//    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var doDateLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var countLikeLabel: UILabel!
    @IBOutlet var likeButton: UIButton!

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

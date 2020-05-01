//
//  Post.swift
//  labox
//
//  Created by 周依琳 on 2020/04/17.
//  Copyright © 2020 Yilin. All rights reserved.
//

import UIKit

class Post: NSObject {

        var objectId: String
        var user: User
        var recorddate: String
        var title: String
        var share: Bool
        var imageUrl1: String
        var imageUrl2: String
        var imageUrl3: String
        var text: String
        var isLiked: Bool?
        var comments: [Comment]?
        var likeCount: Int = 0
        var createDate: Date
        var howmanyimages: Int = 0

    init(objectId: String, user: User, recorddate: String, share: Bool, title: String, text: String, createDate: Date, howmanyimages: Int, imageUrl1: String, imageUrl2: String, imageUrl3: String) {
            self.objectId = objectId
            self.user = user
            self.recorddate = recorddate
            self.share = share
            self.imageUrl1 = imageUrl1
            self.imageUrl2 = imageUrl2
            self.imageUrl3 = imageUrl3
            self.title = title
            self.text = text
            self.createDate = createDate
            self.howmanyimages = howmanyimages
        }
}

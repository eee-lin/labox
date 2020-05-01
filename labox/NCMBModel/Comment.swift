//
//  Comment.swift
//  labox
//
//  Created by 周依琳 on 2020/04/17.
//  Copyright © 2020 Yilin. All rights reserved.
//

import UIKit

class Comment: NSObject {

    var postId: String
    var user: User
    var text: String
    var createDate: Date
    var commentsCount: Int = 0

    init(postId: String, user: User, text: String, createDate: Date) {
        self.postId = postId
        self.user = user
        self.text = text
        self.createDate = createDate
    }
}

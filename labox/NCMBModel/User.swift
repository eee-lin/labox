//
//  User.swift
//  labox
//
//  Created by 周依琳 on 2020/04/17.
//  Copyright © 2020 Yilin. All rights reserved.
//

import UIKit

class User: NSObject {

    var objectId: String
    var userName: String
    var displayName: String? //?はもしかしたら最初からnilの可能性
    var introduction: String?
    var labname: String?
    var major: String?

    //初期値
    init(objectId: String, userName: String) {
        self.objectId = objectId
        self.userName = userName
    }
}

//
//  DataChange.swift
//  GetIndex
//
//  Created by 田畑 篤智 on 2021/02/13.
//

import Foundation
import FirebaseFirestore

class DataChange {
  var type: ChangeType
  var data: UserInfo
  var oldIndex: Int
  var newIndex: Int
  var listNum: Int
  
  init(_ type: ChangeType, data: UserInfo, oldIndex: Int, newIndex: Int, listNum: Int) {
    self.type = type
    self.data = data
    self.oldIndex = oldIndex
    self.newIndex = newIndex
    self.listNum = listNum
  }
}

enum ChangeType {
  case added
  case modified
  case removed
}

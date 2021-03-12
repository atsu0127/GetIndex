//
//  UserInfo.swift
//  GetIndex
//
//  Created by 田畑 篤智 on 2021/02/13.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

struct UserInfo: Codable, Identifiable, Hashable {
  @DocumentID var id: String?
  var name: String
  var birthDay: Timestamp
  
  enum CodingKeys: String, CodingKey {
    case id
    case name = "Name"
    case birthDay = "Birth_Day"
  }
}

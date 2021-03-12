//
//  ContentViewModel.swift
//  GetIndex
//
//  Created by 田畑 篤智 on 2021/02/13.
//

import Combine
import SwiftUI

class ContentViewModel: ObservableObject {
  
  @Published var users: [UserInfo] = []
  @Published var visibleUsers: [UserInfo] = []
  @Published var errMsg: String?
  @Published var isError: Bool = false
  @Published var isLoading: Bool = false
  private var userInfoReposiroty: UserInfoRepository = .init()
  private(set) lazy var onAppear: (UserInfo) ->Void = { [weak self] (user) in
    if let self = self {
      if self.users.isLast(user) && !self.isLoading {
        self.isLoading = true
        print("次を基準にセットを追加します -> \(user.name)")
        print("----------------")
        self.userInfoReposiroty.get(start: user, limit: 10) { (error) in
          if let error = error {
            switch error {
              case UserInfoRepositoryError.nodata:
                print("最終行に到達しました")
              default:
                print(error.localizedDescription)
                self.isError = true
                self.errMsg = "追加取得に失敗しました"
            }
          }
          self.isLoading = false
        }
      }
    }
  }
  
  init() {
    bind()
    self.userInfoReposiroty.get(limit: 10) { (error) in
      if let error = error {
        print(error.localizedDescription)
        self.isError = true
        self.errMsg = "初回取得に失敗しました"
      }
    }
  }
  
  func insert() {
    self.userInfoReposiroty.insert()
  }
  
  func bind() {
    self.userInfoReposiroty.$users
      .compactMap { (u) in
        print("usersの状態確認")
        u.forEach { (u) in
          print(u.name)
        }
        print("-------------")
        return u
      }
      .assign(to: &self.$users)
  }
}

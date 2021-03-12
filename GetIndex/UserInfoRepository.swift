//
//  UserInfoRepository.swift
//  GetIndex
//
//  Created by 田畑 篤智 on 2021/02/13.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

class UserInfoRepository: ObservableObject {
  private let path: String = "UserInfo"
  private let by: String = "Birth_Day"
  private let store = Firestore.firestore()
  
  @Published var users: [UserInfo] = []
  @Published var nestedUsers: [[UserInfo]] = []
  @Published var datachanges: [DataChange]  = []
  
  var listNum: Int = 0
  
  private var cancellables: Set<AnyCancellable> = []
  
  init() {
    self.$nestedUsers
      .sink { (uss) in
        let list: [UserInfo] = uss.flatMap { return $0 }
        self.users = list
      }
      .store(in: &cancellables)
    
    self.$datachanges
      .sink { (datachanges) in
        var _nestedUser: [[UserInfo]] = self.nestedUsers
        for d in datachanges {
          if _nestedUser.count == d.listNum {
            _nestedUser.append([])
          }
          print("----Before----")
          _nestedUser[d.listNum].forEach { (u) in
            print(u.name)
          }
          /*
           あるリストから他のリストへの移動はadd+delete
           同リスト内ならmodify
           */
          switch d.type {
            case .added:
              print("do add -> \(d.data.name)")
              print("newIndex: \(d.newIndex), oldIndex: \(d.oldIndex)")
              _nestedUser[d.listNum].insert(d.data, at: d.newIndex)
            case .modified:
              print("do modify -> \(d.data.name)")
              print("newIndex: \(d.newIndex), oldIndex: \(d.oldIndex)")
              if d.newIndex == d.oldIndex {
                _nestedUser[d.listNum][d.oldIndex] = d.data
              } else {
                _nestedUser[d.listNum].remove(at: d.oldIndex)
                _nestedUser[d.listNum].insert(d.data, at: d.newIndex)
              }
            case .removed:
              print("do remove -> \(d.data.name)")
              print("newIndex: \(d.newIndex), oldIndex: \(d.oldIndex)")
              _nestedUser[d.listNum].remove(at: d.oldIndex)
          }
          print("----After-----")
          _nestedUser[d.listNum].forEach { (u) in
            print(u.name)
          }
        }
        self.nestedUsers = _nestedUser
      }
      .store(in: &cancellables)
  }
  
  public func insert() {
    (0...100).forEach({ (i) in
      let year = Int.random(in: 1990...2000)
      let birthday = Calendar(identifier: .gregorian).date(from: DateComponents(year: year, month: 1, day: 1))!
      let user = UserInfo(name: "Name\(i)", birthDay: Timestamp(date: birthday))
      do {
        try store.collection(self.path).document().setData(from: user)
      } catch {
        print(error.localizedDescription)
      }
    })
  }
  
  public func get(start: UserInfo? = nil, limit: Int, completion: @escaping (Error?) -> ()) {
    var query = store.collection(self.path).order(by: self.by)
    
    if let start = start {
      store.collection(self.path).document(start.id!).getDocument { (first, error) in
        if let error = error {
          completion(error)
        }
        
        guard let first = first else {
          completion(UserInfoRepositoryError.empty)
          return
        }
        
        query = query.start(afterDocument: first)
        
        query.limit(to: limit).getDocuments(completion: { (last, error) in
          if let error = error {
            completion(error)
          }
          
          guard let last = last?.documents.last else {
            completion(UserInfoRepositoryError.nodata)
            return
          }
          
          let num = self.listNum
          self.listNum += 1
          query.end(atDocument: last).addSnapshotListener { (snapshot, error) in
            self.getHelper(snapshot, error: error, startAt: first, endAt: last, listNum: num, completion: completion)
          }
        })
      }
    } else {
      store.collection(self.path).order(by: self.by).limit(to: limit).getDocuments { (last, error) in
        if let error = error {
          completion(error)
        }
        
        guard let last = last?.documents.last else {
          completion(UserInfoRepositoryError.empty)
          return
        }
        
        let num = self.listNum
        self.listNum += 1
        
        self.store.collection(self.path).order(by: self.by).end(atDocument: last).addSnapshotListener { (snapshot, error) in
          self.getHelperFirst(snapshot, error: error, endAt: last, listNum: num, completion: completion)
        }
      }
    }
  }
  
  private func getHelperFirst(_ snapshot: QuerySnapshot?,
                              error: Error?,
                              endAt: QueryDocumentSnapshot,
                              listNum: Int,
                              completion: @escaping (Error?) -> ()) {
    print("++++++start closure: initial, endAt(\(try! endAt.data(as: UserInfo.self)!.name))++++++")
    if let error = error {
      completion(error)
      return
    }
    guard let snapshot = snapshot else {
      completion(UserInfoRepositoryError.nodata)
      return
    }
    self.datachanges = snapshot.documentChanges.compactMap({ (documentchange) -> DataChange in
      var changeType: ChangeType
      switch documentchange.type {
        case .added:
          print("added")
          changeType = .added
        case .modified:
          print("modified")
          changeType = .modified
        case .removed:
          print("removed")
          changeType = .removed
      }
      let u = try! documentchange.document.data(as: UserInfo.self)!
      print(u.name)
      print("listNum -> \(listNum)")
      print("-------------------------")
      return DataChange(changeType, data: u, oldIndex: Int(documentchange.oldIndex), newIndex: Int(documentchange.newIndex), listNum: listNum)
    })
    completion(nil)
  }
  
  private func getHelper(_ snapshot: QuerySnapshot?,
                         error: Error?,
                         startAt: DocumentSnapshot,
                         endAt: QueryDocumentSnapshot,
                         listNum: Int,
                         completion: @escaping (Error?) -> ()) {
    print("++++++start closure: first(\(try! startAt.data(as: UserInfo.self)!.name)), last(\(try! endAt.data(as: UserInfo.self)!.name))++++++")
    if let error = error {
      completion(error)
    }
    
    guard let snapshot = snapshot else {
      completion(UserInfoRepositoryError.nodata)
      return
    }
    
    self.datachanges = snapshot.documentChanges.compactMap({ (documentchange) -> DataChange in
      var changeType: ChangeType
      switch documentchange.type {
        case .added:
          print("added")
          changeType = .added
        case .modified:
          print("modified")
          changeType = .modified
        case .removed:
          print("removed")
          changeType = .removed
      }
      let u = try! documentchange.document.data(as: UserInfo.self)!
      print(u.name)
      print("listNum -> \(listNum)")
      print("-------------------------")
      return DataChange(changeType, data: u, oldIndex: Int(documentchange.oldIndex), newIndex: Int(documentchange.newIndex), listNum: listNum)
    })
    completion(nil)
  }
}

enum UserInfoRepositoryError: Error {
  case empty
  case nodata
  
  var localizedDescription: String {
    switch self {
      case .empty:
        return "リストが空です"
      case .nodata:
        return "これ以上データがありません"
    }
  }
}

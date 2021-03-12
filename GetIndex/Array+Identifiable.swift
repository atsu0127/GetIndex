//
//  Array+Identifiable.swift
//  GetIndex
//
//  Created by 田畑 篤智 on 2021/02/13.
//

import Foundation

extension Array where Self.Element: Identifiable {
  public func isLast<Item: Identifiable>(_ item: Item) -> Bool {
    guard !self.isEmpty else {
      return false
    }
    
    guard let itemIdx = self.lastIndex(where: { (i) -> Bool in return AnyHashable(i.id) == AnyHashable(item.id) }) else {
      return false
    }
    
    let distance = self.distance(from: itemIdx, to: self.endIndex)
    return distance == 1
  }
  
  public mutating func removeFirst<Item: Identifiable>(_ item: Item) {
    guard !self.isEmpty else {
      return
    }
    
    let result = self
    
    for i in result.enumerated() {
      if AnyHashable(i.element.id) == AnyHashable(item.id) {
        self.remove(at: i.offset)
      }
    }
  }
}

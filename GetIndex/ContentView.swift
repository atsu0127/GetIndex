//
//  ContentView.swift
//  GetIndex
//
//  Created by 田畑 篤智 on 2021/02/12.
//

import SwiftUI

struct ContentView: View {
  @StateObject var contentViewModel: ContentViewModel = .init()
  
  var body: some View {
    GeometryReader { geo in
      ScrollView {
        List {
          Button("Insert", action: {self.contentViewModel.insert()})
          ForEach(self.contentViewModel.users) { user in
            VStack {
              Text(user.name)
              Text(user.birthDay.dateValue().description)
            }
            .frame(height: 150, alignment: .center)
            .onAppear(perform: {
              self.contentViewModel.onAppear(user)
            })
          }
        }
        .frame(width: geo.size.width, height: geo.size.height)
      }
      .alert(isPresented: self.$contentViewModel.isError) { () -> Alert in
        Alert(title: Text("エラー発生"), message: Text(self.contentViewModel.errMsg!))
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

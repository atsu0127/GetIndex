//
//  GetIndexApp.swift
//  GetIndex
//
//  Created by 田畑 篤智 on 2021/02/12.
//

import SwiftUI
import Firebase
import UIKit

@main
struct GetIndexApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

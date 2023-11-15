//
//  IrishPokerApp.swift
//  IrishPoker
//
//  Created by Jeremy Manlangit on 11/11/23.
//

import SwiftUI

@main
struct IrishPokerApp: App {
    var body: some Scene {
        WindowGroup {
//            PlayerView()
            PlayerView(player: Player.test1)
//            GiveTakeView()
//            WaitView()
        }
    }
}

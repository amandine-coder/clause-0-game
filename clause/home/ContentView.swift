//
//  ContentView.swift
//  clause
//
//  Created by Amandine on 23/03/26.
//

import SwiftUI

struct ContentView: View {
    @State private var gameStarted = false

    var body: some View {
        if gameStarted {
            GameView(onQuit: { gameStarted = false })
        } else {
            SplashView(gameStarted: $gameStarted)
        }
    }
}

#Preview(traits: .landscapeLeft) {
    ContentView()
}

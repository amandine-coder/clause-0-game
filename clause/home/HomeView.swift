//
//  HomeView.swift
//  clause
//
//  Created by Amandine on 23/03/26.
//
import SwiftUI

struct HomeView: View {

    @Binding var gameStarted: Bool

    @State private var showRumour = true
    @State private var rumourOpacity: Double = 0
    @State private var homeOpacity: Double = 0

    var body: some View {
        ZStack {

            // ── ÉCRAN RUMEUR ──────────────────────────────────────
            if showRumour {
                ZStack {
                    Color.black.ignoresSafeArea()

                    VStack(alignment: .leading, spacing: 28) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("They say a game has been going around.")
                                .font(.system(size: 30, design: .monospaced))
                                .foregroundColor(Color(hex: "cccccc"))
                            Text("People who play it stop responding.")
                                .font(.system(size: 30, design: .monospaced))
                                .foregroundColor(.white)
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("A friend sends you a link.")
                                .font(.system(size: 30, design: .monospaced))
                                .foregroundColor(Color(hex: "cccccc"))
                            Text("You just click.")
                                .font(.system(size: 30, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 80)
                    .opacity(rumourOpacity)
                }
                .onAppear {
                    // Rumeur apparaît
                    withAnimation(.easeIn(duration: 1.5)) { rumourOpacity = 1 }

                    // Rumeur disparaît → HomeView apparaît en fondu enchaîné
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
                        withAnimation(.easeInOut(duration: 1.5)) { rumourOpacity = 0 }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                        showRumour = false
                        withAnimation(.easeInOut(duration: 1.5)) { homeOpacity = 1 }
                    }
                }
            }

            // ── HOME VIEW ─────────────────────────────────────────
            if !showRumour {
                ZStack {
                    Image("home")
                        .resizable()
                        .ignoresSafeArea()

                    VStack {
                        Spacer()
                        Button(action: {
                            gameStarted = true
                        }) {
                            Text("START")
                                .font(.custom("Avenir Next", size: 32))
                                .foregroundColor(.white)
                                .padding(.horizontal, 60)
                                .padding(.vertical, 20)
                                .background(Color.black)
                                .cornerRadius(30)
                        }
                        .padding(.bottom, 130)
                    }
                }
                .opacity(homeOpacity)
            }
        }
    }
}

#Preview(traits: .landscapeLeft) {
    HomeView(gameStarted: .constant(false))
}

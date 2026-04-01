//
//  SplashView.swift
//  clause
//
//  Created by Amandine on 30/03/26.
//
import SwiftUI

struct SplashView: View {

    @Binding var gameStarted: Bool

    @State private var step = 0
    // 0 = logo studio
    // 1 = titre jeu
    // 2 = homeview

    @State private var logoOpacity: Double = 0
    @State private var titleOpacity: Double = 0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // ── ÉCRAN 1 — Logo studio ──
            if step == 0 {
                VStack(spacing: 12) {
                    Image("logo-")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200)
                        
                    Text("design by amb studio")
                        .font(.system(size: 40, weight: .light, design: .monospaced))
                        .foregroundColor(.white)
                        .kerning(2)
                }
                .opacity(logoOpacity)
            }

            // ── ÉCRAN 2 — Titre du jeu ──
            if step == 1 {
                Image("clause0")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 500)
                    .opacity(titleOpacity)
            }

            // ── ÉCRAN 3 — HomeView ──
            if step == 2 {
                HomeView(gameStarted: $gameStarted)
                    .transition(.opacity)
            }
        }
        .onAppear {
            // Logo studio apparaît
            withAnimation(.easeIn(duration: 1)) { logoOpacity = 1 }

            // Logo disparaît → titre apparaît
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeOut(duration: 0.8)) { logoOpacity = 0 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
                step = 1
                withAnimation(.easeIn(duration: 1.2)) { titleOpacity = 1 }
            }

            // Titre disparaît → HomeView
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
                withAnimation(.easeOut(duration: 0.8)) { titleOpacity = 0 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 6.3) {
                withAnimation(.easeIn(duration: 1)) { step = 2 }
            }
        }
    }
}

#Preview(traits: .landscapeLeft) {
    SplashView(gameStarted: .constant(false))
}

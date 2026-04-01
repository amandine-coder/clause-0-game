//
//  DialogueView.swift
//  clause
//
//  Created by Amandine on 27/03/26.
//
import SwiftUI

struct DialogueView: View {

    let dialogues: [String]
    let portraits: [String]
    let onComplete: () -> Void

    @State private var currentIndex = 0
    @State private var displayedText = ""
    @State private var isTyping = false
    @State private var pulseOpacity: Double = 1.0

    var body: some View {
        ZStack {
            // ── Overlay sombre — montre clairement que c'est interactif ──
            Color.black.opacity(0.25)
                .ignoresSafeArea()
                .onTapGesture { handleTap() }

            VStack {
                Spacer()

                HStack(alignment: .bottom, spacing: 10) {

                    // Portrait
                    Image(portraits[currentIndex])
                        .resizable()
                        .scaledToFill()
                        .frame(width: 180, height: 200)
                        .clipped()
                        .offset(y: 20)

                    // Texte
                    Text(displayedText)
                        .foregroundColor(.white)
                        .font(.system(size: 30))
                        .padding(.bottom, 30)
                        .padding(.trailing, !isTyping ? 30 : 0)

                    // Indicateur tap — point qui pulse quand le texte est fini
                    if !isTyping {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 8, height: 8)
                            .opacity(pulseOpacity)
                            .onAppear {
                                withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                                    pulseOpacity = 0.2
                                }
                            }
                            .padding(.bottom, 35)
                    }
                }
                .padding(20)
                // ── Bulle qui pulse légèrement pour indiquer l'interactivité ──
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(hex: "1e1e1e").opacity(0.35))
                        .shadow(color: .white.opacity(isTyping ? 0 : 0.08), radius: 12)
                )
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
                .onTapGesture { handleTap() }
            }
        }
        .onAppear { startTyping() }
    }

    func handleTap() {
        if isTyping {
            displayedText = dialogues[currentIndex]
            isTyping = false
        } else {
            if currentIndex < dialogues.count - 1 {
                pulseOpacity = 1.0
                currentIndex += 1
                startTyping()
            } else {
                onComplete()
            }
        }
    }

    func startTyping() {
        displayedText = ""
        isTyping = true
        let text = dialogues[currentIndex]
        let capturedIndex = currentIndex

        for (index, character) in text.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.04) {
                guard currentIndex == capturedIndex else { return }
                guard displayedText.count == index else { return }
                displayedText += String(character)
                if displayedText == text { isTyping = false }
            }
        }
    }
}

#Preview("Intro Alex", traits: .landscapeLeft) {
    DialogueView(
        dialogues: ["Done.", "Finally done.", "I just need one hour to not think about anything."],
        portraits: ["alex_neutre", "alex_neutre", "alex_neutre"],
        onComplete: {}
    )
}

#Preview("Spirit Final", traits: .landscapeLeft) {
    DialogueView(
        dialogues: [
            "...", "No.", "No that's not — that can't be legal.",
            "You clicked ACCEPT.", "this is a game. this isn't real.",
            "Haru thought the same thing.", "what did you do to her",
            "What she agreed to.", "I want out. I want out right now.",
            "Section 11. No termination clause.", "STOP.",
            "...", "You should have read it."
        ],
        portraits: [
            "alex_inquiet","alex_inquiet","alex_inquiet",
            "spirit","alex_stresse","spirit",
            "alex_inquiet","spirit","alex_stresse",
            "spirit","alex_stresse","spirit","spirit"
        ],
        onComplete: {}
    )
}

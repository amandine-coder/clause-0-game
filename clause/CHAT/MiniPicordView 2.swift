//
//  MiniPicordView 2.swift
//  clause 0
//
//  Created by Amandine on 01/04/26.
//

import SwiftUI

struct MiniPicordView: View {

    @Binding var messages: [Message]
    let exchanges: [Exchange]
    let onComplete: () -> Void
    var onLinkTap: (() -> Void)? = nil

    @State private var currentExchange = 0
    @State private var conversationDone = false
    @State private var showChoice = false
    @State private var choiceText = ""
    @State private var dragOffset = CGSize.zero
    @State private var position = CGPoint(x: 750, y: 350)
    @State private var showTyping = false
    @State private var showLinkPulse = false

    enum Step { case alexIntro, haruResponse, alexChoice }
    @State private var currentStep: Step = .alexIntro

    var body: some View {
        VStack(spacing: 0) {

            // ── Topbar ──
            ZStack {
                Image("barrename")
                    .resizable()
                    .frame(width: 600)
                    .frame(height: 70)
                    .offset(y: -18)

                VStack {
                    HStack(spacing: 8) {
                        Circle().fill(Color(hex: "ff5f57")).frame(width: 12, height: 12)
                        Circle().fill(Color(hex: "febc2e")).frame(width: 12, height: 12)
                        Circle().fill(Color(hex: "28c840")).frame(width: 12, height: 12)
                        Spacer()
                        Text("Haru")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)
                        Spacer()
                        HStack(spacing: 8) {
                            Circle().fill(Color.clear).frame(width: 12, height: 12)
                            Circle().fill(Color.clear).frame(width: 12, height: 12)
                            Circle().fill(Color.clear).frame(width: 12, height: 12)
                        }
                    }
                    .padding(-20)
                }
                .padding(.horizontal, 95)
            }
            .gesture(DragGesture()
                .onChanged { value in
                    position = CGPoint(
                        x: position.x + value.translation.width - dragOffset.width,
                        y: position.y + value.translation.height - dragOffset.height
                    )
                    dragOffset = value.translation
                }
                .onEnded { _ in dragOffset = .zero }
            )

            // ── Messages ──
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(messages) { message in
                            HStack(alignment: .bottom, spacing: 6) {
                                if message.isAlex { Spacer() }
                                if !message.isAlex && message.text.contains("[lien]") {
                                    VStack(alignment: .leading, spacing: 4) {
                                        let parts = message.text.components(separatedBy: "[lien]")
                                        if let before = parts.first, !before.trimmingCharacters(in: .whitespaces).isEmpty {
                                            Text(before)
                                                .font(.system(size: 16))
                                                .foregroundColor(.black)
                                        }

                                        // ── Bouton CLAUSE 0 avec pulse ──
                                        ZStack {
                                            // Ring pulse
                                            if showLinkPulse {
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.white.opacity(0.5), lineWidth: 2)
                                                    .scaleEffect(showLinkPulse ? 1.18 : 1.0)
                                                    .opacity(showLinkPulse ? 0 : 0.6)
                                                    .animation(
                                                        .easeOut(duration: 1.1).repeatForever(autoreverses: false),
                                                        value: showLinkPulse
                                                    )
                                            }

                                            Button(action: { onLinkTap?() }) {
                                                Text("CLAUSE 0")
                                                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                                                    .foregroundColor(.white)
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 6)
                                                    .background(Color.black)
                                                    .cornerRadius(8)
                                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.7), lineWidth: 1))
                                            }
                                            .buttonStyle(.plain)
                                        }
                                        .onAppear {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                showLinkPulse = true
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(RoundedRectangle(cornerRadius: 18).fill(Color(hex: "e8e8e8")))
                                    .frame(maxWidth: 400, alignment: .leading)
                                } else {
                                    Text(message.text)
                                        .font(.system(size: 16))
                                        .foregroundColor(message.isAlex ? .white : .black)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 18)
                                                .fill(message.isAlex
                                                      ? Color(hex: "2a6ef5")
                                                      : Color(hex: "e8e8e8"))
                                        )
                                        .frame(maxWidth: 400, alignment: message.isAlex ? .trailing : .leading)
                                }
                                if !message.isAlex { Spacer() }
                            }
                            .id(message.id)
                        }

                        // ── Typing indicator ──
                        if showTyping {
                            HStack(alignment: .bottom, spacing: 6) {
                                TypingIndicator()
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                }
                // ── Hauteur augmentée à 300 ──
                .frame(height: 300)
                .clipped()
                .background(Color(hex: "1a1a1a"))
                .onChange(of: messages.count) {
                    if let last = messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }

            Rectangle().fill(Color(hex: "2a2a2a")).frame(height: 1)

            // ── Zone de réponse — toujours visible ──
            ZStack {
                Color(hex: "141414")

                if showChoice {
                    Button(action: { sendChoice() }) {
                        HStack {
                            Spacer()
                            Text(choiceText)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(RoundedRectangle(cornerRadius: 18).fill(Color(hex: "2a6ef5")))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                    }
                    .buttonStyle(.plain)
                } else {
                    HStack {
                        Spacer()
                        Text("tap to reply")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "444444"))
                        Spacer()
                    }
                    .padding(.vertical, 14)
                }
            }
            .frame(height: 100)

            if conversationDone {
                Color.clear.onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        onComplete()
                    }
                }
                .frame(width: 0, height: 0)
            }
        }
        .frame(width: 480)
        .background(Color(hex: "1a1a1a"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
        .shadow(color: .black.opacity(0.6), radius: 30, x: 0, y: 10)
        .position(position)
        .onAppear { playCurrentExchange() }
    }

    func playCurrentExchange() {
        guard currentExchange < exchanges.count else {
            conversationDone = true
            return
        }
        let ex = exchanges[currentExchange]

        if let intro = ex.alexIntro, let first = intro.first {
            choiceText = first
            showChoice = true
            currentStep = .alexIntro
        } else {
            showHaruMessage()
        }
    }

    func showHaruMessage() {
        guard currentExchange < exchanges.count else {
            conversationDone = true
            return
        }
        let ex = exchanges[currentExchange]
        showTyping = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            showTyping = false
            addMessage(ex.haruMessage, isAlex: false)
            currentStep = .haruResponse
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                showAlexChoice()
            }
        }
    }

    func showAlexChoice() {
        guard currentExchange < exchanges.count else {
            conversationDone = true
            return
        }
        let ex = exchanges[currentExchange]
        if let choice = ex.choices.first {
            choiceText = choice
            showChoice = true
            currentStep = .alexChoice
        } else {
            currentExchange += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                playCurrentExchange()
            }
        }
    }

    func sendChoice() {
        showChoice = false
        addMessage(choiceText, isAlex: true)

        if currentStep == .alexIntro {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                showHaruMessage()
            }
        } else {
            currentExchange += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                playCurrentExchange()
            }
        }
    }

    func addMessage(_ text: String, isAlex: Bool) {
        messages.append(Message(text: text, isAlex: isAlex))
    }
}

struct TypingIndicator: View {
    @State private var animate = false

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { i in
                Circle()
                    .fill(Color(hex: "888888"))
                    .frame(width: 8, height: 8)
                    .offset(y: animate ? -4 : 0)
                    .animation(
                        .easeInOut(duration: 0.4)
                            .repeatForever()
                            .delay(Double(i) * 0.15),
                        value: animate
                    )
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 18).fill(Color(hex: "e8e8e8")))
        .onAppear { animate = true }
    }
}

#Preview("Haru — intro", traits: .landscapeLeft) {
    ZStack {
        Color(hex: "3d3533").ignoresSafeArea()
        MiniPicordView(
            messages: .constant([]),
            exchanges: [
                Exchange(
                    alexIntro: nil,
                    haruMessage: "hey. found something. don't ask questions just try it. [lien]",
                    choices: ["...ok ?"]
                ),
                Exchange(
                    alexIntro: nil,
                    haruMessage: "just tap on CLAUSE 0 to open it 🖤",
                    choices: []
                )
            ],
            onComplete: {},
            onLinkTap: {}
        )
    }
}

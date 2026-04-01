//import SwiftUI
//
//struct ComputerView: View {
//
//    @State private var showIntroDialogue = true
//    @State private var showNotification = false   // bulle de notif Picord
//    @State private var notificationDismissed = false
//    @State private var showEnding = false
//    @State private var endingTextOpacity: Double = 0
//    @State private var isPicordOpen = false
//    @State private var isBrowserOpen = false
//    @State private var picordMessages: [Message] = []
//
//    // Acte 1 — conversation avec Haru avant le jeu
//    let acte1: [Exchange] = [
//        Exchange(
//            alexIntro: nil,
//            haruMessage: "hey did you start the group project? we have one week left 😬",
//            choices: ["yeah i'm on it, don't worry"]
//        ),
//        Exchange(
//            alexIntro: nil,
//            haruMessage: "sure you are 😂 wanna work on it together tomorrow?",
//            choices: ["yeah sounds good"]
//        ),
//        Exchange(
//            alexIntro: nil,
//            haruMessage: "also did you even eat today? you always skip lunch 🙄",
//            choices: ["i had something"]
//        ),
//        Exchange(
//            alexIntro: nil,
//            haruMessage: "classic 🙄 anyway — found this weird little game. here: [lien]",
//            choices: ["a game? ok i'll check it out"]
//        ),
//        Exchange(
//            alexIntro: nil,
//            haruMessage: "just try it. tell me what you think 🙂",
//            choices: []
//        ),
//    ]
//
//    var body: some View {
//        ZStack {
//            // Bureau
//            Color(hex: "6b6b6b").ignoresSafeArea()
//
//            // Fichiers
//            FileIconView(emoji: "📄", fileName: "project_notes.pdf").position(x: 100, y: 200)
//            FileIconView(emoji: "📝", fileName: "homework.txt").position(x: 150, y: 350)
//            FileIconView(emoji: "🖼️", fileName: "haru_photo.jpg").position(x: 80, y: 450)
//
//            // ── BROWSER — fenêtre flottante centrée ──
//            if isBrowserOpen {
//                BrowserView(
//                    isOpen: $isBrowserOpen,
//                    messages: $picordMessages,
//                    onComplete: {
//                        isBrowserOpen = false
//                        showEnding = true
//                    }
//                )
//                .transition(.opacity)
//                .animation(.easeIn(duration: 0.3), value: isBrowserOpen)
//            }
//
//            // ── DOCK — toujours au dessus ──
//            if !isBrowserOpen {
//                VStack {
//                    Spacer()
//                    HStack(spacing: 20) {
//                        Button(action: {
//                            guard !showIntroDialogue else { return }
//                            withAnimation(.spring()) { isPicordOpen = true }
//                        }) {
//                            ZStack(alignment: .topTrailing) {
//                                Image("icon_picord").resizable().frame(width: 60, height: 60)
//                                Circle().fill(Color.red).frame(width: 15, height: 15)
//                                    .overlay(
//                                        Text("1").font(.system(size: 11, weight: .bold)).foregroundColor(.white)
//                                    )
//                                    .offset(x: 5, y: -5)
//                            }
//                        }
//                        .buttonStyle(.plain)
//                        Image("icon_cloud").resizable().frame(width: 60, height: 60)
//                        Image("icon_trash").resizable().frame(width: 60, height: 60)
//                    }
//                    .padding(.horizontal, 30)
//                    .padding(.vertical, 15)
//                    .background(Color(hex: "524d4c"))
//                    .cornerRadius(20)
//                }
//            }
//
//            // ── NOTIFICATION PICORD — bulle en bas à droite ──
//            if showNotification && !isPicordOpen && !isBrowserOpen {
//                VStack(alignment: .trailing, spacing: 6) {
//                    Spacer()
//                    HStack(spacing: 12) {
//                        Spacer()
//                        Button(action: {
//                            withAnimation(.spring()) {
//                                showNotification = false
//                                isPicordOpen = true
//                            }
//                        }) {
//                            HStack(spacing: 10) {
//                                Circle()
//                                    .fill(Color(hex: "3a3a3a"))
//                                    .frame(width: 40, height: 40)
//                                    .overlay(Text("H").font(.system(size: 18, weight: .bold)).foregroundColor(.white))
//                                VStack(alignment: .leading, spacing: 2) {
//                                    Text("Haru")
//                                        .font(.system(size: 13, weight: .semibold))
//                                        .foregroundColor(.white)
//                                    Text("just try it. tell me what you think 🙂")
//                                        .font(.system(size: 12))
//                                        .foregroundColor(Color(hex: "aaaaaa"))
//                                        .lineLimit(1)
//                                }
//                            }
//                            .padding(.horizontal, 16)
//                            .padding(.vertical, 12)
//                            .background(Color(hex: "2a2a2a"))
//                            .cornerRadius(16)
//                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.1), lineWidth: 1))
//                            .shadow(color: .black.opacity(0.4), radius: 20)
//                        }
//                        .buttonStyle(.plain)
//                        .padding(.trailing, 30)
//                    }
//                    .padding(.bottom, 120)
//                }
//                .transition(.move(edge: .trailing).combined(with: .opacity))
//                .animation(.spring(), value: showNotification)
//            }
//
//            // ── MINI PICORD — fenêtre flottante acte 1 ──
//            if isPicordOpen && !isBrowserOpen {
//                MiniPicordView(
//                    messages: $picordMessages,
//                    exchanges: acte1,
//                    onComplete: { },
//                    onLinkTap: {
//                        withAnimation { isPicordOpen = false }
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                            isBrowserOpen = true
//                        }
//                    }
//                )
//                .transition(.scale(scale: 0.9).combined(with: .opacity))
//                .animation(.spring(), value: isPicordOpen)
//            }
//
//            // ── ENDING — rectangle noir plein écran par dessus tout ──
//            if showEnding {
//                ZStack {
//                    Color.black.ignoresSafeArea()
//                    Text("You should have read it.")
//                        .font(.system(size: 28, weight: .medium, design: .monospaced))
//                        .foregroundColor(.white)
//                        .multilineTextAlignment(.center)
//                        .opacity(endingTextOpacity)
//                }
//                .onAppear {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//                        withAnimation(.easeIn(duration: 2)) { endingTextOpacity = 1.0 }
//                    }
//                    // Retour à HomeView après 7 secondes
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
//                        withAnimation(.easeOut(duration: 1)) {
//                            showEnding = false
//                            showIntroDialogue = true
//                            isPicordOpen = false
//                            isBrowserOpen = false
//                            picordMessages = []
//                            endingTextOpacity = 0
//                        }
//                    }
//                }
//            }
//
//            // ── DIALOGUE INTRO — par dessus tout ──
//            if showIntroDialogue {
//                DialogueView(
//                    dialogues: [
//                        "Finally done with classes.",
//                        "Still have to finish that group project with Haru...",
//                        "Oh. She texted."
//                    ],
//                    portraits: ["alex_neutre", "alex_neutre", "alex_neutre"],
//                    onComplete: {
//                        showIntroDialogue = false
//                        // Petite notification Picord apparaît sur le bureau
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                            showNotification = true
//                        }
//                    }
//                )
//            }
//        }
//    }
//}
//
//#Preview(traits: .landscapeLeft) {
//    ComputerView()
//}

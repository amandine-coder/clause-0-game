//import SwiftUI
//
//enum BrowserState {
//    case loading
//    case home
//    case contract
//    case game
//    case ending  // déclenche onComplete → ComputerView prend le relais
//}
//
//struct BrowserView: View {
//
//    @Binding var isOpen: Bool
//    @Binding var messages: [Message]
//    let onComplete: () -> Void
//
//    @State private var browserState: BrowserState = .loading
//    @State private var loadingProgress: CGFloat = 0
//    @State private var contractDialogueDone = false
//
//    // Enigmes
//    @State private var enigmaStarted = false
//    @State private var showEnigmaContent = false
//    @State private var showContinueScreen = false
//    @State private var continueWord = ""
//    @State private var continueIndex = 0
//
//    // DialogueView overlay
//    @State private var showDialogue = false
//    @State private var dialogueTexts: [String] = []
//    @State private var dialoguePortraits: [String] = []
//    @State private var afterDialogue: (() -> Void)?
//
//    // Picord overlay
//    @State private var showPicord = false
//    @State private var picordExchanges: [Exchange] = []
//    @State private var afterPicord: (() -> Void)?
//    // Messages locaux pour les Picord in-game (séparés de l'acte 1 dans ComputerView)
//    @State private var inGameMessages: [Message] = []
//
//    // Fin
//    @State private var showSpiritDialogue = false
//    @State private var showBlackContinue = false
//    @State private var spiritPhase = 0  // 0 = intro esprit, 1 = conclusion esprit
//
//    // ─────────────────────────────────────────────────────────────
//    // TEXTES — PICORD IN-GAME
//    // ─────────────────────────────────────────────────────────────
//
//    // Après enigma 1 — READ
//    let picordAfterEnigma1: [Exchange] = [
//        Exchange(
//            alexIntro: ["hey so the first word is READ. what's the point of this game?"],
//            haruMessage: "keep going",
//            choices: ["ok...?"]
//        ),
//    ]
//
//    // Après enigma 2 — CONTRACT
//    let picordAfterEnigma2: [Exchange] = [
//        Exchange(
//            alexIntro: ["READ, CONTRACT. haru what is this game actually"],
//            haruMessage: "you're starting to understand",
//            choices: ["understand what??"]
//        ),
//        Exchange(
//            alexIntro: nil,
//            haruMessage: "keep playing",
//            choices: []
//        ),
//    ]
//
//    // Après enigma 3 — DATA
//    // ⚠️ IMPORTANT : Haru dit "Alex." ici — c'est ce qui déclenche le doute
//    // Le joueur DOIT voir ce message avant que Alex réagisse dans DialogueView
//    let picordAfterEnigma3: [Exchange] = [
//        Exchange(
//            alexIntro: ["haru what is going on with this game"],
//            haruMessage: "keep playing.",   // premier message normal
//            choices: ["what does that even mean"]
//        ),
//        Exchange(
//            alexIntro: nil,
//            haruMessage: "just play, Alex.",  // ← ici elle dit son prénom — moment clé
//            choices: []                        // pas de choix — le joueur voit et laisse le choc s'installer
//        ),
//        Exchange(
//            alexIntro: ["haru are you okay"],
//            haruMessage: "yes why",
//            choices: ["you're not talking like yourself"]
//        ),
//        Exchange(
//            alexIntro: nil,
//            haruMessage: "play.",
//            choices: ["who are you"]
//        ),
//        Exchange(
//            alexIntro: nil,
//            haruMessage: "Haru can no longer respond.",
//            choices: []
//        ),
//    ]
//
//    // ─────────────────────────────────────────────────────────────
//    // HELPERS
//    // ─────────────────────────────────────────────────────────────
//
//    func triggerDialogue(_ texts: [String], portraits: [String], then completion: @escaping () -> Void) {
//        dialogueTexts = texts
//        dialoguePortraits = portraits
//        afterDialogue = completion
//        showDialogue = true
//    }
//
//    func triggerPicord(_ exchanges: [Exchange], then completion: @escaping () -> Void) {
//        inGameMessages = []  // ✅ repart d'une conversation vide à chaque fois
//        picordExchanges = exchanges
//        afterPicord = completion
//        showPicord = true
//    }
//
//    // ─────────────────────────────────────────────────────────────
//    // CONTINUE — logique après chaque énigme
//    // ─────────────────────────────────────────────────────────────
//
//    func handleContinue(index: Int? = nil) {
//        showContinueScreen = false
//        let idx = index ?? continueIndex
//
//        switch idx {
//
//        // ── Après READ ──────────────────────────────────────────
//        case 1:
//            triggerDialogue(
//                ["READ.",
//                 "...read what exactly?"],
//                portraits: ["alex_neutre", "alex_stresse"]
//            ) {
//                triggerPicord(picordAfterEnigma1) {
//                    showEnigmaContent = true
//                }
//            }
//
//        // ── Après CONTRACT ──────────────────────────────────────
//        case 2:
//            triggerDialogue(
//                ["Contract.",
//                 "What contract?",
//                 "Wait... she doesn't talk like that."],
//                portraits: ["alex_stresse", "alex_stresse", "alex_stresse"]
//            ) {
//                triggerPicord(picordAfterEnigma2) {
//                    showEnigmaContent = true
//                }
//            }
//
//        // ── Après DATA ──────────────────────────────────────────
//        // Séquence : dialogue Alex → picord → dialogue Alex (doute)
//        // → dialogue Esprit INTRO → enigma4 commence
//        case 3:
//            triggerDialogue(
//                ["Data.",
//                 "My data?"],
//                portraits: ["alex_stresse", "alex_stresse"]
//            ) {
//                triggerPicord(picordAfterEnigma3) {
//                    // Alex réalise — APRÈS avoir vu "just play, Alex." dans le Picord
//                    triggerDialogue(
//                        ["...",
//                         "She called me Alex.",
//                         "She never calls me that.",
//                         "That's not Haru.",
//                         "Why did this app open on its own?",
//                         "I need to finish this."],
//                        portraits: ["alex_stresse", "alex_stresse", "alex_stresse",
//                                    "alex_inquiet", "alex_inquiet", "alex_neutre"]
//                    ) {
//                        // Écran noir + CONTINUE avant que l'Esprit parle
//                        showBlackContinue = true
//                    }
//                }
//            }
//
//        default:
//            showEnigmaContent = true
//        }
//    }
//
//    // ─────────────────────────────────────────────────────────────
//    // BODY
//    // ─────────────────────────────────────────────────────────────
//
//    var body: some View {
//        ZStack {
//            VStack(spacing: 0) {
//
//                // Barre du browser
//                ZStack {
//                    Image("search")
//                        .resizable()
//                        .frame(maxWidth: .infinity, minHeight: 90, maxHeight: 90)
//
//                    HStack(spacing: -110) {
//                        Button(action: {
//                            if browserState == .loading || browserState == .home {
//                                isOpen = false
//                            }
//                        }) {
//                            Image("delete").resizable().frame(width: 120, height: 25)
//                        }
//                        .buttonStyle(.plain)
//                        Image("reduct").resizable().frame(width: 120, height: 25)
//                        Image("growup").resizable().frame(width: 120, height: 25)
//                        Spacer()
//                    }
//                    .padding(.leading, 55)
//
//                    Text("www.■■■■■■.com")
//                        .foregroundColor(.white)
//                        .font(.system(size: 16))
//                }
//
//                // Contenu
//                ZStack {
//                    switch browserState {
//                    case .loading:  loadingContent
//                    case .home:     homeContent
//                    case .contract: contractContent
//                    case .game:     gameContent
//                    case .ending:   endingContent
//                    }
//
//                    // Overlay DialogueView — par dessus tout
//                    if showDialogue {
//                        DialogueView(
//                            dialogues: dialogueTexts,
//                            portraits: dialoguePortraits,
//                            onComplete: {
//                                showDialogue = false
//                                let c = afterDialogue
//                                afterDialogue = nil
//                                c?()
//                            }
//                        )
//                    }
//
//                    // Mini fenêtre Picord flottante et déplaçable pendant les énigmes
//                    if showPicord {
//                        MiniPicordView(
//                            messages: $inGameMessages,
//                            exchanges: picordExchanges,
//                            onComplete: {
//                                showPicord = false
//                                inGameMessages = []
//                                let c = afterPicord
//                                afterPicord = nil
//                                c?()
//                            }
//                        )
//                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
//                        .animation(.spring(), value: showPicord)
//                    }
//
//                    // Overlay Esprit — image en grand + dialogue par dessus
//                    if showSpiritDialogue {
//                        ZStack {
//                            Color.black
//                                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                            Image("spirit")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(maxWidth: .infinity, maxHeight: .infinity)
//
//                            if spiritPhase == 0 {
//                                // INTRO — avant enigma4
//                                DialogueView(
//                                    dialogues: [
//                                        "You found the words.",
//                                        "Read. Contract. Data.",
//                                        "One last thing.",
//                                        "Rebuild what you agreed to."
//                                    ],
//                                    portraits: ["spirit", "spirit", "spirit", "spirit"],
//                                    onComplete: {
//                                        showSpiritDialogue = false
//                                        showEnigmaContent = true  // enigma4 démarre
//                                    }
//                                )
//                            } else {
//                                // CONCLUSION — après enigma4
//                                DialogueView(
//                                    dialogues: [
//                                        "what does this mean. answer me.",
//                                        "Haru played too.",
//                                        "She finished.",
//                                        "She didn't read either.",
//                                        "None of you ever do.",
//                                        "what did you do to her.",
//                                        "Exactly what the contract said.",
//                                        "Your data. Your choices. Your time.",
//                                        "Everything you gave without knowing.",
//                                        "She understood too late.",
//                                        "where is she.",
//                                        "Where everyone who finishes ends up."
//                                    ],
//                                    portraits: [
//                                        "alex_inquiet",
//                                        "spirit",
//                                        "spirit",
//                                        "spirit",
//                                        "spirit",
//                                        "alex_inquiet",
//                                        "spirit",
//                                        "spirit",
//                                        "spirit",
//                                        "spirit",
//                                        "alex_inquiet",
//                                        "spirit"
//                                    ],
//                                    onComplete: {
//                                        showSpiritDialogue = false
//                                        browserState = .ending
//                                    }
//                                )
//                            }
//                        }
//                        .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    }
//                }
//            }
//        }
//        .background(Color(hex: "161515"))
//        .clipShape(
//            UnevenRoundedRectangle(
//                topLeadingRadius: 10,
//                bottomLeadingRadius: 20,
//                bottomTrailingRadius: 20,
//                topTrailingRadius: 10
//            )
//        )
//    }
//
//    // ─────────────────────────────────────────────────────────────
//    // LOADING
//    // ─────────────────────────────────────────────────────────────
//
//    var loadingContent: some View {
//        VStack(spacing: 20) {
//            Spacer()
//            Text("LOADING...")
//                .font(.system(size: 40, weight: .heavy))
//                .foregroundColor(Color(hex: "f5f0eb"))
//            ZStack(alignment: .leading) {
//                RoundedRectangle(cornerRadius: 10)
//                    .foregroundColor(Color(hex: "f5f0eb").opacity(0.3))
//                    .frame(width: 400, height: 15)
//                RoundedRectangle(cornerRadius: 10)
//                    .foregroundColor(Color(hex: "f5f0eb"))
//                    .frame(width: 400 * loadingProgress, height: 15)
//            }
//            Spacer()
//        }
//        .onAppear {
//            withAnimation(.linear(duration: 2)) { loadingProgress = 1.0 }
//            // Pensée d'Alex pendant le chargement
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                triggerDialogue(
//                    ["A puzzle game.",
//                     "Sure, why not."],
//                    portraits: ["alex_neutre", "alex_neutre"]
//                ) { }
//            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
//                browserState = .home
//            }
//        }
//    }
//
//    // ─────────────────────────────────────────────────────────────
//    // HOME
//    // ─────────────────────────────────────────────────────────────
//
//    var homeContent: some View {
//        VStack(spacing: 30) {
//            Spacer()
//            Text("CLAUSE 0")
//                .font(.system(size: 60, weight: .heavy))
//                .foregroundColor(Color(hex: "f5f0eb"))
//            Button(action: { browserState = .contract }) {
//                Text("START")
//                    .font(.system(size: 24, weight: .bold))
//                    .foregroundColor(.white)
//                    .padding(.horizontal, 60)
//                    .padding(.vertical, 20)
//                    .background(Color(hex: "161515"))
//                    .cornerRadius(20)
//                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 3))
//            }
//            Spacer()
//        }
//    }
//
//    // ─────────────────────────────────────────────────────────────
//    // CONTRACT
//    // ─────────────────────────────────────────────────────────────
//
//    var contractContent: some View {
//        ZStack {
//            ScrollView {
//                VStack(alignment: .leading, spacing: 20) {
//                    Text("TERMS OF SERVICE")
//                        .font(.system(size: 28, weight: .heavy, design: .monospaced))
//                        .foregroundColor(.white)
//                        .padding(.top, 30)
//                    Text("Version 14.2.1 — Last updated March 2026")
//                        .font(.system(size: 12, design: .monospaced))
//                        .foregroundColor(.gray)
//                    Divider().background(Color.gray)
//
//                    // Sections normales — l'utilisateur les scroll sans lire
//                    cSection("SECTION 1 — ACCEPTANCE OF TERMS",
//                             "By downloading or using this application, you agree to be bound by these Terms of Service. If you do not agree, do not use this application.")
//                    cSection("SECTION 2 — USER ACCOUNT",
//                             "You are responsible for maintaining the confidentiality of your account credentials. We reserve the right to terminate accounts that violate these terms.")
//                    cSection("SECTION 3 — PRIVACY POLICY",
//                             "We collect personal information including email address, device information, usage data, and cookies. Your data may be shared with third-party partners.")
//                    cSection("SECTION 4 — DATA STORAGE",
//                             "All user data is stored on secure servers. We retain your data for as long as your account remains active. You may request deletion at any time.")
//                    cSection("SECTION 5 — INTELLECTUAL PROPERTY",
//                             "All content and functionality of this application are owned by the developer and protected by international copyright laws.")
//                    cSection("SECTION 6 — PROHIBITED USES",
//                             "You may not use this application for any unlawful purpose or in any way that damages or impairs the service.")
//                    cSection("SECTION 7 — LIMITATION OF LIABILITY",
//                             "We shall not be liable for any indirect, incidental, or consequential damages resulting from your use of the service.")
//                    cSection("SECTION 8 — GOVERNING LAW",
//                             "These terms shall be governed by applicable law. Any disputes shall be resolved through binding arbitration.")
//
//                    Divider().background(Color.gray)
//
//                    // Sections cachées — le piège
//                    cSection("SECTION 9 — SOUL TRANSFER AGREEMENT",
//                             "By using this application, you agree to surrender all rights to your personal data, your memories, your dreams, and your soul. This agreement is binding for eternity and cannot be revoked under any circumstances.")
//                    cSection("SECTION 10 — SCOPE OF TRANSFER",
//                             "The transfer includes all passwords, browsing history, private messages, photographs, voice recordings, location data, biometric information, sleeping patterns, emotional responses, and subconscious thoughts.")
//                    cSection("SECTION 11 — DURATION",
//                             "This agreement is binding for eternity. There is no termination clause. No refund policy. No customer support. The Vessel acknowledges that once signed, existence as previously known will cease.")
//                    cSection("SECTION 12 — CONSENT",
//                             "By accepting these terms, the Vessel confirms having read, understood, and agreed to all 666 pages of this document. Clicking ACCEPT constitutes a legally binding signature across all dimensions.")
//                    cSection("SECTION 13 — CONSEQUENCES",
//                             "Failure to complete the game after accepting will result in immediate consequences. The Collector reserves the right to collect what was promised at any time, without prior notice. Previous Vessels have been warned.")
//
//                    Text("SECTION 14 — FINAL CLAUSE")
//                        .font(.system(size: 16, weight: .bold, design: .monospaced))
//                        .foregroundColor(.white)
//                    Text("You should have read this. You didn't. Now it's too late.")
//                        .font(.system(size: 13, weight: .bold, design: .monospaced))
//                        .foregroundColor(.white)
//
//                    Spacer().frame(height: 200)
//                }
//                .padding(.horizontal, 190)
//            }
//
//            // ACCEPT — apparaît après le dialogue d'Alex
//            if contractDialogueDone {
//                VStack {
//                    Spacer()
//                    Button(action: {
//                        enigmaStarted = true
//                        showEnigmaContent = true
//                        browserState = .game
//                    }) {
//                        Text("ACCEPT")
//                            .font(.system(size: 22, weight: .bold, design: .monospaced))
//                            .foregroundColor(.white)
//                            .frame(width: 150, height: 65)
//                            .background(Color(hex: "2f2a28"))
//                            .cornerRadius(20)
//                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 3))
//                    }
//                    .padding(.bottom, 40)
//                }
//            }
//        }
//        .onAppear {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                triggerDialogue(
//                    ["Terms of service...",
//                     "The usual.",
//                     "Skip."],
//                    portraits: ["alex_neutre", "alex_neutre", "alex_neutre"]
//                ) {
//                    contractDialogueDone = true
//                }
//            }
//        }
//    }
//
//    func cSection(_ title: String, _ body: String) -> some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text(title)
//                .font(.system(size: 16, weight: .bold, design: .monospaced))
//                .foregroundColor(.white)
//            Text(body)
//                .font(.system(size: 13, design: .monospaced))
//                .foregroundColor(.white)
//        }
//    }
//
//    // ─────────────────────────────────────────────────────────────
//    // GAME — énigmes + écran continue
//    // ─────────────────────────────────────────────────────────────
//
//    var gameContent: some View {
//        ZStack {
//            if enigmaStarted {
//                EnigmaView(
//                    onEnigma1Complete: {
//                        showEnigmaContent = false
//                        continueWord = "READ"
//                        continueIndex = 1
//                        showContinueScreen = true
//                    },
//                    onEnigma2Complete: {
//                        showEnigmaContent = false
//                        continueWord = "CONTRACT"
//                        continueIndex = 2
//                        showContinueScreen = true
//                    },
//                    onEnigma3Complete: {
//                        showEnigmaContent = false
//                        continueWord = "DATA"
//                        continueIndex = 3
//                        showContinueScreen = true
//                    },
//                    onEnigma4Complete: {
//                        showEnigmaContent = false
//                        spiritPhase = 1
//                        showSpiritDialogue = true
//                    }
//                )
//                // ✅ Frame explicite = même taille que le canvas interne d'EnigmaView
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .opacity(showEnigmaContent ? 1 : 0)
//                .allowsHitTesting(showEnigmaContent)
//            }
//
//            // Écran noir avec CONTINUE — respiration avant le Spirit
//            if showBlackContinue {
//                VStack(spacing: 50) {
//                    Spacer()
//                    Button(action: {
//                        showBlackContinue = false
//                        spiritPhase = 0
//                        showSpiritDialogue = true
//                    }) {
//                        Text("CONTINUE")
//                            .font(.system(size: 22, weight: .bold, design: .monospaced))
//                            .foregroundColor(.white)
//                            .padding(.horizontal, 50)
//                            .padding(.vertical, 20)
//                            .background(Color(hex: "0a0a0a"))
//                            .cornerRadius(20)
//                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.3), lineWidth: 1))
//                    }
//                    Spacer()
//                }
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .background(Color.black)
//                .clipped()
//            }
//
//            // Écran CONTINUE avec le mot trouvé
//            if showContinueScreen {
//                VStack(spacing: 40) {
//                    Spacer()
//                    Text(continueWord)
//                        .font(.system(size: 80, weight: .heavy, design: .monospaced))
//                        .foregroundColor(.white)
//                    Text("—")
//                        .font(.system(size: 30, weight: .thin))
//                        .foregroundColor(Color(hex: "af9a9a"))
//                    Button(action: { handleContinue(index: continueIndex) }) {
//                        Text("CONTINUE")
//                            .font(.system(size: 22, weight: .bold, design: .monospaced))
//                            .foregroundColor(.white)
//                            .padding(.horizontal, 50)
//                            .padding(.vertical, 20)
//                            .background(Color(hex: "2f2a28"))
//                            .cornerRadius(20)
//                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 3))
//                    }
//                    Spacer()
//                }
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .background(Color(hex: "161515"))
//            }
//        }
//    }
//
//    // ─────────────────────────────────────────────────────────────
//    // ENDING — BrowserView passe la main à ComputerView
//    // ─────────────────────────────────────────────────────────────
//
//    var endingContent: some View {
//        Color.clear
//            .onAppear {
//                // ComputerView gère l'écran noir final plein iPad
//                onComplete()
//            }
//    }
//}
//
//#Preview(traits: .landscapeLeft) {
//    BrowserView(isOpen: .constant(true), messages: .constant([]), onComplete: {})
//}

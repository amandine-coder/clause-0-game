import SwiftUI

enum GamePhase {
    case bureau
    case loading
    case contract
    case tuto
    case enigma
    case spiritIntro
    case spiritWelcome
    case blackContinue
    case spiritFinal
    case ending
    case toBeContinued
}

struct GameView: View {

    var onQuit: () -> Void = {}

    @State private var phase: GamePhase = .tuto
    @State private var loadingProgress: CGFloat = 0
    @State private var contractDialogueDone = false
    @State private var showSignaturePopup = false

    @State private var enigmaStarted = false
    @State private var showEnigmaContent = false
    @State private var showContinueScreen = false
    @State private var continueWord = ""
    @State private var continueIndex = 0

    @State private var showDialogue = false
    @State private var dialogueTexts: [String] = []
    @State private var dialoguePortraits: [String] = []
    @State private var afterDialogue: (() -> Void)?

    @State private var showPicord = false
    @State private var picordMessages: [Message] = []

    @State private var spiritDialogues: [String] = []
    @State private var spiritPortraits: [String] = []
    @State private var afterSpirit: (() -> Void)?

    @State private var endingTextOpacity: Double = 0
    @State private var clauseTextOpacity: Double = 0
    @State private var spiritFarewellOpacity: Double = 0
    @State private var toBeContinuedOpacity: Double = 0
    @State private var showNotification = false
    @State private var keepSpiritVisible = false

    let haruExchanges: [Exchange] = [
        Exchange(alexIntro: nil, haruMessage: "hey. did you finish your part for the presentation ?", choices: ["...not yet. maybe tomorrow"]),
        Exchange(alexIntro: nil, haruMessage: "sure 🙄 as always, last minute.. 😂", choices: ["oh stop it, i'll be done in time"]),
        Exchange(alexIntro: nil, haruMessage: "anyway. found this puzzle game. it's actually really good. try it !", choices: ["mmh ok. might as well take a break before finishing my part 😅"]),
        Exchange(alexIntro: nil, haruMessage: "yes ! here: [lien]", choices: ["ok ok"]),
        Exchange(alexIntro: nil, haruMessage: "just tap on CLAUSE 0 to open it 🖤", choices: [])
    ]

    func triggerDialogue(_ texts: [String], portraits: [String], then completion: @escaping () -> Void) {
        dialogueTexts = texts
        dialoguePortraits = portraits
        afterDialogue = completion
        showDialogue = true
    }

    func triggerSpirit(_ texts: [String], keepBackground: Bool = false, then completion: @escaping () -> Void) {
        spiritDialogues = texts
        spiritPortraits = Array(repeating: "spirit", count: texts.count)
        keepSpiritVisible = keepBackground
        afterSpirit = completion
        phase = .spiritIntro
    }

    func handleContinue() {
        showContinueScreen = false
        switch continueIndex {

        case 1:
            triggerSpirit(["READ.", "Good.", "You can read.", "You just don't.", "Keep going."]) {
                triggerDialogue(["...okay. weird intro."], portraits: ["alex_neutre"]) {
                    showEnigmaContent = true
                    phase = .enigma
                }
            }

        case 2:
            triggerSpirit(["CONTRACT.", "Did you read it ?", "Everybody says that.", "Right until the end.", "Keep going."]) {
                triggerDialogue(
                    ["is this about the terms of service ?", "i clicked accept. it's fine.", "...nobody does.", "the end of what."],
                    portraits: ["alex_neutre", "alex_neutre", "alex_stresse", "alex_stresse"]
                ) {
                    showEnigmaContent = true
                    phase = .enigma
                }
            }

        case 3:
            triggerSpirit([
                "DATA.", "READ. CONTRACT. DATA.", "There won't be a next time.",
                "You signed.", "Clause 0.", "Before the first page.", "Before the terms.",
                "Before everything.", "The clause that makes all the others valid.",
                "Nobody does.", "That's the point."
            ], keepBackground: true) {
                triggerDialogue(
                    ["READ. CONTRACT. DATA.", "okay i get it.", "i'll do better next time, happy ?", "...", "What did I sign."],
                    portraits: ["alex_neutre","alex_stresse","alex_stresse","alex_stresse","alex_inquiet"]
                ) { phase = .blackContinue }
            }

        default:
            showEnigmaContent = true
            phase = .enigma
        }
    }

    var body: some View {
        ZStack {

            // ── FOND ─────────────────────────────────────────────
            if phase == .bureau {
                Color(hex: "3d3533").ignoresSafeArea()
                Canvas { context, size in
                    let tileSize: CGFloat = 4
                    for x in stride(from: 0, to: size.width, by: tileSize) {
                        for y in stride(from: 0, to: size.height, by: tileSize) {
                            let brightness = CGFloat.random(in: 0.20...0.28)
                            context.fill(Path(CGRect(x: x, y: y, width: tileSize, height: tileSize)),
                                        with: .color(Color(white: brightness)))
                        }
                    }
                }
                .ignoresSafeArea()
                .allowsHitTesting(false)

                VStack(spacing: 8) {
                    Image(systemName: "doc.fill").font(.system(size: 30)).foregroundColor(.white.opacity(0.6))
                    Text("notes.txt").font(.system(size: 10)).foregroundColor(.white.opacity(0.5))
                }.position(x: 80, y: 180)

                VStack(spacing: 8) {
                    Image(systemName: "photo.fill").font(.system(size: 30)).foregroundColor(.white.opacity(0.6))
                    Text("haru.jpg").font(.system(size: 10)).foregroundColor(.white.opacity(0.5))
                }.position(x: 80, y: 280)

            } else {
                Color.black.ignoresSafeArea()
            }

            // ── LOADING ───────────────────────────────────────────
            if phase == .loading {
                VStack(spacing: 20) {
                    Spacer()
                    Text("LOADING...").font(.system(size: 40, weight: .heavy)).foregroundColor(Color(hex: "f5f0eb"))
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10).foregroundColor(Color(hex: "f5f0eb").opacity(0.3)).frame(width: 400, height: 15)
                        RoundedRectangle(cornerRadius: 10).foregroundColor(Color(hex: "f5f0eb")).frame(width: 400 * loadingProgress, height: 15)
                    }
                    Spacer()
                }
                .onAppear {
                    withAnimation(.linear(duration: 2)) { loadingProgress = 1.0 }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        triggerDialogue(["A game.", "Fine.", "I could use the distraction."],
                                       portraits: ["alex_neutre","alex_neutre","alex_neutre"]) { }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { phase = .contract }
                }
            }

            // ── CONTRACT ──────────────────────────────────────────
            if phase == .contract {
                ZStack {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {

                            Text("CLAUSE 0")
                                .font(.system(size: 28, weight: .heavy, design: .monospaced))
                                .foregroundColor(.white)
                                .padding(.top, 30)
                            Text("CONTRACT")
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .foregroundColor(Color(hex: "888888"))
                                .kerning(4)
                            Text("Version 14.2.1 — Last updated March 2026")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.gray)

                            Divider().background(Color.white.opacity(0.2))

                            ForEach(contractSections, id: \.self) { section in
                                contractBlock(section)
                            }

                            Divider().background(Color.white.opacity(0.2))

                            ForEach(hiddenSections, id: \.self) { section in
                                contractBlock(section)
                            }

                            Spacer().frame(height: 80)
                        }
                        .padding(.horizontal, 190)
                    }
                    .allowsHitTesting(!showDialogue && !showSignaturePopup)

                    if showDialogue && phase == .contract {
                        DialogueView(
                            dialogues: dialogueTexts,
                            portraits: dialoguePortraits,
                            onComplete: {
                                showDialogue = false
                                let c = afterDialogue
                                afterDialogue = nil
                                c?()
                            }
                        )
                    }

                    if showSignaturePopup {
                        Color.black.opacity(0.7).ignoresSafeArea()

                        VStack(spacing: 24) {
                            Text("CLAUSE 0")
                                .font(.system(size: 28, weight: .heavy, design: .monospaced))
                                .foregroundColor(.white)

                            Text("By proceeding, you accept all terms,\npresent, past, and future.")
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundColor(Color(hex: "888888"))
                                .multilineTextAlignment(.center)

                            SignatureView(onSigned: {
                                showSignaturePopup = false
                                phase = .spiritWelcome
                            })
                        }
                        .padding(40)
                        .background(Color(hex: "111111"))
                        .cornerRadius(24)
                        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.1), lineWidth: 1))
                        .frame(maxWidth: 600)
                        .transition(.scale(scale: 0.9).combined(with: .opacity))
                        .animation(.spring(), value: showSignaturePopup)
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        // ── Dialogue Alex sarcastique ──
                        triggerDialogue(
                            ["Another 42-page contract.", "Who actually reads contract.", "...where do I sign ?"],
                            portraits: ["alex_neutre","alex_neutre","alex_neutre"]
                        ) {
                            withAnimation(.spring()) { showSignaturePopup = true }
                        }
                    }
                }
            }

            // ── SPIRIT WELCOME — intro esprit après signature ──────
            if phase == .spiritWelcome {
                ZStack {
                    Color.black
                    Image("spirit").resizable().scaledToFit().frame(maxWidth: .infinity, maxHeight: .infinity)
                    DialogueView(
                        dialogues: [
                            "Welcome.",
                            "You found it.",
                            "Or maybe it found you.",
                            "CLAUSE 0.",
                            "A game with rules.",
                            "Simple ones.",
                            "Read.",
                            "Understand.",
                            "Play.",
                            "You already failed the first two.",
                            "Let's see about the third."
                        ],
                        portraits: Array(repeating: "spirit", count: 11),
                        onComplete: {
                            enigmaStarted = true
                            phase = .tuto
                        }
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            }

            // ── TUTO ──────────────────────────────────────────────
            if phase == .tuto {
                VStack(spacing: 50) {
                    Spacer()
                    Text("HOW TO PLAY")
                        .font(.system(size: 22, weight: .heavy, design: .monospaced))
                        .foregroundColor(Color(hex: "888888"))
                        .kerning(4)

                    VStack(alignment: .leading, spacing: 28) {
                        if !enigmaStarted {
                            tutoLine(icon: "hand.point.up.left", text: "Tap anywhere to continue the story")
                            tutoLine(icon: "message", text: "Tap the blue button to reply in chat")
                        } else {
                            tutoLine(icon: "hand.draw", text: "Drag elements to explore")
                            tutoLine(icon: "hand.tap", text: "Tap letters in the right order to find the hidden word")
                        }
                    }

                    Button(action: {
                        if !enigmaStarted {
                            phase = .bureau
                        } else {
                            showEnigmaContent = true
                            phase = .enigma
                        }
                    }) {
                        Text("OK")
                            .font(.system(size: 22, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(.horizontal, 60)
                            .padding(.vertical, 20)
                            .background(Color(hex: "2f2a28"))
                            .cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 2))
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            // ── ENIGMES ───────────────────────────────────────────
            if enigmaStarted {
                EnigmaView(
                    onEnigma1Complete: { showEnigmaContent = false; continueWord = "READ"; continueIndex = 1; showContinueScreen = true },
                    onEnigma2Complete: { showEnigmaContent = false; continueWord = "CONTRACT"; continueIndex = 2; showContinueScreen = true },
                    onEnigma3Complete: { showEnigmaContent = false; continueWord = "DATA"; continueIndex = 3; showContinueScreen = true },
                    onEnigma4Complete: { showEnigmaContent = false; phase = .spiritFinal }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(showEnigmaContent ? 1 : 0)
                .allowsHitTesting(showEnigmaContent)
            }

            // ── CONTINUE mot trouvé ───────────────────────────────
            if showContinueScreen {
                VStack(spacing: 40) {
                    Spacer()
                    Text(continueWord).font(.system(size: 80, weight: .heavy, design: .monospaced)).foregroundColor(.white)
                    Text("—").font(.system(size: 30, weight: .thin)).foregroundColor(Color(hex: "af9a9a"))
                    Button(action: { handleContinue() }) {
                        Text("CONTINUE").font(.system(size: 22, weight: .bold, design: .monospaced)).foregroundColor(.white)
                            .padding(.horizontal, 50).padding(.vertical, 20)
                            .background(Color(hex: "2f2a28")).cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 3))
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
            }

            // ── ÉCRAN NOIR avant enigma4 ──────────────────────────
            if phase == .blackContinue {
                VStack {
                    Spacer()
                    Button(action: {
                        triggerSpirit(["One last thing.", "The sentence.", "The one hidden in section 9.", "The one you scrolled past.", "Build it."]) {
                            showEnigmaContent = true
                            phase = .enigma
                        }
                    }) {
                        Text("CONTINUE").font(.system(size: 22, weight: .bold, design: .monospaced)).foregroundColor(.white)
                            .padding(.horizontal, 50).padding(.vertical, 20)
                            .background(Color(hex: "0a0a0a")).cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.3), lineWidth: 1))
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
            }

            // ── SPIRIT BACKGROUND ─────────────────────────────────
            if phase == .spiritIntro || (showDialogue && keepSpiritVisible) {
                ZStack {
                    Color.black
                    Image("spirit").resizable().scaledToFit().frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            }

            // ── SPIRIT DIALOGUE ───────────────────────────────────
            if phase == .spiritIntro {
                DialogueView(
                    dialogues: spiritDialogues,
                    portraits: spiritPortraits,
                    onComplete: {
                        phase = .enigma
                        let c = afterSpirit
                        afterSpirit = nil
                        c?()
                    }
                )
            }

            // ── SPIRIT FINAL ──────────────────────────────────────
            if phase == .spiritFinal {
                ZStack {
                    Color.black
                    Image("spirit").resizable().scaledToFit().frame(maxWidth: .infinity, maxHeight: .infinity)
                    DialogueView(
                        dialogues: [
                            "...", "No.", "No that's not — that can't be legal.",
                            "You clicked ACCEPT.", "You signed.", "You played.",
                            "Three times you said yes.", "Without reading.",
                            "this is a game. this isn't real.",
                            "Haru thought the same thing.", "WHAT !?",
                            "She played last week.", "She finished.", "She sent you the link.",
                            "...why isn't she answering me", "She can't.", "Not anymore.",
                            "what did you do to her", "What she agreed to.", "What you agreed to.",
                            "It's all in the contract.", "The one you didn't read.",
                            "I want out right now.", "Section 11.", "No termination clause.", "No exit.",
                            "where is she. WHERE IS SHE.", "Your friend.", "She belongs to me.", "Clause 0.",
                            "The clause before all others.", "The one you signed.",
                            "NO.", "Stay away from her.", "STAY AWAY FROM ME.",
                            "...", "You should have read it."
                        ],
                        portraits: [
                            "alex_inquiet","alex_inquiet","alex_inquiet",
                            "spirit","spirit","spirit","spirit","spirit",
                            "alex_stresse","spirit","alex_inquiet",
                            "spirit","spirit","spirit",
                            "alex_inquiet","spirit","spirit",
                            "alex_inquiet","spirit","spirit","spirit","spirit",
                            "alex_stresse","spirit","spirit","spirit",
                            "alex_stresse","spirit","spirit","spirit","spirit","spirit",
                            "alex_stresse","alex_stresse","alex_stresse",
                            "spirit","spirit"
                        ],
                        onComplete: { phase = .ending }
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            }

            // ── ENDING ────────────────────────────────────────────
            if phase == .ending {
                ZStack {
                    Color.black
                    VStack(spacing: 40) {
                        Text("You should have read it.")
                            .font(.system(size: 30, weight: .medium, design: .monospaced))
                            .foregroundColor(.white)
                            .opacity(endingTextOpacity)
                        Text("Clause 0 : By proceeding, you agree to all terms,\npresent, past, and future,\nwhether read or not.\n\nYou proceeded.")
                            .font(.system(size: 25, design: .monospaced))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .opacity(clauseTextOpacity)
                    }
                }
                .ignoresSafeArea()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation(.easeIn(duration: 2)) { endingTextOpacity = 1 }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                        withAnimation(.easeIn(duration: 2)) { clauseTextOpacity = 1 }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                        withAnimation(.easeOut(duration: 1)) {
                            endingTextOpacity = 0
                            clauseTextOpacity = 0
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 9.5) {
                        phase = .toBeContinued
                    }
                }
            }

            // ── SPIRIT FAREWELL + TO BE CONTINUED ─────────────────
            if phase == .toBeContinued {
                ZStack {
                    Color.black
                    Image("spirit").resizable().scaledToFit().frame(maxWidth: .infinity, maxHeight: .infinity)

                    VStack(spacing: 50) {
                        Spacer()

                        VStack(spacing: 16) {
                            Text("Well played, Alex.")
                                .font(.system(size: 24, weight: .medium, design: .monospaced))
                                .foregroundColor(.white)
                            Text("But you were never the only one.")
                                .font(.system(size: 20, design: .monospaced))
                                .foregroundColor(Color(hex: "aaaaaa"))
                            Text("I'll find someone else to play with.")
                                .font(.system(size: 20, design: .monospaced))
                                .foregroundColor(Color(hex: "aaaaaa"))
                        }
                        .opacity(spiritFarewellOpacity)

                        // ── TO BE CONTINUED — grand et blanc ──
                        Text("TO BE CONTINUED")
                            .font(.system(size: 28, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .kerning(6)
                            .opacity(toBeContinuedOpacity)

                        Spacer()
                    }
                    .padding(.horizontal, 60)
                }
                .ignoresSafeArea()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation(.easeIn(duration: 2)) { spiritFarewellOpacity = 1 }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                        withAnimation(.easeIn(duration: 2)) { toBeContinuedOpacity = 1 }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 9) {
                        withAnimation(.easeOut(duration: 1.5)) { onQuit() }
                    }
                }
            }

            // ── PICORD ────────────────────────────────────────────
            if showPicord && phase == .bureau {
                MiniPicordView(
                    messages: $picordMessages,
                    exchanges: haruExchanges,
                    onComplete: { },
                    onLinkTap: {
                        withAnimation { showPicord = false }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { phase = .loading }
                    }
                )
                .position(x: 650, y: 450)
                .transition(.scale(scale: 0.9).combined(with: .opacity))
                .animation(.spring(), value: showPicord)
            }

            // ── NOTIFICATION ──────────────────────────────────────
            if showNotification && !showPicord && phase == .bureau {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation(.spring()) { showNotification = false; showPicord = true }
                        }) {
                            HStack(spacing: 14) {
                                Circle().fill(Color(hex: "4a4a4a")).frame(width: 65, height: 65)
                                    .overlay(Text("H").font(.system(size: 44, weight: .bold)).foregroundColor(.white))
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text("Haru").font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
                                        Spacer()
                                        Text("now").font(.system(size: 12)).foregroundColor(Color(hex: "888888"))
                                    }
                                    Text("found something. don't ask questions 🙂")
                                        .font(.system(size: 14)).foregroundColor(Color(hex: "cccccc")).lineLimit(2)
                                }
                            }
                            .padding(.horizontal, 20).padding(.vertical, 16).frame(width: 360)
                            .background(Color(hex: "2a2a2a")).cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.15), lineWidth: 1))
                            .shadow(color: .black.opacity(0.5), radius: 30)
                        }
                        .buttonStyle(.plain)
                        .padding(.trailing, 30).padding(.bottom, 40)
                    }
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .animation(.spring(), value: showNotification)
            }

            // ── DIALOGUE ALEX — par dessus tout (sauf contract) ───
            if showDialogue && phase != .contract {
                DialogueView(
                    dialogues: dialogueTexts,
                    portraits: dialoguePortraits,
                    onComplete: {
                        showDialogue = false
                        keepSpiritVisible = false
                        let c = afterDialogue
                        afterDialogue = nil
                        c?()
                    }
                )
            }
        }
        .onChange(of: phase) {
            if phase == .bureau {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    triggerDialogue(
                        ["Done.", "Finally done.", "I just need one hour to not think about anything."],
                        portraits: ["alex_neutre","alex_neutre","alex_neutre"]
                    ) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { showNotification = true }
                    }
                }
            }
        }
    }

    // ── CONTRAT : blocs de rectangles illisibles ──────────────────
    let contractSections = [
        "SECTION 1 — ACCEPTANCE OF TERMS",
        "SECTION 2 — USER ACCOUNT",
        "SECTION 3 — PRIVACY POLICY",
        "SECTION 4 — DATA STORAGE",
        "SECTION 5 — INTELLECTUAL PROPERTY",
        "SECTION 6 — PROHIBITED USES",
        "SECTION 7 — LIMITATION OF LIABILITY",
        "SECTION 8 — GOVERNING LAW"
    ]

    let hiddenSections = [
        "SECTION 9 — SOUL TRANSFER AGREEMENT",
        "SECTION 10 — SCOPE OF TRANSFER",
        "SECTION 11 — DURATION",
        "SECTION 12 — CONSENT",
        "SECTION 13 — CONSEQUENCES",
        "SECTION 14 — FINAL CLAUSE"
    ]

    func contractBlock(_ title: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            VStack(alignment: .leading, spacing: 6) {
                ForEach(0..<Int.random(in: 2...4), id: \.self) { i in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.25))
                        .frame(maxWidth: i == 2 ? CGFloat.random(in: 180...300) : .infinity)
                        .frame(height: 8)
                }
            }
        }
    }

    func tutoLine(icon: String, text: String) -> some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(Color(hex: "888888"))
                .frame(width: 40)
            Text(text)
                .font(.system(size: 18, design: .monospaced))
                .foregroundColor(.white)
        }
    }

    func cSection(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.system(size: 16, weight: .bold, design: .monospaced)).foregroundColor(.white)
            Text(body).font(.system(size: 13, design: .monospaced)).foregroundColor(.white)
        }
    }
}

#Preview(traits: .landscapeLeft) {
    GameView()
}

import SwiftUI

enum EnigmaState {
    case enigma1
    case enigma2
    case enigma3
    case enigma4
    case final
}

// enigma 4 - word
struct WordItem: Identifiable {
    let id = UUID()
    let word: String
    var position: CGPoint
    var isPlaced: Bool = false
    let correctIndex: Int
}

// move piece
struct DraggableItem: Identifiable {
    let id = UUID()
    let imageName: String
    var position: CGPoint
}

// enigme 3 - puzzle
struct PuzzlePiece: Identifiable {
    let id: Int
    let imageName: String
    var position: CGPoint
    let targetPosition: CGPoint
    var isPlaced: Bool = false
}

struct EnigmaView: View {

    @State private var enigmaState: EnigmaState = .enigma1

    // enigma 1
    @State private var items: [DraggableItem] = [
        DraggableItem(imageName: "postit4", position: CGPoint(x: 250, y: 250)),
        DraggableItem(imageName: "postit2", position: CGPoint(x: 350, y: 380)),
        DraggableItem(imageName: "postit1", position: CGPoint(x: 500, y: 300)),
        DraggableItem(imageName: "postit3", position: CGPoint(x: 420, y: 220)),
    ]

    // enigma 2
    @State private var bookItems: [DraggableItem] = [
        DraggableItem(imageName: "book1", position: CGPoint(x: 160, y: 300)),
        DraggableItem(imageName: "book2", position: CGPoint(x: 315, y: 300)),
        DraggableItem(imageName: "book3", position: CGPoint(x: 500, y: 300)),
        DraggableItem(imageName: "book4", position: CGPoint(x: 640, y: 300)),
    ]

    // enigma 3
    @State private var puzzlePieces: [PuzzlePiece] = {
        let gridOriginX: CGFloat = 100
        let gridOriginY: CGFloat = 25
        let pieceSize: CGFloat = 150

        var pieces: [PuzzlePiece] = []

        let startPositions: [CGPoint] = [
            CGPoint(x: 50, y: 50),   CGPoint(x: 250, y: 80),  CGPoint(x: 450, y: 50),  CGPoint(x: 600, y: 100),
            CGPoint(x: 80, y: 300),  CGPoint(x: 300, y: 250), CGPoint(x: 500, y: 300), CGPoint(x: 620, y: 280),
            CGPoint(x: 60, y: 500),  CGPoint(x: 200, y: 480), CGPoint(x: 400, y: 520), CGPoint(x: 580, y: 480),
            CGPoint(x: 100, y: 400), CGPoint(x: 320, y: 420), CGPoint(x: 480, y: 400), CGPoint(x: 650, y: 420),
        ]

        for row in 0..<4 {
            for col in 0..<4 {
                let id = row * 4 + col
                let targetX = gridOriginX + CGFloat(col) * pieceSize + pieceSize / 2
                let targetY = gridOriginY + CGFloat(row) * pieceSize + pieceSize / 2

                pieces.append(PuzzlePiece(
                    id: id,
                    imageName: id == 0 ? "piece" : "piece\(id)",
                    position: startPositions[id],
                    targetPosition: CGPoint(x: targetX, y: targetY)
                ))
            }
        }
        return pieces
    }()

    // enigma 4
    @State private var wordItems: [WordItem] = [
        WordItem(word: "YOUR",   position: CGPoint(x: 102, y: 400), correctIndex: 0),
        WordItem(word: "AND",    position: CGPoint(x: 230, y: 350), correctIndex: 2),
        WordItem(word: "BELONG", position: CGPoint(x: 358, y: 420), correctIndex: 5),
        WordItem(word: "DATA",   position: CGPoint(x: 486, y: 380), correctIndex: 1),
        WordItem(word: "ME",     position: CGPoint(x: 614, y: 300), correctIndex: 7),
        WordItem(word: "YOUR",   position: CGPoint(x: 742, y: 450), correctIndex: 3),
        WordItem(word: "TO",     position: CGPoint(x: 870, y: 320), correctIndex: 6),
        WordItem(word: "LIFE",   position: CGPoint(x: 998, y: 400), correctIndex: 4),
    ]

    let slotPositions: [CGPoint] = [
        CGPoint(x: 175 + 60,  y: 560),
        CGPoint(x: 175 + 188, y: 560),
        CGPoint(x: 175 + 316, y: 560),
        CGPoint(x: 175 + 444, y: 560),
        CGPoint(x: 175 + 572, y: 560),
        CGPoint(x: 175 + 700, y: 560),
        CGPoint(x: 175 + 828, y: 560),
        CGPoint(x: 175 + 956, y: 560),
    ]

    let onEnigma1Complete: () -> Void
    let onEnigma2Complete: () -> Void
    let onEnigma3Complete: () -> Void
    let onEnigma4Complete: () -> Void

    @State private var selectedLetters: [Int] = []
    @State private var wrongLetter: String? = nil
    @State private var isVisualComplete = false

    let snapDistance: CGFloat = 60

    func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2))
    }

    func handleLetterTap(letter: String, index: Int, word: String, nextState: EnigmaState, onComplete: @escaping () -> Void) {
        let expectedIndex = selectedLetters.count
        let expectedLetter = String(Array(word)[expectedIndex])

        if letter == expectedLetter {
            withAnimation(SwiftUI.Animation.easeOut(duration: 0.3)) {
                selectedLetters.append(index)
            }
            if selectedLetters.count == word.count && isVisualComplete {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    selectedLetters = []
                    isVisualComplete = false
                    enigmaState = nextState
                    onComplete()
                }
            }
        } else {
            wrongLetter = letter
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                wrongLetter = nil
            }
        }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {

                switch enigmaState {

                // ── ENIGMA 1 ─────────────────────────────────────────────
                case .enigma1:
                    let word = "READ"
                    let letters = ["R","E","G","D","B","H","T","A","L"]

                    HStack(spacing: 0) {
                        // GAUCHE
                        GeometryReader { geo in
                            ZStack {
                                ForEach($items) { $item in
                                    Image(item.imageName)
                                        .resizable()
                                        .frame(width: 400, height: 400)
                                        .position(item.position)
                                        .gesture(
                                            DragGesture(coordinateSpace: .named("enigma1Canvas"))
                                                .onChanged { value in
                                                    item.position = value.location
                                                }
                                               
                                        )
                                }
                            }
                            .coordinateSpace(name: "enigma1Canvas")
                        }
                        .frame(width: 790, height: 650)
                        .clipped()

                        // DROITE
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 60),
                            GridItem(.flexible(), spacing: 60),
                            GridItem(.flexible(), spacing: 60)
                        ], spacing: 60) {
                            ForEach(Array(letters.enumerated()), id: \.offset) { index, letter in
                                Button(action: {
                                    handleLetterTap(letter: letter, index: index, word: word, nextState: .enigma2, onComplete: onEnigma1Complete)
                                }) {
                                    Text(letter)
                                        .font(.system(size: 50, weight: .medium, design: .monospaced))
                                        .foregroundColor(
                                            wrongLetter == letter ? .red :
                                                selectedLetters.contains(index) ? .clear : .white
                                        )
                                }
                            }
                        }
                        .frame(width: 200)
                        .padding(.horizontal, 70)
                        .offset(x: 20)
                    }
                    .onAppear {
                        isVisualComplete = true
                    }

                // ── ENIGMA 2 ─────────────────────────────────────────────
                case .enigma2:
                    let word = "CONTRACT"
                    let letters = ["C","O","H","T","N","A","C","T","R"]

                    HStack(spacing: 40) {
                        // GAUCHE
                        ZStack {
                            Rectangle()
                                .foregroundColor(Color(hex: "2a2a2a"))
                                .cornerRadius(15)

                            ForEach($bookItems) { $item in
                                Image(item.imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 500)
                                    .position(item.position)
                                    .gesture(
                                        // ✅ FIX
                                        DragGesture(coordinateSpace: .named("enigma2Canvas"))
                                            .onChanged { value in
                                                item.position = CGPoint(
                                                    x: min(max(value.location.x, 90), 690),
                                                    y: item.position.y
                                                )
                                            }
                                    )
                            }

                            Image("etagere")
                                .scaledToFit()
                                .frame(width: 790)
                                .offset(y: 270)
                        }
                        .frame(width: 790, height: 650)
                        .clipped()
                        .coordinateSpace(name: "enigma2Canvas") // ✅ FIX
                        .padding(35)

                        // DROITE
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 60),
                            GridItem(.flexible(), spacing: 60),
                            GridItem(.flexible(), spacing: 60)
                        ], spacing: 60) {
                            ForEach(Array(letters.enumerated()), id: \.offset) { index, letter in
                                Button(action: {
                                    // ✅ FIX : était nextState: .enigma2 + onEnigma1Complete (double bug)
                                    handleLetterTap(letter: letter, index: index, word: word, nextState: .enigma3, onComplete: onEnigma2Complete)
                                }) {
                                    Text(letter)
                                        .font(.system(size: 50, weight: .medium, design: .monospaced))
                                        .foregroundColor(
                                            wrongLetter == letter ? .red :
                                                selectedLetters.contains(index) ? .clear : .white
                                        )
                                }
                            }
                        }
                        .frame(width: 200)
                        .padding(.horizontal, 70)
                        .offset(x: 10)
                    }
                    .onAppear {
                        isVisualComplete = true
                    }

                // ── ENIGMA 3 ─────────────────────────────────────────────
                case .enigma3:
                    let word = "DATA"
                    let letters = ["D","A","X","T","B","A","Q","R","M"]

                    HStack(spacing: 40) {
                        // GAUCHE — le puzzle
                        ZStack {
                            Rectangle()
                                .foregroundColor(Color(hex: "2a2a2a"))
                                .cornerRadius(15)

                            // Cibles grises
                            ForEach(puzzlePieces) { piece in
                                Rectangle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    .frame(width: 150, height: 150)
                                    .position(piece.targetPosition)
                            }

                            // Pièces draggables
                            ForEach($puzzlePieces) { $piece in
                                Image(piece.imageName)
                                    .resizable()
                                    .frame(width: 150, height: 150)
                                    .position(piece.position)
                                    .opacity(piece.isPlaced ? 1.0 : 0.85)
                                    .overlay(
                                        Rectangle()
                                            .stroke(piece.isPlaced ? Color.green : Color.clear, lineWidth: 2)
                                    )
                                    .gesture(
                                        // ✅ FIX
                                        DragGesture(coordinateSpace: .named("enigma3Canvas"))
                                            .onChanged { value in
                                                if !piece.isPlaced {
                                                    piece.position = value.location
                                                }
                                            }
                                            .onEnded { value in
                                                if !piece.isPlaced {
                                                    if distance(value.location, piece.targetPosition) < snapDistance {
                                                        withAnimation(SwiftUI.Animation.easeOut(duration: 0.2)) {
                                                            piece.position = piece.targetPosition
                                                            piece.isPlaced = true
                                                        }
                                                        if puzzlePieces.allSatisfy({ $0.isPlaced }) {
                                                            isVisualComplete = true
                                                        }
                                                    }
                                                }
                                            }
                                    )
                            }
                        }
                        .frame(width: 790, height: 650)
                        .clipped()
                        .coordinateSpace(name: "enigma3Canvas") // ✅ FIX
                        .padding(35)

                        // DROITE — lettres
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 60),
                            GridItem(.flexible(), spacing: 60),
                            GridItem(.flexible(), spacing: 60)
                        ], spacing: 60) {
                            ForEach(Array(letters.enumerated()), id: \.offset) { index, letter in
                                Button(action: {
                                    handleLetterTap(letter: letter, index: index, word: word, nextState: .enigma4, onComplete: onEnigma3Complete)
                                }) {
                                    Text(letter)
                                        .font(.system(size: 50, weight: .medium, design: .monospaced))
                                        .foregroundColor(
                                            wrongLetter == letter ? .red :
                                                selectedLetters.contains(index) ? .clear : .white
                                        )
                                        .scaleEffect(wrongLetter == letter ? 1.3 : 1.0)
                                }
                            }
                        }
                        .frame(width: 200)
                        .padding(.horizontal, 70)
                        .offset(x: 10)
                    }
                    .onAppear {
                        isVisualComplete = true
                    }

                // ── ENIGMA 4 ─────────────────────────────────────────────
                case .enigma4:
                    ZStack {
                       

                        // Slots visuels
                        ForEach(0..<8) { index in
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                .frame(width: 120, height: 50)
                                .position(slotPositions[index])
                        }

                        // Mots draggables
                        ForEach($wordItems) { $item in
                            Text(item.word)
                                .font(.system(size: 20, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                                .frame(width: 120, height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(item.isPlaced ? Color.green.opacity(0.3) : Color.black.opacity(0.6))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                )
                                .position(item.position)
                                .gesture(
                                    // ✅ FIX
                                    DragGesture(coordinateSpace: .named("enigma4Canvas"))
                                        .onChanged { value in
                                            if !item.isPlaced {
                                                item.position = value.location
                                            }
                                        }
                                        .onEnded { value in
                                            if !item.isPlaced {
                                                let correctSlot = slotPositions[item.correctIndex]
                                                if distance(value.location, correctSlot) < 60 {
                                                    withAnimation(SwiftUI.Animation.easeOut(duration: 0.2)) {
                                                        item.position = correctSlot
                                                        item.isPlaced = true
                                                    }
                                                    if wordItems.allSatisfy({ $0.isPlaced }) {
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                            enigmaState = .final
                                                            onEnigma4Complete()
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                )
                        }
                    }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)  
                        .coordinateSpace(name: "enigma4Canvas")

                case .final:
                    Text("final")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
}

#Preview(traits: .landscapeLeft) {
    EnigmaView(
        onEnigma1Complete: {},
        onEnigma2Complete: {},
        onEnigma3Complete: {},
        onEnigma4Complete: {}
    )
}

import SwiftUI

// Les structs partagées entre MiniPicordView et le reste du jeu
struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isAlex: Bool
}

struct Choice: Identifiable {
    let id = UUID()
    let text: String
}

struct Exchange {
    let alexIntro: [String]?
    let haruMessage: String
    let choices: [String]
}

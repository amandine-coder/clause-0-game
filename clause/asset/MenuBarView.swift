//
//  MenuBarView.swift
//  clause
//
//  Created by Amandine on 23/03/26.
//
//import SwiftUI
//import Combine
//
//struct MenuBarView: View {
//    @State private var currentTime = ""
//    @State private var currentDay = ""
//    
//    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
//    
//    var body: some View {
//        HStack {
//            Spacer()
//            Text("\(currentDay)  \(currentTime)")
//                .font(.system(size: 14))
//                .foregroundColor(.white)
//                .padding(.trailing, 20)
//        }
//        .frame(height: 30)
//        .background(Color(hex: "2a2a2a"))
//        .onReceive(timer) { _ in
//            let formatter = DateFormatter()
//            formatter.locale = Locale(identifier: "fr_FR")
//            formatter.dateFormat = "EEEE d MMM"
//            currentDay = formatter.string(from: Date())
//            formatter.dateFormat = "HH:mm"
//            currentTime = formatter.string(from: Date())
//        }
//        .onAppear {
//            let formatter = DateFormatter()
//            formatter.locale = Locale(identifier: "fr_FR")
//            formatter.dateFormat = "EEEE d MMM"
//            currentDay = formatter.string(from: Date())
//            formatter.dateFormat = "HH:mm"
//            currentTime = formatter.string(from: Date())
//        }
//    }
//}

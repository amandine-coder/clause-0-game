//
//  HomeView.swift
//  clause
//
//  Created by Amandine on 23/03/26.
//
import SwiftUI
struct HomeView: View {
    
    @Binding var gameStarted: Bool
    
    var body: some View {
        
        ZStack {
            Image("home")
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                Button (action: {
                    gameStarted = true
                }) {
                    Text ("START")
                        .font (.custom("Avenir Next", size: 32))
                        .foregroundColor(.white)
                        .padding(.horizontal,60)
                        .padding(.vertical,20)
                        .background(Color.black)
                        .cornerRadius(30)
                    
                }
                .padding(.bottom,130)
            }
        }
    }
}
#Preview (traits: .landscapeLeft){
    HomeView(gameStarted: .constant(false))
}


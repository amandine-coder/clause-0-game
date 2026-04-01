//
//  FileIconView.swift
//  clause
//
//  Created by Amandine on 23/03/26.
//
import SwiftUI

struct FileIconView: View {
    let emoji: String
    let fileName: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(emoji)
                .font(.system(size: 40))
            Text(fileName)
                .font(.system(size: 10))
                .foregroundColor(.white)
        }
    }
}

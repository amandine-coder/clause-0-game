//
//  SignatureView.swift
//  clause
//
//  Created by Amandine on 30/03/26.
//
import SwiftUI
import PencilKit

struct SignatureView: View {
    let onSigned: () -> Void

    @State private var canvasView = PKCanvasView()
    @State private var hasSignature = false
    @State private var showConfirm = false

    var body: some View {
        VStack(spacing: 12) {

            // Label
            HStack {
                Text("Sign here to accept")
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(Color(hex: "888888"))
                Spacer()
                if hasSignature {
                    Button(action: {
                        canvasView.drawing = PKDrawing()
                        hasSignature = false
                        showConfirm = false
                    }) {
                        Text("clear")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(Color(hex: "666666"))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 4)

            // Zone de signature
            ZStack {
                // Fond
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "1a1a1a"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(hasSignature ? 0.4 : 0.15), lineWidth: 1)
                    )

                // Ligne de base
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 1)
                    .padding(.horizontal, 20)
                    .offset(y: 20)

                // Canvas PencilKit
                SignatureCanvas(canvasView: $canvasView, onChanged: {
                    let strokes = canvasView.drawing.strokes
                    hasSignature = !strokes.isEmpty
                    if hasSignature {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            if !canvasView.drawing.strokes.isEmpty {
                                showConfirm = true
                            }
                        }
                    }
                })
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .frame(width: 500, height: 90)

            // Bouton ACCEPT — apparaît après signature
            if showConfirm {
                Button(action: {
                    withAnimation(.easeIn(duration: 0.3)) {
                        onSigned()
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                        Text("ACCEPT & SIGN")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(Color(hex: "2f2a28"))
                    .cornerRadius(20)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 2))
                }
                .buttonStyle(.plain)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                .animation(.spring(), value: showConfirm)
            }
        }
    }
}

// Wrapper UIViewRepresentable pour PKCanvasView
struct SignatureCanvas: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    let onChanged: () -> Void

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.backgroundColor = .clear
        canvasView.tool = PKInkingTool(.pen, color: .white, width: 2)
        canvasView.drawingPolicy = .anyInput  // doigt ou Pencil
        canvasView.delegate = context.coordinator
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onChanged: onChanged) }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        let onChanged: () -> Void
        init(onChanged: @escaping () -> Void) { self.onChanged = onChanged }
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) { onChanged() }
    }
}

#Preview(traits: .landscapeLeft) {
    ZStack {
        Color.black.ignoresSafeArea()
        SignatureView(onSigned: {})
    }
}

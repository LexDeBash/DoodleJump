//
//  ResultView.swift
//  DoodleJump
//
//  Created by Alexey Efimov on 13.09.2024.
//

import SwiftUI

struct ResultView: View {
    let score: Int
    let highScore: Int
    let resetAction: () -> Void
    
    var body: some View {
        VStack {
            Text("Game Over")
                .font(.largeTitle)
                .padding()
            Text("Score: \(score)")
                .font(.title)
            Text("BEST: \(highScore)")
                .padding()
            Button("RESET", action: resetAction)
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(.rect(cornerRadius: 10))
                .padding()
        }
        .background(.white.opacity(0.8))
        .clipShape(.rect(cornerRadius: 20))
    }
}

#Preview {
    ResultView(score: 5, highScore: 8, resetAction: {})
}

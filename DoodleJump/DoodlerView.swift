//
//  DoodlerView.swift
//  DoodleJump
//
//  Created by Alexey Efimov on 04.09.2024.
//

import SwiftUI

struct DoodlerView: View {
    // Высота дудлера передается через инициализацию
    let height: Double
    
    var body: some View {
        Circle()
            .frame(width: height)
            .foregroundStyle(.yellow)
            .overlay(
                Circle().stroke(Color.black, lineWidth: 2)
            )
    }
}

#Preview {
    DoodlerView(height: 50)
}

//
//  PlatformView.swift
//  DoodleJump
//
//  Created by Alexey Efimov on 04.09.2024.
//

import SwiftUI

struct PlatformView: View {
    let width: Double
    let height: Double
    
    var body: some View {
        Capsule()
            .frame(width: width, height: height)
            .foregroundStyle(.green)
    }
}

#Preview {
    PlatformView(width: 100, height: 20)
}

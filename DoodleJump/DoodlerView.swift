//
//  DoodlerView.swift
//  DoodleJump
//
//  Created by Alexey Efimov on 04.09.2024.
//

import SwiftUI

struct DoodlerView: View {
    
    let height: Double

    
    var body: some View {
        Image(.doodler)
            .resizable()
            .frame(width: height, height: height)
    }
}

#Preview {
    DoodlerView(height: 50)
}

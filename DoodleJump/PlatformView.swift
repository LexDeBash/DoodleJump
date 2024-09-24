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
    let platformType: PlatformType
    
    var body: some View {
        Image(platformType == .disappearingPlatform ? .platformYellow : .platformGreen)
            .resizable()
            .frame(width: width, height: height)
    }
}

#Preview {
    PlatformView(width: 100, height: 20, platformType: .staticPlatform)
}

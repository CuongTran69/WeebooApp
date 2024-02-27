//
//  LoadingView.swift
//  WeeBoo
//
//  Created by Cường Trần on 27/02/2024.
//

import Foundation
import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(AngularGradient(gradient: Gradient(colors: [.blue, .green, .yellow, .mint]), center: .center), style: StrokeStyle(lineWidth: 5, lineCap: .round))
            .frame(width: 50, height: 50)
            .rotationEffect(Angle(degrees: self.isAnimating ? 360 : 0))
            .animation(self.isAnimating ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default)
            .onAppear() {
                self.isAnimating = true
            }
            .onDisappear() {
                self.isAnimating = false
            }
    }
}

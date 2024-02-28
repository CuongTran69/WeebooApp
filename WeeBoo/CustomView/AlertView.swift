//
//  AlertView.swift
//  WeeBoo
//
//  Created by Cường Trần on 27/02/2024.
//

import Foundation
import SwiftUI
import Combine

class TimerManager: ObservableObject {
    @Published var timerFinished = false
    private var timer: AnyCancellable?
    
    func startTimer() {
        timerFinished = false
        var timeRemaining = 1
        
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    self.timerFinished = true
                    self.timer?.cancel()
                }
            }
    }
}

struct AlertView: View {
    var isSuccess: Bool
    var messageAlert: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: isSuccess ? "checkmark.circle" : "xmark.circle")
                .font(.largeTitle)
                .foregroundColor(isSuccess ? .green : .red)
            Text(messageAlert)
                .fontWeight(.medium)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}

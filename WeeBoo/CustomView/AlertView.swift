//
//  AlertView.swift
//  WeeBoo
//
//  Created by Cường Trần on 27/02/2024.
//

import Foundation
import SwiftUI

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

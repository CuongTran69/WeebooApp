//
//  HeaderView.swift
//  WeeBoo
//
//  Created by Cường Trần on 27/02/2024.
//

import Foundation
import SwiftUI

struct HeaderView: View {
    let viewModel   : AnimeViewModel
    let isGifActive : Bool
    
    var body: some View {
        HStack(spacing: 3) {
            Text("Image")
                .padding(5)
                .background(isGifActive ? Color.white : Color.black)
                .foregroundColor(isGifActive ? .black : .white)
                .cornerRadius(5)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(isGifActive ? Color.black : Color.white, lineWidth: 1)
                )
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        self.viewModel.action.accept(.activeTag(isTagGif: false))
                    }
                }
                .transition(.scale)
            
            Text("Gif")
                .padding(5)
                .background(isGifActive ? Color.black : Color.white)
                .foregroundColor(isGifActive ? .white : .black)
                .cornerRadius(5)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(isGifActive ? Color.white : Color.black, lineWidth: 1)
                )
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        self.viewModel.action.accept(.activeTag(isTagGif: true))
                    }
                }
                .transition(.scale)
        }
        .animation(.easeInOut, value: isGifActive)
        .padding(.bottom)
    }
}

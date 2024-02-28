//
//  HeaderView.swift
//  WeeBoo
//
//  Created by Cường Trần on 27/02/2024.
//

import Foundation
import SwiftUI

struct HeaderView: View {
    @EnvironmentObject var viewModel   : AnimeViewModel
    
    var body: some View {
        HStack(spacing: 3) {
            Text("Image")
                .padding(5)
                .background(viewModel.isGifActive ? Color.white : Color.black)
                .foregroundColor(viewModel.isGifActive ? .black : .white)
                .cornerRadius(5)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(viewModel.isGifActive ? Color.black : Color.white, lineWidth: 1)
                )
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        self.viewModel.setActiveTag(isGif: false)
                    }
                }
                .transition(.scale)
            
            Text("Gif")
                .padding(5)
                .background(viewModel.isGifActive ? Color.black : Color.white)
                .foregroundColor(viewModel.isGifActive ? .white : .black)
                .cornerRadius(5)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(viewModel.isGifActive ? Color.white : Color.black, lineWidth: 1)
                )
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        self.viewModel.setActiveTag(isGif: true)
                    }
                }
                .transition(.scale)
        }
        .animation(.easeInOut, value: viewModel.isGifActive)
        .padding(.bottom)
    }
}

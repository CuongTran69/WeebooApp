//
//  ContentView.swift
//  WeeBoo
//
//  Created by Cường Trần on 23/02/2024.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = AnimeViewModel()

    var body: some View {
        VStack {
            AsyncImage(url: URL(string: viewModel.imageURL)) { image in
                image
                    .resizable()
                    .cornerRadius(10)
                    .shadow(radius: 10)
            } placeholder: {
                ProgressView()
            }
            .aspectRatio(contentMode: .fit)
            .frame(width: 300, height: 300)
            
            Spacer()
            
            HStack {
                Button("Xem ảnh khác") {
                    viewModel.fetchImageAnime()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Button("Lưu ảnh này") {
                    guard !viewModel.imageURL.isEmpty else { return } 
                    viewModel.downloadAndSaveImage()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .onAppear {
            viewModel.fetchImageAnime()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

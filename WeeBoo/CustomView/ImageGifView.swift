//
//  ImageGifView.swift
//  WeeBoo
//
//  Created by Cường Trần on 28/02/2024.
//

import Foundation
import SwiftUI

struct ImageGifView: View {
    @EnvironmentObject var viewModel: AnimeViewModel
    
    var body: some View {
        if let animeModel = viewModel.animeModel {
            if animeModel.isGif(),
               let gifUrl = URL(string: animeModel.url) {
                GIFView(gifURL: gifUrl)
                    .scaledToFit()
                    .frame(minWidth: 200, maxWidth: 400)
                    .cornerRadius(10)
                    .shadow(radius: 10)
                    .padding(.horizontal)
                
                HStack(alignment: .top) {
                    Text("Movie Name:")
                    Text("\(animeModel.animeName ?? "")")
                        .bold()
                    
                    if let animeName = animeModel.animeName, let link = URL(string: "https://www.google.com/search?q=\(animeName)") {
                        Link(destination: link) { 
                            Image(systemName: "link")
                                .foregroundColor(.black)
                                .imageScale(.medium)
                        }
                    }
                }
                .padding()
            } else {
                AsyncImage(url: URL(string: animeModel.url)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case let .success(image):
                        image
                            .resizable()
                            .cornerRadius(10)
                            .shadow(radius: 10)
                    case .failure:
                        Image(systemName: "photo")
                    @unknown default:
                        Image(systemName: "photo")
                    }
                }
                .scaledToFit()
                .frame(width: 300, height: 300)
                
                HStack(alignment: .top) {
                    Text("Artist Name:")
                    Text("\(animeModel.artistName ?? "")")
                        .bold()
                    
                    if let artistName = animeModel.artistName, let link = URL(string: "https://www.google.com/search?q=\(artistName)") {
                        Link(destination: link) { 
                            Image(systemName: "link")
                                .foregroundColor(.black)
                                .imageScale(.medium)
                        }
                    }
                }
                .padding()
            }
        }
    }
}

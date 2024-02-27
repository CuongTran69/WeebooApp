//
//  BottomView.swift
//  WeeBoo
//
//  Created by Cường Trần on 27/02/2024.
//

import Foundation
import SwiftUI

struct BottomView: View {
    var viewModel: AnimeViewModel
    // State share
    @State private var shareSheetPresent    = false
    var itemsToShare                        : [Any]
    
    var body: some View {
        HStack {
            Button("Other") {
                viewModel.action.accept(.fetchAnimeImage(tag: viewModel.state.value.currentTag))
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Button("Save") {
                viewModel.action.accept(.downloadAndSaveImage)
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Button("Share") {
                shareSheetPresent = true
            }
            .padding()
            .background(.mint)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .sheet(isPresented: $shareSheetPresent) { 
            ShareSheet(items: itemsToShare)
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

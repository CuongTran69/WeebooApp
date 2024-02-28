//
//  BottomView.swift
//  WeeBoo
//
//  Created by Cường Trần on 27/02/2024.
//

import Foundation
import SwiftUI

struct BottomView: View {
    @EnvironmentObject var viewModel: AnimeViewModel
    // State share
    @State private var shareSheetPresent    = false
    
    var body: some View {
        HStack {
            Button("Other") {
                viewModel.fetchAnimeImage()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Button("Save") {
                viewModel.downloadAndSaveImage()
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
            ShareSheet(items: [viewModel.animeModel?.url ?? ""])
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

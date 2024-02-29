//
//  ButtonView.swift
//  WeeBoo
//
//  Created by Cường Trần on 27/02/2024.
//

import Foundation
import SwiftUI

struct ButtonView: View {
    @EnvironmentObject var viewModel: AnimeViewModel
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                HStack {
                    Text(" ")
                    Button { 
                        //TODO: 
                    } label: { 
                        Image(systemName: "list.bullet")
                            .imageScale(.medium)
                            .foregroundColor(.black)
                    }
                    .padding()
                }
                .background(.white)
                .cornerRadius(40)
                .shadow(radius: 10)
                .offset(x: -20)
                
                Spacer()
                
                VStack {
                    if let model = viewModel.animeModel {
                        Button { 
                            viewModel.fetchAnimeImage()
                        } label: { 
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .imageScale(.small)
                                .foregroundColor(.black)
                        }
                        .padding()
                        .background(model.url.isEmpty ? .gray : .white)
                        .clipShape(Circle())
                        
                        Button { 
                            viewModel.downloadAndSaveImage()
                        } label: { 
                            Image(systemName: "arrow.down.to.line")
                                .imageScale(.small)
                                .foregroundColor(.black)
                        }
                        .padding()
                        .background(model.url.isEmpty ? .gray : .white)
                        .clipShape(Circle())
                        
                        Button { 
                            viewModel.shareSheetPresent = true
                        } label: { 
                            Image(systemName: "arrowshape.turn.up.forward")
                                .imageScale(.small)
                                .foregroundColor(.black)
                        }
                        .padding()
                        .background(model.url.isEmpty ? .gray : .white)
                        .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .shadow(radius: 10)
                .sheet(isPresented: $viewModel.shareSheetPresent) { 
                    ShareSheet(items: [viewModel.animeModel?.url ?? ""])
                }
            }
            
            Spacer()
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

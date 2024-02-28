//
//  ContentView.swift
//  WeeBoo
//
//  Created by Cường Trần on 23/02/2024.
//

import SwiftUI
import RxSwift
import Combine
import UIKit

struct ContentView: View {
    @StateObject var viewModel          = AnimeViewModel()
    @ObservedObject var timerManager    = TimerManager()
    
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            ScrollView {
                VStack {
                    HeaderView()
                    
                    Spacer()
                    
                    if let animeModel = viewModel.animeModel {
                        if animeModel.isGif(),
                           let gifUrl = URL(string: animeModel.url) {
                            GIFView(gifURL: gifUrl)
                                .scaledToFit()
                                .frame(minWidth: 200, maxWidth: 400)
                                .cornerRadius(10)
                                .shadow(radius: 10)
                                .padding(.horizontal)
                            
                            HStack {
                                Text("Movie Name:")
                                Text("\(animeModel.animeName ?? "")")
                                    .bold()
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
                            
                            HStack {
                                Text("Artist Name:")
                                Text("\(animeModel.artistName ?? "")")
                                    .bold()
                            }
                            .padding()
                        }
                    }
                    
                    Spacer()
                    
                    TagView()
                    
                    Spacer()
                    
                    BottomView()
                }
            }
            
            if viewModel.showAlert.0, !timerManager.timerFinished {
                ZStack {
                    Color.black
                        .ignoresSafeArea()
                        .opacity(0.3)
                    
                    AlertView(isSuccess: viewModel.showAlert.0, messageAlert: viewModel.showAlert.1)
                        .onAppear {
                            timerManager.startTimer()
                        }
                }
            }
            
            if viewModel.isLoading {
                ZStack {
                    Color.black
                        .opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                    
                    LoadingView()
                        .transition(.opacity)
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            viewModel.fetchAnimeImage()
        }
        .alert(isPresented: $viewModel.isShowAppSettings) { 
            Alert(title: Text("Permission Denied"),
                  message: Text("Please enable access to your photos in the Settings app."),
                  primaryButton: .default(Text("Open settings"), action: { [self] in
                self.viewModel.openAppSettings()
            }),
                  secondaryButton: .cancel())
        }
        .environmentObject(viewModel)
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

class TimerManager: ObservableObject {
    @Published var timerFinished = false
    private var timer: AnyCancellable?
    
    func startTimer() {
        timerFinished = false
        var timeRemaining = 2
        
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

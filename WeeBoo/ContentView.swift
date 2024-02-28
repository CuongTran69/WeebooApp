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
    @ObservedObject var viewModel       = AnimeViewModel()
    @ObservedObject var timerManager    = TimerManager()
    
    // State loading
    @State private var isLoading        = false
    
    // State alert view
    @State private var showAlert        = false
    @State private var messageAlert     = ""
    @State private var isAlertSuccess   = false
    
    @State private var isGifActive      = false
    
    var body: some View {
        let state = viewModel.state.value
        ZStack {
            Color.white.ignoresSafeArea()
            
            ScrollView {
                VStack {
                    HeaderView(viewModel: viewModel, isGifActive: isGifActive)
                    
                    Spacer()
                    
                    if let animeModel = state.animeModel {
                        if viewModel.isGif,
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
                    
                    TagView(viewModel: viewModel, isReload: isGifActive)
                    
                    Spacer()
                    
                    BottomView(viewModel: viewModel, itemsToShare: [state.animeModel?.url ?? ""])
                }
            }
            
            if showAlert, !timerManager.timerFinished {
                ZStack {
                    Color.black
                        .ignoresSafeArea()
                        .opacity(0.3)
                    
                    AlertView(isSuccess: isAlertSuccess, messageAlert: messageAlert)
                        .onAppear {
                            timerManager.startTimer()
                        }
                }
            }
            
            if isLoading {
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
            viewModel.action.accept(.fetchAnimeImage(tag: state.currentTag))
            bindViewModel()
        }
        .alert(isPresented: $viewModel.isShowAppSettings) { 
            Alert(title: Text("Permission Denied"),
                  message: Text("Please enable access to your photos in the Settings app."),
                  primaryButton: .default(Text("Open settings"), action: { 
                viewModel.openAppSettings()
            }),
                  secondaryButton: .cancel())
        }
    }
    
    func bindViewModel() {
        viewModel.navigator
            .subscribe(onNext: { [self] navigator in
                switch navigator {
                case let .showAlert(isSuccess, message):
                    self.showAlert = true
                    self.messageAlert = message
                    self.isAlertSuccess = isSuccess
                }
            })
            .disposed(by: viewModel.disposeBag)
        
        viewModel.state.compactMap { $0.isLoading }
            .subscribe(onNext: { [self] loading in
                self.isLoading = loading
            })
            .disposed(by: viewModel.disposeBag)
        
        viewModel.state.compactMap { $0.isGifActive }
            .subscribe(onNext: { [self] isGifActive in
                self.isGifActive = isGifActive
            })
            .disposed(by: viewModel.disposeBag)
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

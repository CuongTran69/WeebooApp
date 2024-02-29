//
//  ContentView.swift
//  WeeBoo
//
//  Created by Cường Trần on 23/02/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel          = AnimeViewModel()
    @ObservedObject var timerManager    = TimerManager()
    
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            ScrollView {
                VStack {
                    HeaderView()
                    ImageGifView()
                    TagView()
                }
            }
            
            ButtonView()
            
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

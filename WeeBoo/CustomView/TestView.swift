//
//  TestView.swift
//  WeeBoo
//
//  Created by Cường Trần on 28/02/2024.
//

import Foundation
import SwiftUI

struct TestView: View {
    var body: some View {
        HStack(alignment: .top) {
            HStack {
                Text("   ")
                Button { 
                    
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
                Button { 
                    
                } label: { 
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .imageScale(.small)
                        .foregroundColor(.white)
                }
                .padding()
                .background(.red)
                .clipShape(Circle())
                
                Button { 
                    
                } label: { 
                    Image(systemName: "arrow.down.to.line")
                        .imageScale(.small)
                        .foregroundColor(.white)
                }
                .padding()
                .background(.red)
                .clipShape(Circle())
                
                Button { 
                    
                } label: { 
                    Image(systemName: "arrowshape.turn.up.right.fill")
                        .imageScale(.small)
                        .foregroundColor(.white)
                }
                .padding()
                .background(.red)
                .clipShape(Circle())
            }
            .padding()
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}

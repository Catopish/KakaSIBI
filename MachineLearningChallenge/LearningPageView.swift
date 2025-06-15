//
//  LearningPageView.swift
//  MachineLearningChallenge
//
//  Created by Lin Dan Christiano on 13/06/25.
//

import Foundation
import SwiftUI

struct LearningPageView: View {
    var body: some View {
        ZStack{
            VStack {
                GeometryReader {
                    geometry in
                    HStack {
                        Image(systemName: "chevron.left")
                            .frame(width: 32, height: 48)
                            .fontWeight(.bold)
                        Text("Pronoun")
                            .font(.system(size: 22, weight: .bold))
                    }
                    .frame(width: geometry.size.width, alignment: .leading)
                    //                .padding(8)
                    .background(Color.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.top)
                    
                    HStack (alignment: .bottom){
                        ZStack{
                            Color.red
//                            Text("Kaka")
                        }
                        .frame(width: geometry.size.width * 0.35, height: geometry.size.height * 0.9)
                        ZStack{
                            VStack {
                                Color.blue
                            }
                            
                        }
                        .frame(width: geometry.size.width * 0.64, height: geometry.size.height * 0.90)
                        
                    }
                    .frame(height: geometry.size.height)
    //                .background(Color.cyan)
                    .padding(.top, 25)
                }
            }
            .padding(8)
            ZStack {
                Color.gray
                    .frame(width: 600, height: 50)
            }
        }
        
    }
}

//#Preview {
//    LearningPageView()
//}

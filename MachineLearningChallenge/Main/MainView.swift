////
////  MainView.swift
////  MachineLearningChallenge
////
////  Created by Al Amin Dwiesta on 12/06/25.
////
//
//import SwiftUI
//import Foundation
//
//struct MainView: View {
//    var body: some View {
//        GeometryReader{
//            geometry in
//            HStack{
//                Color.blue
////                    .frame(width: geometry.size.width*0.6)
////                Color.red
////                    .frame(width: geometry.size.width*0.4)
//            }
//        }
//    }
//}
//
//#Preview {
//    MainView()
//}

import SwiftUI

// MARK: - Model

struct Level: Identifiable {
    let id: Int
    let title: String
    let content: String
}

// MARK: - View

struct MainView: View {
    // The currently selected level
    @State private var selectedLevel: Int = 1
    
    // Your four levels; replace the Lorem ipsum with real text as needed.
    
    
    var body: some View {
        GeometryReader {
            geometry in
            //                        HSplitView {
            // MARK: Left Panel
            ZStack {
                // Vertical line
                //                    VStack {
                //                        Spacer(minLength: 40)
                //                        Rectangle()
                //                            .fill(Color.gray.opacity(0.3))
                //                            .frame(width: 4)
                //                            .padding(.vertical, 20)
                //                        Spacer(minLength: 40)
                //                    }
                // Circles
                VStack() {
                    Text("Pilih Tingkatan Belajar")
                        .font(.title2.weight(.bold))
                        .padding(.bottom, 20)
                    ForEach(levels) { level in
                        CircleLevelView(levelID: level.id,
                                        isSelected: level.id == selectedLevel)
                        .onTapGesture {
                            withAnimation(.spring()) {
                                selectedLevel = level.id
                            }
                        }
                    }
                    .padding(.vertical,5)
                }
                .frame(
                    width:  geometry.size.width,
                    height: geometry.size.height,
                    alignment: .center
                )
            }
            //                .frame(minWidth: 200, maxWidth: 250)
            //                .padding()
            
            //                 MARK: Right Panel
            //                Divider()
            
            HStack {
                Spacer()
                ZStack {
                    VStack(alignment: .leading, spacing: 16) {
                        let detail = levels.first { $0.id == selectedLevel }!
                        
                        Text(detail.title)
                            .font(.title)
                            .bold()
                        
                        ScrollView {
                            Text(detail.content)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        Spacer()
                        
                        Button("Mulai Belajar") {
                            // primary action
                            print("Mulai Belajar tapped on level \(selectedLevel)")
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        
                        Button("Ulangi Boss Battle") {
                            // secondary action
                            print("Ulangi Boss Battle tapped on level \(selectedLevel)")
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                    .padding()
                    .frame(
                        minWidth: 0,
                        maxWidth: geometry.size.width * 0.4
                    )
                    .background(Color.black.opacity(0.9))
                }
            }
            //                        }
            //            .frame(minWidth: 700, minHeight: 400)
        }
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

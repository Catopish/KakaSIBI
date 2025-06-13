//
//  MainView.swift
//  MachineLearningChallenge
//
//  Created by Al Amin Dwiesta on 12/06/25.
//
import SwiftUI

// MARK: - Model

struct Level: Identifiable {
    let id: Int
    let title: String
    let content: String
}

// MARK: - View

struct MainView: View {
    @State private var selectedLevel: Int? = nil
    
    var body: some View {
        GeometryReader {
            geometry in
            // MARK: Left Panel
            ZStack {
                VStack() {
                    Text("Pilih Tingkatan Belajar")
                        .font(.title2.weight(.bold))
                        .padding(.bottom, 20)
                    ForEach(levels) { level in
                        CircleLevelView(levelID: level.id,
                                        isSelected: level.id == selectedLevel)
                        .onTapGesture {
                            withAnimation(.spring()) {
                                if selectedLevel == level.id {
                                    selectedLevel = nil
                                }else{
                                    selectedLevel = level.id
                                }
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
            
            //                 MARK: Right Panel
            if let id = selectedLevel, let detail = levels.first(where: { $0.id == id }) {
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
                                print("Mulai Belajar tapped on level \(selectedLevel)")
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            
                            Button("Ulangi Boss Battle") {
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
            }
        }
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

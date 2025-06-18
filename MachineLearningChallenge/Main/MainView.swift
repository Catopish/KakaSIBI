//
//  MainView.swift
//  MachineLearningChallenge
//
//  Created by Al Amin Dwiesta on 12/06/25.
//
import SwiftUI

struct MainView: View {
    @State private var selectedLevel: Int? = nil
    @State private var navigateToTesting: Bool = false
    @State private var navigateToGamePreview: Bool = false  // ✅ new

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: true) {
                        ZStack {
                            Image("LEVELSELECT_BG")
                                .resizable()
                                .scaledToFill()
                                .frame(width: geo.size.width,
                                       height: geo.size.height)
                            VStack() {
                                Spacer().frame(height: 72)
                                VStack(spacing: 150) {
                                    ForEach(levels.reversed()) { level in
                                        RectangleLevelView(
                                            levelID: level.id,
                                            isSelected: level.id == selectedLevel
                                        )
                                        .id(level.id)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            withAnimation(.spring()) {
                                                selectedLevel = (selectedLevel == level.id ? nil : level.id)
                                            }
                                        }
                                        .popover(
                                            isPresented: Binding(
                                                get:  { selectedLevel == level.id },
                                                set: { if !$0 { selectedLevel = nil } }
                                            ),
                                            arrowEdge: .trailing
                                        ) {
                                            ModalView(
                                                level: level,
                                                onStartLearning: {
                                                    navigateToTesting = true
                                                },
                                                onRepeatBossBattle: {
                                                    navigateToGamePreview = true
                                                }
                                            )
                                            .frame(
                                                minWidth: 300,
                                                idealWidth: 400,
                                                maxWidth: 600,
                                                minHeight: 200,
                                                idealHeight: 700,
                                                maxHeight: 1200
                                            )
                                            .padding()
                                        }
                                    }
                                }
                            }
                            .padding()
                        }
                        .padding(.vertical, 110)
                        .frame(minHeight: geo.size.height + 220)
                    }
                    .onAppear {
                        if let firstID = levels.first?.id {
                            proxy.scrollTo(firstID, anchor: .bottom)
                        }
                    }
                }
                .navigationDestination(isPresented: $navigateToTesting) {
                    TestingView(onBack: { navigateToTesting = false })
                }
                .navigationDestination(isPresented: $navigateToGamePreview) {  // ✅ new
                    GamePreview()  // <-- navigasi ke sini
                }
            }
        }
    }
}

struct ModalView: View {
    let level: Level
    let onStartLearning: () -> Void
    let onRepeatBossBattle: () -> Void  // ✅ new

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(level.title)
                .font(.title).bold()

            ScrollView {
                Text(level.content)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Button("Mulai Belajar") {
                onStartLearning()
            }
            .buttonStyle(PrimaryButtonStyle())

            Button("Ulangi Boss Battle") {
                onRepeatBossBattle()
            }
            .buttonStyle(SecondaryButtonStyle())
        }
    }
}


// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

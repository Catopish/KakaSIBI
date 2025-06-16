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
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: true) {
                        ZStack {
                            Image("LEVELSELECT_BG")
                                .resizable()                       // allow resizing
                                .scaledToFill()                    // fill and crop edges
                                .frame(width: geo.size.width,
                                       height: geo.size.height)  // exactly full screen
//                                .clipped()                         // chop off overflow
//                                .ignoresSafeArea()                // under status bar, etc.
                            VStack(spacing: 150) {
                                //            Text("Pilih Tingkatan Belajar")
                                //               .font(.title2.weight(.bold))
                                
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
                                        ModalView(level: level){
                                            navigateToTesting = true
                                        }
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
                                Color.clear
                                    .padding(.top,-200)
                                //                                .frame(height: geo.size.height * 0.2)
                            }
                            .padding()
                        }
                    }
                    .onAppear {
                        // scroll to Level 1 at launch:
                        if let firstID = levels.first?.id {
                            proxy.scrollTo(firstID, anchor: .bottom)
                        }
                    }
                }
                .navigationDestination(isPresented: $navigateToTesting) {
                    TestingView(onBack: { navigateToTesting = false })
                }
            }
        }
    }
}

struct ModalView: View {
    let level: Level
    let onStartLearning: () -> Void
    
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
            
            Button("Ulangi Boss Battle") { /*…*/ }
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

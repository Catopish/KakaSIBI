import SwiftUI
import AppKit       // for NSView
import AVFoundation // for AVCaptureSession

struct TestingView: View {
    @StateObject private var camera = CameraModel()
    let onBack: () -> Void
    // State untuk mengontrol apakah kartu terbuka atau tertutup
    @State private var isCardOpen: Bool = false
    @State private var selectedWord: String?     // ← track user’s choice
    @State private var showOverlay: Bool = false   // show big check
    
    @AppStorage("completedPronounsRaw") private var completedPronounsRaw: String = ""
    private var completedWords: Set<String> {
        get { Set(completedPronounsRaw
            .split(separator: ",")
            .map { String($0) }
            .filter { !$0.isEmpty }) }
        set { completedPronounsRaw = newValue.sorted().joined(separator: ",") }
    }
    
    // Tinggi penuh kartu saat terbuka
    let fullCardHeight: CGFloat = 250
    
    // Seberapa banyak kartu yang terlihat saat tertutup (di bagian bawah layar)
    let peekHeight: CGFloat = 40
    
    var body: some View {
        ZStack {
            // MARK: - Konten Utama Aplikasi
            Color.gray.opacity(0.1)
                .ignoresSafeArea()
                .overlay(
                    ZStack{
                        VStack {
                            GeometryReader {
                                geometry in
                                HStack {
                                    Button(action: {
                                        onBack()
                                    }) {
                                        HStack {
                                            Image(systemName: "chevron.left")
                                                .frame(width: 32, height: 48)
                                                .fontWeight(.bold)
                                            Text("Pilih Level")
                                                .font(.system(size: 20, weight: .semibold))
                                        }
                                    }
                                    Spacer()
                                    Text(camera.lastPrediction)
                                        .font(.system(size: 24, weight: .bold))
                                        .padding(.trailing, 112)
                                    Spacer()
                                }
                                .frame(width: geometry.size.width, alignment: .leading)
                                //                .padding(8)
                                .background(Color.gray)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .padding(.top)
                                
                                HStack (alignment: .bottom, spacing: 24){
                                    ZStack{
                                        Color.purple
                                        //                            Text("Kaka")
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .frame(width: geometry.size.width * 0.35, height: geometry.size.height * 0.9)
                                    ZStack{
                                        VStack {
                                            CameraPreview(session: camera.session)
                                            //                                                .frame(width: 640, height: 480)
                                                .cornerRadius(8)
                                                .shadow(radius: 4)
                                        }
                                        
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .frame(width: geometry.size.width * 0.635, height: geometry.size.height * 0.90)
                                    
                                }
                                .frame(height: geometry.size.height)
                                //                .background(Color.cyan)
                                .padding(.top, 35)
                            }
                        }
                        .padding(8)
                    }
                )
                .onTapGesture {
                    if isCardOpen{
                        isCardOpen.toggle()
                    }
                }
            
            // MARK: - Komponen Pembuka Kartu
            VStack {
                Spacer()
                CardView(
                    isCardOpen: $isCardOpen,
                    selectedWord: $selectedWord,
                    completedWords: completedWords
                )
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 25, topTrailingRadius: 25))
                .frame(height: fullCardHeight)
                .offset(y: isCardOpen ? 0 : fullCardHeight - peekHeight)
                .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.2), value: isCardOpen)
            }
            .ignoresSafeArea(.all, edges: .bottom)
            
            //MARK: Overlay cek bener apa engga
            if showOverlay {
                Color.black.opacity(0.4).ignoresSafeArea()
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 150, height: 150)
                    .foregroundColor(.green)
                    .transition(.scale.combined(with: .opacity))
            }
            
        }
        .navigationBarBackButtonHidden(true)
        .onAppear { camera.start() }
        .onChange(of: camera.lastPrediction) { newPrediction in
            guard let picked = selectedWord,
                  picked == newPrediction,
                  !completedWords.contains(picked)
            else { return }
            
            // mark done
            var updated = completedWords
            updated.insert(picked)
            // write straight to the @AppStorage backing store:
            completedPronounsRaw = updated
                .sorted()
                .joined(separator: ",")
            // show overlay briefly
            withAnimation {
                showOverlay = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    showOverlay = false
                }
            }
        }
    }
}

// MARK: - CardView (Tampilan Kartu Itu Sendiri)
struct CardView: View {
    @Binding var isCardOpen: Bool
    @Binding var selectedWord: String?        // ← bound from parent
    let completedWords: Set<String>
    
    let pronouns = ["Aku", "Kamu", "Mereka", "Dia", "Kita", "Kami"]
    
    var body: some View {
        ZStack {
            UnevenRoundedRectangle(topLeadingRadius: 25, topTrailingRadius: 25)
                .fill(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue]), startPoint: .top, endPoint: .bottom))
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: -5)
            
            VStack {
                // MARK: Chevron untuk Animasi
                HStack {
                    Spacer()
                    Text(isCardOpen ? "Tutup" : "Ingin Belajar Kata Ganti Lain? Pilih Disini!")
                    Image(systemName: "chevron.up") // Menggunakan ikon chevron ke atas
                        .font(.title2) // Ukuran ikon
                        .foregroundColor(.white.opacity(0.8))
                    //                        .padding(.bottom, isCardOpen ? 20 : 0)
                        .rotationEffect(.degrees(isCardOpen ? 180 : 0))
                        .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.2), value: isCardOpen)
                    Spacer()
                }
                .frame(width: .infinity)
                .padding(.vertical, 16)
                .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.4), Color.blue]), startPoint: .top, endPoint: .bottom))
                .onTapGesture {
                    isCardOpen.toggle()
                }
                Spacer()
                if isCardOpen {
                    Text("Pilih Kata Ganti")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.bottom, 8)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                        ForEach(pronouns, id: \.self) { word in
                            Button(action: {
                                // 1️⃣ record selection
                                selectedWord = word
                                print("\(word) tapped")
                                isCardOpen.toggle()
                            }) {
                                Text(word)
                                    .frame(maxWidth: .infinity, minHeight: 40)
                                    .background(Color.white.opacity(0.2))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                Spacer()
                                if completedWords.contains(word) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.yellow)
                                }
                                
                                if selectedWord == word {
                                    Image(systemName: "hand.point.up.left.fill")
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 50)
                } else {
                    Spacer()
                    Text("Tekan Chevron untuk Membuka")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.bottom, 20)
                }
            }
        }
        .frame(width: 1200)
    }
}

// MARK: - Preview untuk Xcode Canvas
//struct TestingView_Previews: PreviewProvider {
//    static var previews: some View {
//        TestingView()
//            .frame(width: 1500, height: 600)
//    }
//}

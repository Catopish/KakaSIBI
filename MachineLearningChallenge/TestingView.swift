import SwiftUI
import AppKit       // for NSView
import AVFoundation // for AVCaptureSession
//import TipKit
import AVKit

//struct videoTips: Tip {
//    var title: Text {
//        Text("Tonton tutorialnya dulu, ya!")
//    }
//    var message: Text? {
//        Text("Dengan nonton video ini dulu, kamu bakal lebih paham\ncara bikin gerakan bahasa isyarat.")
//    }
//    var image: Image? {
//        Image(systemName: "1.circle")
//    }
//}
//
//struct selectWordsTips: Tip {
//    var title: Text {
//        Text("Ketuk di sini buat ganti kata")
//    }
//    var message: Text? {
//        Text("Klik aja kalau mau ubah kata-katanya.")
//    }
//    var image: Image? {
//        Image(systemName: "3.circle")
//    }
//}
//
//struct videoPreviewTips: Tip {
//    var title: Text {
//        Text("Ayo peragakan lagi!")
//    }
//    var message: Text? {
//        Text("Coba ulangin gerakannya biar makin lancar.")
//    }
//    var image: Image? {
//        Image(systemName: "2.circle")
//    }
//}

struct TestingView: View {
    
    @State private var player = AVPlayer()
    @StateObject private var camera = CameraModel()
    let onBack: () -> Void
    // State untuk mengontrol apakah kartu terbuka atau tertutup
    @State private var isCardOpen: Bool = false
    @State private var selectedWord: String?     // ← track user's choice
    @State private var showOverlay: Bool = false   // show big check
    @State private var showCompletionModal = false
    let pronouns = ["Aku", "Kamu", "Dia", "Mereka", "Kita", "Kami"]
    @State private var showHelpModal = true
    
//    var videotips = videoTips()
//    var videopreviewtips = videoPreviewTips()
//    var selectwordstips = selectWordsTips()
    
//    @State private var tips: TipGroup = TipGroup(.ordered) {
//      videoTips()
//      videoPreviewTips()
//      selectWordsTips()
//    }

    @AppStorage("completedPronounsRaw") private var completedPronounsRaw: String = ""
    private var completedWords: Set<String> {
        get { Set(completedPronounsRaw
            .split(separator: ",")
            .map { String($0) }
            .filter { !$0.isEmpty }) }
        set { completedPronounsRaw = newValue.sorted().joined(separator: ",") }
    }
    
    // Tinggi penuh kartu saat terbuka
    let fullCardHeight: CGFloat = 170
    // Seberapa banyak kartu yang terlihat saat tertutup (di bagian bawah layar)
    let peekHeight: CGFloat = 0
    
    // untuk menyimpan sekarang di kata yang mana melalui index array pronouns
    @State private var currentIndex: Int = 0
    
    // Function untuk mendapatkan URL video berdasarkan kata
    func getVideoURL(for word: String) -> URL? {
        let videoName = word.lowercased()
        return Bundle.main.url(forResource: videoName, withExtension: "mov")
    }
    
    // function untuk update kata yang dipilih setelah pencet next/previous
    func updateSelectedWord(to index: Int) {
        let boundedIndex = min(max(index, 0), pronouns.count - 1)
        currentIndex = boundedIndex
        selectedWord = pronouns[boundedIndex]
    }
    
    // Function untuk update index berdasarkan kata yang dipilih
    func updateCurrentIndex(for word: String) {
        if let index = pronouns.firstIndex(of: word) {
            currentIndex = index
        }
    }
    
    @State private var navigateToGamePreview: Bool = false
    
    var body: some View {
        
        ZStack (alignment: .bottom){
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
                                        .padding(.trailing)
                                    }
                                    Spacer()
                                    Text("Kata Ganti")
                                        .font(.system(size: 24, weight: .bold))
                                        .padding(.trailing, 112)
                                    Spacer()
                                    Button{
                                        showHelpModal = true
                                    }label:{
                                        Image(systemName: "questionmark.circle.fill")
                                            .font(.system(size: 24))
                                            .padding(.trailing,20)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                .frame(width: geometry.size.width, alignment: .leading)
                                .background(Color.gray)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .padding(.top)
                                
                                HStack (alignment: .center, spacing: 24){
                                    ZStack {
                                        
                                        // Video berubah berdasarkan selectedWord
                                        if let selectedWord = selectedWord,
                                           let videoURL = getVideoURL(for: selectedWord) {
                                            
                                            VideoContainerView(videoURL: videoURL)
                                                .id(selectedWord) // Force refresh when word changes
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                                .frame(width: geometry.size.width * 0.35, height: geometry.size.height * 0.75)
                                            VStack {
                                                HStack{
                                                    Text("Perhatikan Video Tutorial Ini")
                                                        .font(.headline)
                                                }
                                                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 8, topTrailingRadius: 8))
                                                .frame(width: geometry.size.width * 0.35, height: 50)
                                                .background(Color.gray)
                                                .padding(.top, 70)
                                                Spacer()
                                            }
                                        } else {
                                            // Default video jika tidak ada yang dipilih
                                            VideoContainerView(videoURL: Bundle.main.url(forResource: "aku", withExtension: "mov")!)
                                                .id("aku") // Default ID
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                                .frame(width: geometry.size.width * 0.35, height: geometry.size.height * 0.75)
                                            VStack {
                                                HStack{
                                                    Text("Perhatikan Video Tutorial Ini")
                                                        .font(.headline)
                                                }
                                                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 8, topTrailingRadius: 8))
                                                .frame(width: geometry.size.width * 0.35, height: 50)
                                                .background(Color.gray)
                                                .padding(.top, 70)
                                                Spacer()
                                            }
                                        }

//                                        if let tip = tips.currentTip as? videoTips {
//                                            TipView(videotips, arrowEdge: .top)
//                                                .zIndex(1)
//                                                .padding(.bottom,-300)
//                                                .tipBackground(Color.black)
//                                                .fixedSize(horizontal: true, vertical: false)
//                                                .padding(.leading,50)
//                                        }
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .frame(width: geometry.size.width * 0.35, height: geometry.size.height * 0.9)
                                    
                                    ZStack{
                                        CameraPreview(session: camera.session,model: camera)
                                            .cornerRadius(8)
                                            .shadow(radius: 4)
                                        VStack {
                                            HStack{
                                                Text("Coba Peragakan Yang Sudah Dicontohkan Oleh Video Tutorial")
                                                    .font(.headline)
                                            }
                                            .clipShape(UnevenRoundedRectangle(topLeadingRadius: 8, topTrailingRadius: 8))
                                            .frame(width: geometry.size.width * 0.635, height: 50)
                                            .background(Color.gray)
//                                            .padding(.top, 70)
                                            Spacer()
                                        }
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .frame(width: geometry.size.width * 0.635, height: geometry.size.height * 0.75)
                                }
                                .frame(height: geometry.size.height)
//                                .padding(.top, )
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
            ZStack{
//                Spacer()
                VStack {
                    
                    CardView(
                        isCardOpen: $isCardOpen,
                        selectedWord: $selectedWord,
                        completedWords: completedWords,
                        pronouns: pronouns,
                        currentIndex: $currentIndex,
                        onWordSelected: { word in
                            // Update currentIndex ketika kata dipilih dari card
                            updateCurrentIndex(for: word)
                        }
                    )
                    .clipShape(UnevenRoundedRectangle(topLeadingRadius: 25, topTrailingRadius: 25))
                    .frame(height: fullCardHeight)
                    .offset(y: isCardOpen ? 0 : fullCardHeight - peekHeight)
                    .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.2), value: isCardOpen)
                    HStack(spacing: 80) {
                        Button(action: {
                            updateSelectedWord(to: currentIndex - 1)
                        }) {
                            Image(systemName: "chevron.left.circle.fill")
                                .resizable()
                                .frame(width: 48, height: 48)
                                .foregroundColor(currentIndex > 0 ? .blue : .white.opacity(0.5))
                        }
                        .disabled(currentIndex == 0)
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            isCardOpen.toggle()
                        }) {
                            HStack{
                                Text(pronouns[currentIndex])
                                Image(systemName: "chevron.up")
                            }
                            .frame(width: 200)
                            .font(.title)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .clipShape(Capsule())
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            updateSelectedWord(to: currentIndex + 1)
                        }) {
                            Image(systemName: "chevron.right.circle.fill")
                                .resizable()
                                .frame(width: 48, height: 48)
                                .foregroundColor(currentIndex < pronouns.count - 1 ? .blue : .white.opacity(0.5))
                        }
                        .disabled(currentIndex == pronouns.count - 1)
                        .buttonStyle(PlainButtonStyle())
                    }
                    .frame(width: 1500, height: 100)
                    .background(Color.gray)
                }

            }
            //            .frame(maxHeight: .infinity, alignment: .bottom)
//         if let tip = tips.currentTip as? selectWordsTips {
//            TipView(selectwordstips,arrowEdge: .bottom)
//                .zIndex(1)
//                .padding(.bottom,80)
//                .tipBackground(Color.black)
//                .fixedSize(horizontal: true, vertical: false)
//         }
            
            
        }
        //        ZStack{
        
        //        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            camera.start()
            updateSelectedWord(to: 0)
        }
        //MARK: uncomment this on prod
//        .task {
//            do {
//                try Tips.configure()
//            }
//            catch {
//                print("Error initializing TipKit \(error.localizedDescription)")
//            }
//        }
        .onChange(of: camera.lastPrediction) { newPrediction in
            guard let picked = selectedWord,
                  picked == newPrediction
            else { return }
            
            // ✅ Update completedWords jika belum ada
            var updated = completedWords
            if !updated.contains(picked) {
                updated.insert(picked)
                completedPronounsRaw = updated.sorted().joined(separator: ",")
            }
            
            // ✅ Tampilkan overlay (checkmark hijau)
            withAnimation {
                showOverlay = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    showOverlay = false
                }
            }
            
            // ✅ Cek apakah semua pronouns sudah selesai
            let allPronouns = pronouns
            if allPronouns.allSatisfy({ updated.contains($0) }) {
                showCompletionModal = true
            }
        }
        
        .sheet(isPresented: $showCompletionModal) {
//            NavigationStack {
                VStack(spacing: 20) {
                    Text("🎉 Kamu sudah membuka Training Ground!")
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Text("Ingin mencoba skill-mu?")
                        .font(.headline)
                    
                    HStack(spacing: 20) {
                        Button("Let's Go") {
                            // Navigasi ke halaman berikutnya
                            print("User chose to go!")
                            showCompletionModal = false
                            navigateToGamePreview = true
                            //                        GamePreview()
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        
                        Button("Do it Later") {
                            showCompletionModal = false
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.3))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                .padding()
                .frame(width: 400, height: 300)
                .navigationDestination(isPresented: $navigateToGamePreview) {  // ✅ new
                    GamePreview()  // <-- navigasi ke sini
                }
//            }
        }
        //MARK: Overlay cek bener apa engga
        ZStack {
            if showOverlay {
                Color.black.opacity(0.4).ignoresSafeArea()
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 150, height: 150)
                    .foregroundColor(.green)
                    .transition(.opacity)
            }
        }
        .background(
            NavigationLink(destination: GamePreview(), isActive: $navigateToGamePreview) {
                EmptyView()
            }
                .buttonStyle(PlainButtonStyle())
        )
        
        .animation(.easeInOut(duration: 0.3), value: showOverlay)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        if showHelpModal {
            ZStack{
                Color.black.opacity(0.4).ignoresSafeArea()
                HelpModalView(showHelpModal: $showHelpModal)
            }
            
        }
        
    }
}

// MARK: - CardView (Tampilan Kartu Itu Sendiri)
struct CardView: View {
    @Binding var isCardOpen: Bool
    @Binding var selectedWord: String?
    let completedWords: Set<String>
    let pronouns: [String]
    @Binding var currentIndex: Int
    let onWordSelected: (String) -> Void
    var body: some View {
        Spacer()
        ZStack {
            UnevenRoundedRectangle(topLeadingRadius: 25, topTrailingRadius: 25)
                .fill(LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.8), Color.gray]), startPoint: .top, endPoint: .bottom))
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: -5)
//                .background(Color.red)
            
            VStack {
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
                                // 2️⃣ Update current index
                                onWordSelected(word)
                                print("\(word) tapped")
                                isCardOpen.toggle()
                            }) {
                                HStack{
                                    Text(word)
                                        .frame(maxWidth: .infinity, minHeight: 40)
                                        .background(completedWords.contains(word) ? Color.green.opacity(0.5) : Color.blue.opacity(0.8))
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.white, lineWidth: selectedWord == word ? 2 : 0)
                                        )
                                    Spacer()
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                } else {
                    Spacer()
                        .padding(.bottom, -20)
                }
            }
        }
        .frame(width: 600)
    }
}

//struct HelpModalView: View {
//    @Binding var showHelpModal: Bool
//    
//    var body: some View {
//        ZStack {
//            //            Color.black.opacity(0.4)
//            //                .ignoresSafeArea()
//            VStack(spacing: 20) {
//                Text("Cara menggunakan aplikasi KakaSIBI")
//                    .font(.headline)
//                
//                VStack(alignment: .leading, spacing: 10) {
//                    Text("1. Posisikan diri Anda sejauh lengan Anda dari layar depan kamera.")
//                    Image("TestImageModal")
//                    Text("2. Tonton video instruksi terlebih dahulu.")
//                    Text("3. Peragakan ulang bahasa isyarat di depan kamera Anda.")
//                    Text("4. Jika gerakan sesuai, tanda centang akan muncul.")
//                    Text("5. Jika gerakan sesuai, tanda centang akan muncul.")
//                }
//                .font(.body)
//                
//                // Close button
//                Button {
//                    showHelpModal = false
//                } label: {
//                    Text("Tutup")
//                        .font(.headline)
//                        .padding(.horizontal, 24)
//                        .padding(.vertical, 12)
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(8)
//                }
//                .buttonStyle(.plain)
//            }
//            .padding()
//            .background(Color.black)
//            .cornerRadius(12)
//            .shadow(radius: 10)
//            .padding(.horizontal, 40)
//        }
//    }
//}


struct HelpModalView: View {
    @Binding var showHelpModal: Bool
    @State private var currentPage = 0
    
    private let helpTexts: [String] = [
        "1. Pastikan Anda di ruangan yang terang dan memiliki latar belakang yang bersih.",
        "2. Duduk dan posisikan diri Anda sejauh lengan Anda dari layar depan kamera.",
        "3. Tonton video instruksi terlebih dahulu.",
        "4. Peragakan ulang bahasa isyarat di depan kamera Anda.",
        "5. Jika gerakan sesuai, tanda centang akan muncul."
    ]
    
    private let images: [String] = [
        "TestImageModal"
    ]
        
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Text("Cara menggunakan aplikasi KakaSIBI")
                    .font(.headline)
                
                VStack(spacing: 16) {
                    Text(helpTexts[currentPage])
                        .font(.body)
                        .multilineTextAlignment(.leading)
                    
                    Image("TestImageModal")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)

                    // Dot indicators
                    HStack(spacing: 8) {
                        ForEach(0..<helpTexts.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? Color.white : Color.gray)
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.top, 8)
                }

                HStack {
                    // Back Button
                    if currentPage > 0 {
                        Button("Kembali") {
                            currentPage -= 1
                        }
                    }

                    Spacer()

                    // Next or Close Button
                    if currentPage < helpTexts.count - 1 {
                        Button("Lanjut") {
                            currentPage += 1
                        }
                    } else {
                        Button("Tutup") {
                            showHelpModal = false
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(8)
                    }
                }
                .font(.headline)
            }
            .padding()
            .background(Color.black)
            .cornerRadius(12)
            .shadow(radius: 10)
            .padding(.horizontal, 40)
            .foregroundColor(.white)
        }
    }
}
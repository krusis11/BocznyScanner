import SwiftUI
import UIKit
import CoreXLSX

struct HomeView: View {
    struct ScannerView: UIViewControllerRepresentable {
        @Binding var scannedCode: String?
        @Environment(\.presentationMode) var presentationMode
        
        func makeUIViewController(context: Context) -> ScannerViewController {
            let scannerVC = ScannerViewController()
            scannerVC.onCodeScanned = { code in
                scannedCode = code
                presentationMode.wrappedValue.dismiss()
            }
            return scannerVC
        }
        
        func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}
    }
    
    @State private var showScanner = false
    @State private var scannedCode: String?
    @State private var showFileBrowser = false
    @State private var selectedFile: URL?
    @State private var showPopup = false
    @State private var isFileSelected = false
    @State private var message = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Button("Skanuj kod") {
                    showScanner = true
                }
                .font(.title2)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .sheet(isPresented: $showScanner) {
                    ScannerView(scannedCode: $scannedCode)
                }
                
                if let code = scannedCode {
                    Text("Zeskanowany kod:")
                        .font(.headline)
                        .padding(.top)
                    Text(code)
                        .font(.largeTitle)
                        .foregroundColor(.green)
                        .padding()
                } else {
                    Text("Brak zeskanowanego kodu")
                        .foregroundColor(.gray)
                        .padding(.top)
                }
                
                if isFileSelected {
                    Button("Przetwórz plik") {
                        if let fileURL = selectedFile, let barcode = scannedCode {
                            processBarcodeData(from: fileURL, barcode: barcode)
                        }
                    }
                    .font(.title3)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.top)
                }
                
                Text(message)
                    .font(.title3)
                    .foregroundColor(.green)
                    .padding(.top)
            }
            .navigationTitle("Główne Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if selectedFile != nil {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showFileBrowser = true
                    }) {
                        Image(systemName: "folder")
                            .foregroundColor(.blue)
                    }
                    .sheet(isPresented: $showFileBrowser) {
                        FileBrowserView(selectedFile: $selectedFile, isFileSelected: $isFileSelected)
                            .onDisappear {
                                if selectedFile != nil {
                                    showPopup = true
                                }
                            }
                    }
                }
            }
            .alert(isPresented: $showPopup) {
                Alert(
                    title: Text("Plik załadowany"),
                    message: Text("Wybrano plik: \(selectedFile?.lastPathComponent ?? "")"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    func processBarcodeData(from excelFileURL: URL, barcode: String) {
        // Same implementation as in FileBrowserView's processBarcodeData method.
    }
}

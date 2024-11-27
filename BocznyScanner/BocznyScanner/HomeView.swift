import SwiftUI
import CoreXLSX
import UniformTypeIdentifiers
import MobileCoreServices
import Foundation

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
    @State private var isFileImporterPresented = false

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
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        isFileImporterPresented = true
                    }) {
                        Image(systemName: "folder")
                            .foregroundColor(.blue)
                    }
                    .fileImporter(
                        isPresented: $isFileImporterPresented,
                        allowedContentTypes: [UTType(filenameExtension: "xls")!, UTType(filenameExtension: "xlsx")!],
                        allowsMultipleSelection: false
                        
                        
                    ) { result in
                        handleFileSelection(result)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if selectedFile != nil {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
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
    /// Handles file selection from the file importer
    func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else {
                print("No files selected.")
                return
            }
            
            selectedFile = url
            isFileSelected = true
            showPopup = true
//            print("File selected: \(url.lastPathComponent)")
            
        case .failure(let error):
            print("Error selecting file: \(error.localizedDescription)")
        }
    }


    func processBarcodeData(from excelFileURL: URL, barcode: String) {
        do {
            let file = try XLSXFile(filepath: excelFileURL.path)
            
            // Assuming we are looking for a worksheet named "Laptopy"
            guard let worksheet = try file?.parseWorksheet(at: "Laptopy") else {
                message = "Worksheet 'Laptopy' not found."
                return
            }
            
            var dataSummary = "Processed rows:\n"
            
            // Iterate through rows to process data
            for row in worksheet.data?.rows ?? [] {
                let barcodeValue = getValueFromColumn(row: row, column: "pusta")
                dataSummary += "Barcode: \(barcodeValue)\n"
                // Add more fields if needed
            }
            
            message = dataSummary
            
        } catch {
            message = "Error processing file: \(error.localizedDescription)"
        }
    }
    
    func getValueFromColumn(row: Row, column: String) -> String {
        if let cell = row.cells.first(where: { $0.reference.column.description == column })?.value {
            return cell as? String ?? ""
        }
        return ""
    }
}

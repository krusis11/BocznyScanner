import SwiftUI
import CoreXLSX
import UniformTypeIdentifiers
import MobileCoreServices
import Foundation
import UIKit

struct FileBrowserView: View {
    @State private var selectedFile: URL?
    @State private var isFileSelected = false
    @State private var isFileImporterPresented = false
    @State private var fileProcessingResult: String? // To display results of file processing
    
    var body: some View {
        VStack {
            Button("Choose Excel File") {
                isFileImporterPresented = true
            }
            .fileImporter(
                isPresented: $isFileImporterPresented,
                allowedContentTypes: [UTType(filenameExtension: "xls")!, UTType(filenameExtension: "xlsx")!],
                allowsMultipleSelection: false
                
                
            ) { result in
                handleFileSelection(result)
                
            }

            .padding()
            
            if isFileSelected, let file = selectedFile {
                Text("Selected File: \(file.lastPathComponent)")
                    .padding()
                Button("Process File") {
                    processExcelFile(fileURL: file)
                }
                .padding()
            }
            
            if let result = fileProcessingResult {
                Text("File Processing Result: \(result)")
                    .padding()
                    .foregroundColor(.green)
            }
        }
        .padding()
    }
    
    
    /// Handles file selection and updates the state
    private func handleFileSelection(_ result: Result<[URL], Error>) {
        do {
            let urls = try result.get()
            if let url = urls.first {
                selectedFile = url
                isFileSelected = true
                
                print("Selected file: \(url)")
            }
        } catch {
            print("Error selecting file: \(error.localizedDescription)")
        }
    }
    
    /// Processes the selected Excel file and retrieves data
     func processExcelFile(fileURL: URL) {
        do {
            let file = try XLSXFile(filepath: fileURL.path)
            
            // Assuming we are looking for a worksheet named "Laptopy"
            guard let worksheet = try file?.parseWorksheet(at: "0") else {
                fileProcessingResult = "Worksheet 'Laptopy' not found."
                return
            }
            
            var dataSummary = "Processed rows:\n"
            
            // Iterate through rows to process data
            for row in worksheet.data?.rows ?? [] {
                let barcodeValue = getValueFromColumn(row: row, column: "pusta")
                dataSummary += "Barcode: \(barcodeValue)\n"
                // Add more fields if needed
            }
            
            fileProcessingResult = dataSummary
            
        } catch {
            fileProcessingResult = "Error processing file: \(error.localizedDescription)"
        }
    }
    
    /// Extracts value from a given column in a row
    func getValueFromColumn(row: Row, column: String) -> String {
        if let cell = row.cells.first(where: { $0.reference.column.description == column })?.value {
            return cell as? String ?? ""
        }
        return ""
    }
}

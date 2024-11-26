import SwiftUI
import UIKit
import UniformTypeIdentifiers
//import CoreXLSX
import CoreXLSX


//extension String {
//    var stringValue: String {
//        return self
//    }
//}
struct FileBrowserView: UIViewControllerRepresentable {
    @Binding var selectedFile: URL?
   // @Binding var barcode: String?
    @Binding var isFileSelected: Bool // Do śledzenia, czy plik został wybrany
    

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
//        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
//            if UIApplication.shared.canOpenURL(appSettings) {
//                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
//            }
//        }
//        let fileManager = FileManager.default
//        let documentsUrl = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)

        // Ograniczenie do plików Excel (.xls, .xlsx)
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType(filenameExtension: "xls")!, UTType(filenameExtension: "xlsx")!], asCopy: false)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false // Pozwala na wybór tylko jednego pliku
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: FileBrowserView

        init(_ parent: FileBrowserView) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first {
                parent.selectedFile = url // Przekaż wybrany plik
                parent.isFileSelected = true // Ustaw, że plik został wybrany
                print("Wybrano plik: \(url)")
            }
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            print("Anulowano wybór pliku")
        }
    }
    
    func processBarcodeData(from excelFileURL: URL, barcode: String) {
        do {
            // Otwórz plik Excel
            let file = try XLSXFile(filepath: excelFileURL.path)
            
            // Pobierz arkusz o nazwie "Laptopy"
            guard let worksheet = try file?.parseWorksheet(at: "Laptopy") else {
                print("Nie znaleziono arkusza 'Laptopy'.")
                return
            }
            
            // Zdefiniowanie zmiennych do przechowywania danych z wierszy
            var pusta: String = ""
            var specyfikacja: String = ""
            var sn: String = ""
            var zakup: String = ""
            var klasa: String = ""
            var wadyZListy: String = ""
            var dostawa: String = ""
            var m: String = ""
            var k: String = ""
            var o: String = ""
            var wady: String = ""
            var res: String = ""
            var grafa: String = ""
            var komentarz: String = ""
            var przeznaczenie: String = ""
            var lokalizacja: String = ""
            
            // Iteracja przez wiersze w arkuszu
            for row in worksheet.data!.rows {
                // Pobierz wartość z kolumny "pusta"
                let pustaValue = getValueFromColumn(row: row, column: "pusta")
                
                var barcodeToCompare = barcode
                
                // Usuń dwa pierwsze znaki, jeśli to są 0
                if barcodeToCompare.prefix(2) == "00" {
                    barcodeToCompare = String(barcodeToCompare.dropFirst(2))  // Konwersja Substring na String
                }
                
                // Porównaj zeskanowany kod z wartością w kolumnie "pusta"
                if pustaValue == barcodeToCompare {
                    // Znaleziono pasujący wiersz, teraz przypisz wartości z innych kolumn
                    specyfikacja = getValueFromColumn(row: row, column: "Specyfikacja")
                    sn = getValueFromColumn(row: row, column: "SN")
                    zakup = getValueFromColumn(row: row, column: "Zakup")
                    klasa = getValueFromColumn(row: row, column: "Klasa")
                    wadyZListy = getValueFromColumn(row: row, column: "Wady z listy")
                    dostawa = getValueFromColumn(row: row, column: "Dostawa")
                    m = getValueFromColumn(row: row, column: "M")
                    k = getValueFromColumn(row: row, column: "K")
                    o = getValueFromColumn(row: row, column: "O")
                    wady = getValueFromColumn(row: row, column: "Wady")
                    res = getValueFromColumn(row: row, column: "Res")
                    grafa = getValueFromColumn(row: row, column: "Grafa")
                    komentarz = getValueFromColumn(row: row, column: "Komentarz")
                    przeznaczenie = getValueFromColumn(row: row, column: "Przeznaczenie")
                    lokalizacja = getValueFromColumn(row: row, column: "Lokalizacja")
                    
                    // Wypisz dane
                    print("Dane z wiersza \(pustaValue):")
                    print("Pusta: \(pusta), Specyfikacja: \(specyfikacja), SN: \(sn), Zakup: \(zakup), Klasa: \(klasa), ...")
                    return // Zakończ po znalezieniu pasującego wiersza
                }
            }
            
            // Jeśli kod kreskowy nie został znaleziony
            print("Nie znaleziono pasującego kodu kreskowego.")
            
        } catch {
            print("Wystąpił błąd przy przetwarzaniu pliku Excel: \(error.localizedDescription)")
        }
    }


//    func getValueFromColumn(row: Row, column: String) -> String {
//        // Assuming Row is an array of cells in SwiftExcel
//        guard let columnIndex = row.cells(where: { $0.column == column }) else {
//            return "" // Return empty string if column not found
//        }
//        
//        // Access the cell value based on the column index
//        let cell = row[columnIndex]
//        
//        switch cell.type {
//        case .string:
//            return cell.stringValue ?? "" // Handle optional value
//        case .double:
//            return String(cell.doubleValue ?? 0.0) // Convert Double to String
//        case .date:
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd"
//            return dateFormatter.string(from: cell.dateValue ?? Date())
//        default:
//            return "" // Return empty for unsupported types
//        }
//    }

    func getValueFromColumn(row: Row, column: String) -> String {
        // Szukamy wartości komórki w danej kolumnie
        if let cell = row.cells.first(where: { $0.reference.column.description == column })?.value {
            return cell as? String ?? "" // Zwracamy wartość, jeśli to string
        }
        return ""
    }














}


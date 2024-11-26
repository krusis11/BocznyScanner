import SwiftUI

struct FilePreviewView: View {
    let file: URL

    @State private var fileContent: String = ""
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            if let error = errorMessage {
                Text("Nie można załadować pliku:")
                    .font(.headline)
                    .foregroundColor(.red)
                Text(error)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                ScrollView {
                    Text(fileContent)
                        .padding()
                        .multilineTextAlignment(.leading)
                        .font(.body)
                }
            }
        }
        .navigationTitle(file.lastPathComponent)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadFileContent()
        }
        .padding()
    }

    private func loadFileContent() {
        do {
            fileContent = try String(contentsOf: file, encoding: .utf8)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

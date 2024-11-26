import SwiftUI

struct CodeDisplayView: View {
    let scannedCode: String

    var body: some View {
        VStack {
            Text("Zeskanowany Kod")
                .font(.largeTitle)
                .padding()

            Text(scannedCode)
                .font(.title)
                .foregroundColor(.blue)
                .padding()
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding()
        .navigationTitle("Wynik Skanowania")
    }
}

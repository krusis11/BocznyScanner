import Foundation


extension URL: Identifiable {
    public var id: String { self.absoluteString } // Unikalny identyfikator oparty na ścieżce URL
}

import SwiftUI

extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1.0)
    }
}

//creates a global variable for a color
public var peach = Color(hex: "EBA793")
public var maroon = Color(hex: "8B6466")
public var brown = Color(hex: "3D2829")
// From lightest to darkest
public var blue1 = Color(hex: "B6D3E5")
public var blue2 = Color(hex: "6194B0")
public var blue3 = Color(hex: "29537C")
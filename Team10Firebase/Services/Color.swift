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
public var lightBrown = Color(hex: "CEA07E")
public var darkBrown = Color(hex: "775139")
public var lightBlue = Color(hex: "D8E9F5")
public var mediumBlue = Color(hex: "89BBDE")
public var darkBlue = Color(hex: "191D32")
public var tan = Color(hex: "EBDBCE")

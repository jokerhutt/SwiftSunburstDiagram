import AppKit
import CoreGraphics
extension NSColor {
    func lighter(by fraction: CGFloat = 0.2) -> NSColor {
        guard let rgbColor = self.usingColorSpace(.deviceRGB) else { return self }
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        rgbColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Increase each channel toward 1.0 by fraction
        red = min(red + (1.0 - red) * fraction, 1.0)
        green = min(green + (1.0 - green) * fraction, 1.0)
        blue = min(blue + (1.0 - blue) * fraction, 1.0)
        
        return NSColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    func rotatedHue(by fraction: CGFloat) -> NSColor {
        // Convert to RGB color space for safe hue extraction
        guard let rgbColor = self.usingColorSpace(.deviceRGB) else {
            return self // fallback to original if conversion fails
        }

        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        // Extract HSB components
        rgbColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

        // Calculate new hue with wrapping
        let newHue = fmod(hue + fraction, 1.0)

        // Return new NSColor with rotated hue and same saturation, brightness, alpha
        return NSColor(hue: newHue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
}

//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit

// MARK: - Colors

public struct Colors: SafeResource {

    var stub: UIColor { .white }

    init() {}
}

// MARK: - App Colors

extension Colors {

    // MARK: - Label

    public var labelPrimary: UIColor { valueOrStub("label_primary") }
    public var labelPrimaryVariant: UIColor { valueOrStub("label_primary_variant") }
    public var labelSecondary: UIColor { valueOrStub("label_secondary") }
    public var labelSecondaryVariant: UIColor { valueOrStub("label_secondary_variant") }

    // MARK: - Background

    public var backgroundPrimary: UIColor { valueOrStub("background_primary") }
    public var backgroundSecondary: UIColor { valueOrStub("background_secondary") }
    public var backgroundSecondaryDisabled: UIColor { valueOrStub("background_secondary_disabled") }
    public var backgroundSecondaryVariant: UIColor { valueOrStub("background_secondary_variant") }
    public var backgroundTertiary: UIColor { valueOrStub("background_tertiary") }
    public var backgorundBorderDisabled: UIColor { valueOrStub("backgorund_border_disabled") }
    
    public var blueVk: UIColor { valueOrStub("blue_vk") }

    // MARK: - Fill

    public var fillPrimary: UIColor { valueOrStub("fill_primary") }
    public var fillPrimaryVariant: UIColor { valueOrStub("fill_primary_variant") }
}

// MARK: - Color Palette

extension Colors {
    
    public struct PaletteItem {
        public let color: UIColor
        public let name: String
        public let hexAndRgba: String
    }
    
    private var allColors: [PaletteItem] {
        [
            .init(color: labelPrimary, name: "labelPrimary", hexAndRgba: showHexAndRgba(from: labelPrimary)),
            .init(color: labelPrimaryVariant, name: "labelPrimaryVariant", hexAndRgba: showHexAndRgba(from: labelPrimaryVariant)),
            .init(color: labelSecondary, name: "labelSecondary", hexAndRgba: showHexAndRgba(from: labelSecondary)),
            .init(color: labelSecondaryVariant, name: "labelSecondaryVariant", hexAndRgba: showHexAndRgba(from: labelSecondaryVariant)),
            .init(color: backgroundPrimary, name: "backgroundPrimary", hexAndRgba: showHexAndRgba(from: backgroundPrimary)),
            .init(color: backgroundSecondary, name: "backgroundSecondary", hexAndRgba: showHexAndRgba(from: backgroundSecondary)),
            .init(color: backgroundSecondaryDisabled, name: "backgroundSecondaryDisabled", hexAndRgba: showHexAndRgba(from: backgroundSecondaryDisabled)),
            .init(color: backgroundSecondaryVariant, name: "backgroundSecondaryVariant", hexAndRgba: showHexAndRgba(from: backgroundSecondaryVariant)),
            .init(color: backgroundTertiary, name: "backgroundTertiary", hexAndRgba: showHexAndRgba(from: backgroundTertiary)),
            .init(color: backgorundBorderDisabled, name: "backgroundBorderDisabled", hexAndRgba: showHexAndRgba(from: backgorundBorderDisabled)),
            .init(color: fillPrimary, name: "fillPrimary", hexAndRgba: showHexAndRgba(from: fillPrimary)),
            .init(color: fillPrimaryVariant, name: "fillPrimaryVariant", hexAndRgba: showHexAndRgba(from: fillPrimaryVariant))
        ]
    }
    
    public var colorSections: [[PaletteItem]] {
        var labelColors: [PaletteItem] = []
        var backgroundColors: [PaletteItem] = []
        var fillColors: [PaletteItem] = []
        
        for color in allColors {
            if color.name.contains("label") {
                labelColors.append(color)
            } else if color.name.contains("background") {
                backgroundColors.append(color)
            } else if color.name.contains("fill") {
                fillColors.append(color)
            }
        }
        
        var allSections: [[PaletteItem]] = []
        allSections.append(labelColors)
        allSections.append(backgroundColors)
        allSections.append(fillColors)
        
        return allSections
    }
    
    private func showHexAndRgba(from color: UIColor) -> String {
        let components = color.cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0
        let a: CGFloat = components?[3] ?? 0.0

        let hexString = String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
        let rgbaString = String.init(" (\(lroundf(Float(r * 100))), \(lroundf(Float(g * 100))), \(lroundf(Float(b * 100))), A\(lroundf(Float(a * 100))))")

        return hexString + rgbaString
     }
}

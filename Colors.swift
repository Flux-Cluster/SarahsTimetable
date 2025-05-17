import SwiftUI

struct AppColors {
    static let rivieraGreen = Color(red: 111/255, green: 167/255, blue: 161/255) // #6FA7A1
    static let creamyWhite = Color(red: 245/255, green: 241/255, blue: 232/255) // #F5F1E8
    static let tyreRubber = Color(red: 28/255, green: 28/255, blue: 28/255) // #1C1C1C
    static let black = Color.black // #000000
    // Add other colours if needed (e.g., foot mats grey, chrome) but stick to a minimal palette.
}

struct AppGradient {
    static let background = LinearGradient(
        gradient: Gradient(colors: [AppColors.rivieraGreen, AppColors.creamyWhite]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}


import SwiftUI

extension Color {
  init(hex: String) {
    let value =
      UInt64(hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted), radix: 16) ?? 0
    self.init(
      .sRGB, red: Double((value >> 16) & 0xff) / 255, green: Double((value >> 8) & 0xff) / 255,
      blue: Double(value & 0xff) / 255, opacity: 1)
  }
  static let condesaBackground = Color(hex: "0f0d0b")
  static let condesaAccent = Color(hex: "c8966c")
  static let condesaText = Color(hex: "f5f0e8")
  static let condesaSurface = Color(hex: "1c1712")
  static let condesaInk = Color(hex: "241407")
}

struct PrimaryButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label.font(.headline).foregroundStyle(Color.condesaInk).frame(maxWidth: .infinity)
      .padding(.vertical, 15)
      .background(
        Color.condesaAccent.opacity(configuration.isPressed ? 0.75 : 1),
        in: RoundedRectangle(cornerRadius: 14))
  }
}

struct CoffeePlaceholder: View {
  let category: MenuCategory
  private var colors: [Color] {
    category == .seasonal
      ? [Color(hex: "9fae7a"), Color(hex: "4d5a34")] : [.condesaAccent, Color(hex: "6b4426")]
  }
  var body: some View {
    ZStack {
      LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
      Image(systemName: category == .food ? "takeoutbag.and.cup.and.straw" : "cup.and.saucer.fill")
        .font(.system(size: 29)).foregroundStyle(.condesaText.opacity(0.75))
    }
  }
}

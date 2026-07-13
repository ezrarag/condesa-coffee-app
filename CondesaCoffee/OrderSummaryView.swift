import SwiftUI

struct OrderSummaryView: View {
  @EnvironmentObject private var state: AppState
  var body: some View {
    VStack(spacing: 0) {
      ScrollView {
        VStack(spacing: 0) {
          ForEach(state.cart) { item in
            HStack(alignment: .top) {
              VStack(alignment: .leading, spacing: 4) {
                Text("\(item.quantity)× \(item.name)").font(.headline)
                Text(item.customizationSummary).font(.caption).foregroundStyle(
                  .condesaText.opacity(0.55))
              }
              Spacer()
              Text(item.lineTotal, format: .currency(code: "USD")).fontWeight(.semibold)
            }.padding(.vertical, 15)
            Divider().overlay(.condesaText.opacity(0.1))
          }
          VStack(alignment: .leading, spacing: 8) {
            Text("TABLE / ROOM").font(.caption.bold()).tracking(1).foregroundStyle(
              .condesaText.opacity(0.55))
            TextField("Table 12 or Room 204", text: $state.roomOrTable).fontWeight(.semibold)
              .padding(14).background(Color(hex: "241d17"), in: RoundedRectangle(cornerRadius: 12))
              .overlay(RoundedRectangle(cornerRadius: 12).stroke(.condesaAccent))
          }.padding(.vertical, 24)
          VStack(spacing: 9) {
            totalRow("Subtotal", state.subtotal)
            totalRow("Tax", state.tax)
            Divider().overlay(.condesaText.opacity(0.1))
            totalRow("Total", state.total, bold: true)
          }
        }.padding(20)
      }.background(Color.condesaBackground)
      NavigationLink(destination: CheckoutView()) { Text("Checkout") }.buttonStyle(
        PrimaryButtonStyle()
      ).disabled(state.roomOrTable.trimmingCharacters(in: .whitespaces).isEmpty).opacity(
        state.roomOrTable.isEmpty ? 0.45 : 1
      ).padding(20).background(Color.condesaBackground)
    }
    .navigationTitle("Your Order").navigationBarTitleDisplayMode(.large).foregroundStyle(
      .condesaText)
  }
  private func totalRow(_ name: String, _ value: Double, bold: Bool = false) -> some View {
    HStack {
      Text(name)
      Spacer()
      Text(value, format: .currency(code: "USD"))
    }.font(bold ? .title3.bold() : .subheadline).foregroundStyle(
      bold ? .condesaText : .condesaText.opacity(0.6))
  }
}

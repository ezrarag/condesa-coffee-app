import SwiftUI

struct ItemDetailView: View {
  @EnvironmentObject private var state: AppState
  @Environment(\.dismiss) private var dismiss
  let item: MenuItem
  @State private var milk: MilkType = .oat
  @State private var shots = 2
  @State private var quantity = 1
  @State private var notes = ""
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 22) {
        CoffeePlaceholder(category: item.category).frame(height: 210).clipShape(
          RoundedRectangle(cornerRadius: 20))
        VStack(alignment: .leading, spacing: 6) {
          HStack {
            Text(item.name).font(.title.bold())
            Spacer()
            Text(item.price, format: .currency(code: "USD")).font(.title3.bold()).foregroundStyle(
              .condesaAccent)
          }
          Text(item.description).foregroundStyle(.condesaText.opacity(0.55))
        }
        LabeledSection("Milk") {
          HStack(spacing: 7) {
            ForEach(MilkType.allCases) { option in
              Button(option.rawValue) { milk = option }.font(.caption.bold()).foregroundStyle(
                milk == option ? Color.condesaInk : .condesaText.opacity(0.6)
              ).frame(maxWidth: .infinity).padding(.vertical, 10).background(
                milk == option ? Color.condesaAccent : .condesaSurface,
                in: RoundedRectangle(cornerRadius: 10))
            }
          }
        }
        HStack {
          Text("SHOTS").sectionLabel()
          Spacer()
          Stepper("\(shots)", value: $shots, in: 1...4).fixedSize()
        }
        LabeledSection("Notes") {
          TextField("Extra hot, no foam…", text: $notes, axis: .vertical).padding(13).background(
            Color.condesaSurface, in: RoundedRectangle(cornerRadius: 12))
        }
        HStack {
          Text("QUANTITY").sectionLabel()
          Spacer()
          Stepper("\(quantity)", value: $quantity, in: 1...10).fixedSize()
        }
      }.padding(20)
    }.foregroundStyle(.condesaText).background(Color.condesaBackground)
      .safeAreaInset(edge: .bottom) {
        Button("Add to Order · \(item.price * Double(quantity),format:.currency(code:"USD"))") {
          state.add(item, milk: milk, shots: shots, notes: notes, quantity: quantity)
          dismiss()
        }.buttonStyle(PrimaryButtonStyle()).padding(20).background(Color.condesaBackground)
      }
  }
}

private struct LabeledSection<Content: View>: View {
  let label: String
  @ViewBuilder let content: Content
  init(_ label: String, @ViewBuilder content: () -> Content) {
    self.label = label
    self.content = content
  }
  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text(label.uppercased()).sectionLabel()
      content
    }
  }
}
extension Text {
  fileprivate func sectionLabel() -> some View {
    self.font(.caption.bold()).tracking(1).foregroundStyle(Color.condesaText.opacity(0.55))
  }
}

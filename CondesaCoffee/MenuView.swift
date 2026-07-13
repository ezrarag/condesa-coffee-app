import SwiftUI

struct MenuView: View {
  @EnvironmentObject private var state: AppState
  @State private var category: MenuCategory = .espresso
  private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        VStack(alignment: .leading, spacing: 4) {
          Text("CONDÉSA COFFEE").font(.caption.bold()).tracking(2).foregroundStyle(.condesaAccent)
          Text("What can we make you?").font(.largeTitle.bold()).foregroundStyle(.condesaText)
        }
        ScrollView(.horizontal, showsIndicators: false) {
          HStack {
            ForEach(MenuCategory.allCases) { item in
              Button(item.rawValue) { category = item }.font(.subheadline.bold()).foregroundStyle(
                category == item ? Color.condesaInk : .condesaText.opacity(0.55)
              ).padding(.horizontal, 15).padding(.vertical, 10).background(
                category == item ? Color.condesaAccent : .condesaSurface, in: Capsule()
              ).overlay(Capsule().stroke(.condesaText.opacity(category == item ? 0 : 0.1)))
            }
          }
        }
        LazyVGrid(columns: columns, spacing: 12) {
          ForEach(state.menuItems.filter { $0.category == category && $0.available }) { item in
            NavigationLink(value: item) { MenuItemCard(item: item) }.buttonStyle(.plain)
          }
        }
      }.padding(20)
    }
    .background(Color.condesaBackground).navigationDestination(for: MenuItem.self) {
      ItemDetailView(item: $0)
    }
    .safeAreaInset(edge: .bottom) {
      if !state.cart.isEmpty {
        NavigationLink(destination: OrderSummaryView()) {
          HStack {
            Text("View order")
            Spacer()
            Text(
              "\(state.cart.count) item\(state.cart.count == 1 ? "" : "s") · \(state.total,format:.currency(code:"USD"))"
            )
          }
        }.buttonStyle(PrimaryButtonStyle()).padding(.horizontal, 20).padding(.bottom, 8).background(
          Color.condesaBackground)
      }
    }
  }
}

private struct MenuItemCard: View {
  let item: MenuItem
  var body: some View {
    VStack(alignment: .leading, spacing: 9) {
      CoffeePlaceholder(category: item.category).frame(height: 112).clipShape(
        RoundedRectangle(cornerRadius: 12))
      Text(item.name).font(.headline).foregroundStyle(.condesaText).lineLimit(1)
      Text(item.description).font(.caption).foregroundStyle(.condesaText.opacity(0.55)).lineLimit(2)
        .frame(height: 32, alignment: .top)
      Text(item.price, format: .currency(code: "USD")).font(.subheadline.bold()).foregroundStyle(
        .condesaAccent)
    }.padding(10).background(Color.condesaSurface, in: RoundedRectangle(cornerRadius: 16)).overlay(
      RoundedRectangle(cornerRadius: 16).stroke(.condesaText.opacity(0.1)))
  }
}

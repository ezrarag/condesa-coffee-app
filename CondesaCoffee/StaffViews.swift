import SwiftUI

struct OrderQueueView: View {
  @EnvironmentObject private var state: AppState
  var body: some View {
    ScrollView {
      LazyVStack(spacing: 12) {
        ForEach(state.orders) { order in
          Button {
            state.advance(order)
          } label: {
            VStack(alignment: .leading, spacing: 7) {
              HStack {
                Text(order.roomOrTable).font(.headline)
                Spacer()
                StatusBadge(status: order.status)
              }
              Text(
                order.items.map { $0.quantity > 1 ? "\($0.name) ×\($0.quantity)" : $0.name }.joined(
                  separator: ", ")
              ).font(.subheadline).foregroundStyle(.condesaText.opacity(0.55))
              Text(order.createdAt, style: .relative).font(.caption).foregroundStyle(
                .condesaText.opacity(0.35))
            }.padding(16).background(Color.condesaSurface, in: RoundedRectangle(cornerRadius: 16))
              .overlay(RoundedRectangle(cornerRadius: 16).stroke(.condesaText.opacity(0.1)))
          }.buttonStyle(.plain)
        }
      }.padding(20)
    }.background(Color.condesaBackground).navigationTitle("Queue").safeAreaInset(edge: .top) {
      HStack {
        Spacer()
        Text("\(state.orders.count) orders").font(.caption).foregroundStyle(
          .condesaText.opacity(0.55)
        ).padding(.trailing, 20)
      }
    }.onAppear { state.startListening() }
  }
}
private struct StatusBadge: View {
  let status: OrderStatus
  var color: Color {
    switch status {
    case .pending: return .condesaAccent
    case .brewing: return Color(hex: "e0913f")
    case .ready: return Color(hex: "8bab6e")
    case .pickedUp: return .condesaText.opacity(0.15)
    }
  }
  var body: some View {
    Text(status.rawValue).font(.caption.bold()).foregroundStyle(
      status == .pickedUp ? .condesaText : .condesaInk
    ).padding(.horizontal, 10).padding(.vertical, 5).background(color, in: Capsule())
  }
}

struct MenuAdminView: View {
  @EnvironmentObject private var state: AppState
  var body: some View {
    ScrollView {
      LazyVStack(spacing: 10) {
        ForEach(state.menuItems) { item in
          HStack(spacing: 12) {
            CoffeePlaceholder(category: item.category).frame(width: 42, height: 42).clipShape(
              RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading) {
              Text(item.name).font(.headline)
              Text("\(item.category.rawValue) · \(item.price,format:.currency(code:"USD"))").font(
                .caption
              ).foregroundStyle(.condesaText.opacity(0.4))
            }
            Spacer()
            Toggle(
              "Available", isOn: Binding(get: { item.available }, set: { _ in state.toggle(item) })
            ).labelsHidden().tint(.condesaAccent)
          }.padding(13).background(Color.condesaSurface, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(.condesaText.opacity(0.1)))
        }
      }.padding(20)
    }.foregroundStyle(.condesaText).background(Color.condesaBackground).navigationTitle("Menu")
  }
}

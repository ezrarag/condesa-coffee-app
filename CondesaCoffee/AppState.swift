import Foundation
import SwiftUI

@MainActor final class AppState: ObservableObject {
  @Published var mode: AppMode = .customer
  @Published var cart: [CartItem] = []
  @Published var roomOrTable = ""
  @Published var menuItems = SampleData.menu
  @Published var orders = SampleData.orders
  @Published var didPlaceOrder = false
  let repository: CoffeeRepository = FirestoreCoffeeRepository()
  var subtotal: Double { cart.reduce(0) { $0 + $1.lineTotal } }
  var tax: Double { subtotal * 0.08 }
  var total: Double { subtotal + tax }

  func add(_ item: MenuItem, milk: MilkType, shots: Int, notes: String, quantity: Int) {
    cart.append(
      CartItem(
        id: UUID(), itemId: item.id, name: item.name, price: item.price, quantity: quantity,
        milk: milk, shots: shots, notes: notes))
  }
  func handle(url: URL) {
    guard url.scheme == "condesa", url.host == "order",
      let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
    else { return }
    if let value = components.queryItems?.first(where: { $0.name == "table" || $0.name == "room" })?
      .value
    {
      roomOrTable = value
    }
  }
  func startListening() {
    repository.listenForOrders { [weak self] values in Task { @MainActor in self?.orders = values }
    }
  }
  func advance(_ order: CoffeeOrder) {
    if let index = orders.firstIndex(where: { $0.id == order.id }) {
      orders[index].status = order.status.next
    }
    repository.updateOrderStatus(id: order.id, status: order.status.next)
  }
  func toggle(_ item: MenuItem) {
    if let index = menuItems.firstIndex(where: { $0.id == item.id }) {
      menuItems[index].available.toggle()
      repository.setMenuAvailability(id: item.id, available: menuItems[index].available)
    }
  }
}

enum SampleData {
  static let menu = [
    MenuItem(
      id: "m1", name: "Cortado", description: "Equal parts espresso, steamed milk", price: 4.50,
      category: .espresso, available: true, customizations: []),
    MenuItem(
      id: "m2", name: "Cubano", description: "Espresso, raw sugar, cinnamon", price: 5,
      category: .espresso, available: true, customizations: []),
    MenuItem(
      id: "m3", name: "Ethiopia Pour Over", description: "Rotating single-origin, brewed to order",
      price: 5.50, category: .pourOver, available: true, customizations: []),
    MenuItem(
      id: "m4", name: "House Cold Brew", description: "Steeped 18 hours, served over ice",
      price: 4.75, category: .coldBrew, available: false, customizations: []),
    MenuItem(
      id: "m5", name: "Breakfast Torta", description: "Egg, chorizo, oaxaca on telera roll",
      price: 7.50, category: .food, available: true, customizations: []),
    MenuItem(
      id: "m6", name: "Horchata Cold Brew", description: "Cold brew, house horchata, cinnamon",
      price: 6.25, category: .seasonal, available: true, customizations: []),
  ]
  static let orders: [CoffeeOrder] = [
    CoffeeOrder(
      id: "o1",
      items: [
        CartItem(
          id: UUID(), itemId: "m1", name: "Cortado", price: 4.5, quantity: 1, milk: .oat, shots: 2,
          notes: "")
      ], total: 4.86, roomOrTable: "Table 12", paymentMethod: "Apple Pay", status: .pending,
      createdAt: .now.addingTimeInterval(-120), updatedAt: .now),
    CoffeeOrder(
      id: "o2",
      items: [
        CartItem(
          id: UUID(), itemId: "m4", name: "House Cold Brew", price: 4.75, quantity: 2, milk: .none,
          shots: 1, notes: "")
      ], total: 10.26, roomOrTable: "Table 4", paymentMethod: "Apple Pay", status: .brewing,
      createdAt: .now.addingTimeInterval(-240), updatedAt: .now),
  ]
}

import Foundation

enum AppMode: String, CaseIterable, Identifiable {
  case customer = "Customer"
  case staff = "Staff"
  var id: Self { self }
}
enum MenuCategory: String, CaseIterable, Codable, Identifiable {
  case espresso = "Espresso"
  case pourOver = "Pour Over"
  case coldBrew = "Cold Brew"
  case food = "Food"
  case seasonal = "Seasonal"
  var id: Self { self }
}
enum MilkType: String, CaseIterable, Codable, Identifiable {
  case whole = "Whole"
  case oat = "Oat"
  case almond = "Almond"
  case none = "None"
  var id: Self { self }
}
enum OrderStatus: String, CaseIterable, Codable {
  case pending = "Pending"
  case brewing = "Brewing"
  case ready = "Ready"
  case pickedUp = "Picked Up"
  var next: Self {
    let all = Self.allCases
    return all[(all.firstIndex(of: self)! + 1) % all.count]
  }
}

struct MenuItemCustomization: Codable, Hashable {
  let type: String
  let options: [String]
}
struct MenuItem: Identifiable, Codable, Hashable {
  let id: String
  var name: String
  var description: String
  var price: Double
  var category: MenuCategory
  var imageUrl: String? = nil
  var available: Bool
  var customizations: [MenuItemCustomization]
}
struct CartItem: Identifiable, Codable, Hashable {
  let id: UUID
  let itemId: String
  let name: String
  let price: Double
  var quantity: Int
  let milk: MilkType
  let shots: Int
  let notes: String
  var lineTotal: Double { price * Double(quantity) }
  var customizationSummary: String {
    [
      milk == .none ? "No milk" : "\(milk.rawValue) milk", "\(shots) shot\(shots == 1 ? "" : "s")",
      notes.isEmpty ? nil : notes,
    ].compactMap { $0 }.joined(separator: " · ")
  }
}
struct CoffeeOrder: Identifiable, Codable, Hashable {
  let id: String
  var items: [CartItem]
  var total: Double
  var roomOrTable: String
  var paymentMethod: String
  var status: OrderStatus
  var createdAt: Date
  var updatedAt: Date
}

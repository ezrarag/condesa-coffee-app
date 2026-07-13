import Foundation

#if canImport(FirebaseFirestore)
  import FirebaseFirestore
#endif

protocol CoffeeRepository {
  func listenForOrders(_ completion: @escaping ([CoffeeOrder]) -> Void)
  func updateOrderStatus(id: String, status: OrderStatus)
  func setMenuAvailability(id: String, available: Bool)
  func submit(order: CoffeeOrder, completion: @escaping (Error?) -> Void)
}

final class FirestoreCoffeeRepository: CoffeeRepository {
  #if canImport(FirebaseFirestore)
    private var listener: ListenerRegistration?
    private var isConfigured: Bool {
      Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
    }
  #endif
  func listenForOrders(_ completion: @escaping ([CoffeeOrder]) -> Void) {
    #if canImport(FirebaseFirestore)
      guard isConfigured else { return }
      listener = Firestore.firestore().collection("orders").order(by: "createdAt")
        .addSnapshotListener { snapshot, _ in
          let orders = snapshot?.documents.compactMap(Self.decodeOrder) ?? []
          completion(orders)
        }
    #endif
  }
  func updateOrderStatus(id: String, status: OrderStatus) {
    #if canImport(FirebaseFirestore)
      guard isConfigured else { return }
      Firestore.firestore().collection("orders").document(id).updateData([
        "status": status.rawValue, "updatedAt": FieldValue.serverTimestamp(),
      ])
    #endif
  }
  func setMenuAvailability(id: String, available: Bool) {
    #if canImport(FirebaseFirestore)
      guard isConfigured else { return }
      Firestore.firestore().collection("menuItems").document(id).updateData(["available": available]
      )
    #endif
  }
  func submit(order: CoffeeOrder, completion: @escaping (Error?) -> Void) {
    #if canImport(FirebaseFirestore)
      guard isConfigured else {
        completion(nil)
        return
      }
      let items = order.items.map {
        [
          "itemId": $0.itemId, "name": $0.name, "price": $0.price, "quantity": $0.quantity,
          "customizations": ["milk": $0.milk.rawValue, "shots": $0.shots, "notes": $0.notes],
        ] as [String: Any]
      }
      Firestore.firestore().collection("orders").addDocument(data: [
        "items": items, "total": order.total, "roomOrTable": order.roomOrTable,
        "paymentMethod": order.paymentMethod, "status": order.status.rawValue,
        "createdAt": FieldValue.serverTimestamp(), "updatedAt": FieldValue.serverTimestamp(),
      ]) { completion($0) }
    #else
      completion(nil)
    #endif
  }
  #if canImport(FirebaseFirestore)
    private static func decodeOrder(_ document: QueryDocumentSnapshot) -> CoffeeOrder? {
      let d = document.data()
      let rawItems = d["items"] as? [[String: Any]] ?? []
      let items = rawItems.map {
        CartItem(
          id: UUID(), itemId: $0["itemId"] as? String ?? "", name: $0["name"] as? String ?? "Item",
          price: $0["price"] as? Double ?? 0, quantity: $0["quantity"] as? Int ?? 1, milk: .none,
          shots: 1, notes: "")
      }
      return CoffeeOrder(
        id: document.documentID, items: items, total: d["total"] as? Double ?? 0,
        roomOrTable: d["roomOrTable"] as? String ?? "To Go",
        paymentMethod: d["paymentMethod"] as? String ?? "",
        status: OrderStatus(rawValue: d["status"] as? String ?? "") ?? .pending,
        createdAt: (d["createdAt"] as? Timestamp)?.dateValue() ?? .now,
        updatedAt: (d["updatedAt"] as? Timestamp)?.dateValue() ?? .now)
    }
  #endif
}

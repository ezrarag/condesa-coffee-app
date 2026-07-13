import PassKit
import SwiftUI

struct CheckoutView: View {
  @EnvironmentObject private var state: AppState
  @State private var showingApplePay = false
  @State private var showManualCard = false
  @State private var errorMessage: String?
  private var applePayAvailable: Bool { PKPaymentAuthorizationController.canMakePayments() }
  var body: some View {
    VStack(spacing: 22) {
      VStack(spacing: 12) {
        HStack {
          Text("Table")
          Spacer()
          Text(state.roomOrTable).fontWeight(.semibold)
        }
        HStack {
          Text("\(state.cart.count) items")
          Spacer()
        }
        Divider()
        HStack {
          Text("Total").font(.title3.bold())
          Spacer()
          Text(state.total, format: .currency(code: "USD")).font(.title3.bold())
        }
      }.padding(18).background(Color.condesaSurface, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.condesaText.opacity(0.1)))
      if applePayAvailable {
        Button {
          showingApplePay = true
        } label: {
          ApplePayButtonView().frame(height: 50)
        }.buttonStyle(.plain)
      } else {
        Text("Apple Pay isn’t available on this device.").foregroundStyle(
          .condesaText.opacity(0.55))
      }
      Button("Enter card details manually") { showManualCard = true }.foregroundStyle(
        .condesaAccent
      ).underline()
      if let errorMessage { Text(errorMessage).font(.caption).foregroundStyle(.red) }
      Spacer()
      Text("Payments processed securely. Your order starts as soon as payment is confirmed.").font(
        .caption
      ).multilineTextAlignment(.center).foregroundStyle(.condesaText.opacity(0.35))
    }.padding(20).foregroundStyle(.condesaText).background(Color.condesaBackground).navigationTitle(
      "Checkout"
    )
    .sheet(isPresented: $showingApplePay) {
      ApplePayController(total: state.total) { success in
        if success { submit(paymentMethod: "Apple Pay") }
      }
    }
    .sheet(isPresented: $showManualCard) {
      ManualCardPlaceholder {
        submit(paymentMethod: "Manual Card")
        showManualCard = false
      }
    }
    .alert("Order received", isPresented: $state.didPlaceOrder) {
      Button("Done") { state.cart = [] }
    } message: {
      Text("We’ll start brewing right away.")
    }
  }
  private func submit(paymentMethod: String) {
    let order = CoffeeOrder(
      id: UUID().uuidString, items: state.cart, total: state.total, roomOrTable: state.roomOrTable,
      paymentMethod: paymentMethod, status: .pending, createdAt: .now, updatedAt: .now)
    state.repository.submit(order: order) { error in
      Task { @MainActor in
        if let error {
          errorMessage = error.localizedDescription
        } else {
          state.didPlaceOrder = true
        }
      }
    }
  }
}

private struct ApplePayButtonView: UIViewRepresentable {
  func makeUIView(context: Context) -> PKPaymentButton {
    PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .whiteOutline)
  }
  func updateUIView(_ uiView: PKPaymentButton, context: Context) {}
}
private struct ApplePayController: UIViewControllerRepresentable {
  let total: Double
  let completion: (Bool) -> Void
  func makeCoordinator() -> Coordinator { Coordinator(completion: completion) }
  func makeUIViewController(context: Context) -> PKPaymentAuthorizationViewController {
    let request = PKPaymentRequest()
    request.merchantIdentifier = "merchant.com.ragnexus.condesacoffee"
    request.supportedNetworks = [.amex, .masterCard, .visa]
    request.merchantCapabilities = .threeDSecure
    request.countryCode = "US"
    request.currencyCode = "USD"
    request.paymentSummaryItems = [
      PKPaymentSummaryItem(label: "Condesa Coffee", amount: NSDecimalNumber(value: total))
    ]
    let vc = PKPaymentAuthorizationViewController(paymentRequest: request)!
    vc.delegate = context.coordinator
    return vc
  }
  func updateUIViewController(
    _ uiViewController: PKPaymentAuthorizationViewController, context: Context
  ) {}
  final class Coordinator: NSObject, PKPaymentAuthorizationViewControllerDelegate {
    let completion: (Bool) -> Void
    var succeeded = false
    init(completion: @escaping (Bool) -> Void) { self.completion = completion }
    func paymentAuthorizationViewController(
      _ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment,
      handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
      succeeded = true
      completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
    }
    func paymentAuthorizationViewControllerDidFinish(
      _ controller: PKPaymentAuthorizationViewController
    ) { controller.dismiss { self.completion(self.succeeded) } }
  }
}
private struct ManualCardPlaceholder: View {
  @Environment(\.dismiss) var dismiss
  let onPay: () -> Void
  @State var number = "", expiry = "", cvv = ""
  var body: some View {
    NavigationStack {
      Form {
        Section("Card details") {
          TextField("Card number", text: $number).keyboardType(.numberPad)
          TextField("MM/YY", text: $expiry)
          SecureField("CVV", text: $cvv)
        }
        Text("Placeholder only — connect a PCI-compliant payment provider before launch.").font(
          .caption
        ).foregroundStyle(.secondary)
      }.navigationTitle("Card Payment").toolbar {
        ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
        ToolbarItem(placement: .confirmationAction) {
          Button("Pay", action: onPay).disabled(number.isEmpty)
        }
      }
    }
  }
}

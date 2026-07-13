import SwiftUI

struct RootView: View {
  @EnvironmentObject private var state: AppState
  var body: some View {
    ZStack {
      Color.condesaBackground.ignoresSafeArea()
      if state.mode == .customer { CustomerFlow() } else { StaffFlow() }
    }
    .tint(.condesaAccent)
  }
}

private struct ModePicker: View {
  @EnvironmentObject private var state: AppState
  var body: some View {
    Picker("App mode", selection: $state.mode) {
      ForEach(AppMode.allCases) { Text($0.rawValue).tag($0) }
    }
    .pickerStyle(.segmented).padding()
  }
}

struct CustomerFlow: View {
  var body: some View {
    NavigationStack {
      MenuView().toolbar { ToolbarItem(placement: .topBarLeading) { ModeMenu() } }
    }.toolbarBackground(Color.condesaBackground, for: .navigationBar)
  }
}

struct StaffFlow: View {
  var body: some View {
    NavigationStack {
      OrderQueueView().toolbar {
        ToolbarItem(placement: .topBarLeading) { ModeMenu() }
        ToolbarItem(placement: .topBarTrailing) {
          NavigationLink(destination: MenuAdminView()) { Image(systemName: "slider.horizontal.3") }
        }
      }
    }.toolbarBackground(Color.condesaBackground, for: .navigationBar)
  }
}

private struct ModeMenu: View {
  @EnvironmentObject private var state: AppState
  var body: some View {
    Menu {
      Picker("Mode", selection: $state.mode) {
        ForEach(AppMode.allCases) { Text($0.rawValue).tag($0) }
      }
    } label: {
      Image(
        systemName: state.mode == .customer
          ? "cup.and.saucer.fill" : "person.2.badge.gearshape.fill"
      ).foregroundStyle(.condesaAccent)
    }
  }
}

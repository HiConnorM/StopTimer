import SwiftUI

/// Local cosmetic store. Shows the coin balance and a section per cosmetic type;
/// players buy with coins and equip owned items. Purchases persist locally.
struct StoreView: View {
    @EnvironmentObject private var progress: ProgressStore

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: progress.backgroundColors, startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        balance
                        ForEach(CosmeticType.allCases) { type in
                            section(type)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Store")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var balance: some View {
        HStack(spacing: 8) {
            Image(systemName: "dollarsign.circle.fill").foregroundStyle(Constants.Theme.coin)
            Text("\(progress.progress.coins)")
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundStyle(Constants.Theme.textPrimary)
            Text("coins").font(.system(.subheadline, design: .rounded).weight(.semibold))
                .foregroundStyle(Constants.Theme.textSecondary)
            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Constants.Theme.card, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 10, y: 5)
    }

    private func section(_ type: CosmeticType) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(type.displayName, systemImage: type.symbol)
                .font(.system(.headline, design: .rounded).weight(.heavy))
                .foregroundStyle(Constants.Theme.textPrimary)

            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(CosmeticCatalog.items(of: type)) { item in
                    CosmeticCardView(
                        item: item,
                        owned: progress.isOwned(item.id),
                        equipped: progress.isEquipped(item.id),
                        available: progress.isAvailable(item),
                        canAfford: progress.canAfford(item),
                        onBuy: { _ = progress.purchase(item) },
                        onEquip: { progress.equip(item) }
                    )
                }
            }
        }
    }
}

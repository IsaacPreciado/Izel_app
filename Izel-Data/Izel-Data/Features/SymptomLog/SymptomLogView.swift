import SwiftUI
import SwiftData

struct SymptomLogView: View {
    @Environment(\.modelContext) private var context
    @State private var viewModel = SymptomLogViewModel()
    @State private var showSaved = false

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                header
                ForEach(SymptomCategory.allCases) { category in
                    section(for: category)
                }

                CardContainer {
                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text("INTENSIDAD GLOBAL")
                            .font(Theme.Typography.label(11, weight: .bold))
                            .tracking(1.5)
                            .foregroundStyle(Theme.Colors.secondary)
                        HStack(spacing: Theme.Spacing.md) {
                            Slider(value: Binding(
                                get: { Double(viewModel.intensity) },
                                set: { viewModel.intensity = Int($0) }
                            ), in: 0...5, step: 1)
                            .tint(Theme.Colors.primaryContainer)
                            Text("\(viewModel.intensity)")
                                .font(Theme.Typography.headline(22, weight: .bold))
                                .foregroundStyle(Theme.Colors.primary)
                                .frame(width: 24, alignment: .trailing)
                        }
                    }
                }

                CardContainer {
                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        Text("NOTAS")
                            .font(Theme.Typography.label(11, weight: .bold))
                            .tracking(1.5)
                            .foregroundStyle(Theme.Colors.secondary)
                        TextField("Observaciones opcionales...", text: $viewModel.note, axis: .vertical)
                            .font(Theme.Typography.body(15))
                            .lineLimit(3...6)
                    }
                }

                PrimaryButton(title: "Guardar Registro", icon: "square.and.arrow.down") {
                    viewModel.save(using: context)
                    showSaved = true
                }
                .alert("Registro guardado", isPresented: $showSaved) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text("Tus síntomas de hoy han sido guardados correctamente.")
                }
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.xl)
        }
        .background(Theme.Colors.background.ignoresSafeArea())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text("REGISTRO DIARIO")
                .font(Theme.Typography.label(11, weight: .bold))
                .tracking(1.5)
                .foregroundStyle(Theme.Colors.secondary)
            Text("¿Cómo te sientes hoy?")
                .font(Theme.Typography.headline(28, weight: .heavy))
        }
    }

    private func section(for category: SymptomCategory) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                Text(category.displayName)
                    .font(Theme.Typography.headline(17, weight: .bold))
                Spacer()
                Text("Selección múltiple")
                    .font(Theme.Typography.label(11, weight: .semibold))
                    .foregroundStyle(Theme.Colors.secondary)
                    .padding(.horizontal, Theme.Spacing.sm + 4)
                    .padding(.vertical, Theme.Spacing.xs)
                    .background(Theme.Colors.secondaryContainer.opacity(0.3))
                    .clipShape(Capsule())
            }

            LazyVGrid(columns: columns, spacing: Theme.Spacing.md) {
                ForEach(Symptom.catalog.filter { $0.category == category }) { symptom in
                    SymptomGridCard(
                        symptom: symptom,
                        isSelected: viewModel.isSelected(symptom)
                    ) {
                        viewModel.toggle(symptom)
                    }
                }
            }
        }
    }
}

#Preview {
    SymptomLogView()
        .modelContainer(PersistenceService.makeContainer(inMemory: true))
}

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var context
    @State private var viewModel = OnboardingViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.xl) {
                header
                biometricSection
                healthHistorySection
                footer
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.xl)
        }
        .background(Theme.Colors.background.ignoresSafeArea())
    }

    private var header: some View {
        VStack(spacing: Theme.Spacing.md) {
            Circle()
                .fill(Theme.Colors.primaryContainer)
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "bubbles.and.sparkles.fill")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.white)
                )

            Text("Izel-Data")
                .font(Theme.Typography.headline(34, weight: .heavy))
                .foregroundStyle(Theme.Colors.onSurface)

            Text("Bienvenida a tu santuario de datos clínicos y salud hormonal.")
                .font(Theme.Typography.body(17, weight: .medium))
                .foregroundStyle(Theme.Colors.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.md)
        }
    }

    private var biometricSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            SectionHeader(number: "01", title: "Datos Biométricos")

            CardContainer {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("FECHA DE NACIMIENTO")
                        .font(Theme.Typography.label(11, weight: .bold))
                        .tracking(1.5)
                        .foregroundStyle(Theme.Colors.secondary)
                    DatePicker(
                        "",
                        selection: $viewModel.birthDate,
                        in: ...Date.now,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    .environment(\.locale, Locale(identifier: "es_ES"))
                    .font(Theme.Typography.headline(18, weight: .semibold))
                }
            }

            HStack(spacing: Theme.Spacing.md) {
                LabeledField(
                    label: "Peso (kg)",
                    placeholder: "00.0",
                    text: $viewModel.weightText,
                    keyboard: .decimalPad
                )
                LabeledField(
                    label: "Estatura (cm)",
                    placeholder: "165",
                    text: $viewModel.heightText,
                    keyboard: .numberPad
                )
            }
        }
    }

    private var healthHistorySection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            SectionHeader(number: "02", title: "Historial de Salud")

            CardContainer {
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    Text("REGULARIDAD DEL CICLO")
                        .font(Theme.Typography.label(11, weight: .bold))
                        .tracking(1.5)
                        .foregroundStyle(Theme.Colors.secondary)
                    HStack(spacing: Theme.Spacing.sm) {
                        ForEach(CycleRegularity.allCases) { option in
                            ChipButton(
                                title: option.displayName,
                                isSelected: viewModel.cycleRegularity == option
                            ) {
                                viewModel.cycleRegularity = option
                            }
                        }
                    }
                }
            }

            CardContainer {
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    Text("DURACIÓN DEL CICLO (DÍAS)")
                        .font(Theme.Typography.label(11, weight: .bold))
                        .tracking(1.5)
                        .foregroundStyle(Theme.Colors.secondary)
                    HStack(spacing: Theme.Spacing.md) {
                        Slider(
                            value: Binding(
                                get: { Double(viewModel.cycleDurationDays) },
                                set: { viewModel.cycleDurationDays = Int($0) }
                            ),
                            in: 21...45,
                            step: 1
                        )
                        .tint(Theme.Colors.primaryContainer)
                        Text("\(viewModel.cycleDurationDays)")
                            .font(Theme.Typography.headline(22, weight: .bold))
                            .foregroundStyle(Theme.Colors.primary)
                            .frame(width: 36, alignment: .trailing)
                    }
                }
            }

            HStack(spacing: Theme.Spacing.md) {
                StepperField(label: "Embarazos", value: $viewModel.pregnancies)
                StepperField(label: "Abortos", value: $viewModel.abortions)
            }
        }
    }

    private var footer: some View {
        VStack(spacing: Theme.Spacing.md) {
            PrimaryButton(
                title: "Finalizar Registro",
                icon: "arrow.right",
                isEnabled: viewModel.isValid
            ) {
                viewModel.save(using: context)
            }

            Text("Al continuar, aceptas que tus datos sean procesados bajo protocolos de grado clínico para tu análisis personalizado.")
                .font(Theme.Typography.label(11))
                .foregroundStyle(Theme.Colors.secondary.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.md)
        }
        .padding(.top, Theme.Spacing.lg)
    }
}

#Preview {
    OnboardingView()
        .modelContainer(PersistenceService.makeContainer(inMemory: true))
}

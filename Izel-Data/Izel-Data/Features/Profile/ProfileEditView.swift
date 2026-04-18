import SwiftUI
import SwiftData

struct ProfileEditView: View {
    @Query private var profiles: [UserProfile]
    @Environment(\.modelContext) private var context

    // Formulario biométrico
    @State private var birthDate: Date = Calendar.current.date(byAdding: .year, value: -25, to: .now) ?? .now
    @State private var weightText: String = ""
    @State private var heightText: String = ""
    @State private var cycleRegularity: CycleRegularity = .regular
    @State private var cycleDurationDays: Int = 28
    @State private var pregnancies: Int = 0
    @State private var abortions: Int = 0
    @State private var showSaved: Bool = false

    // Configuración del servidor
    @AppStorage("server_host") private var serverHost: String = "localhost"
    @AppStorage("server_port") private var serverPort: String = "8000"

    enum PingState { case idle, checking, online, offline }
    @State private var pingState: PingState = .idle
    private let service = PredictionService()

    private var profile: UserProfile? { profiles.first }

    private var isValid: Bool {
        guard let w = Double(weightText.replacingOccurrences(of: ",", with: ".")),
              let h = Double(heightText.replacingOccurrences(of: ",", with: ".")) else { return false }
        return w > 0 && h > 0
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.xl) {
                pageHeader
                biometricSection
                healthHistorySection
                serverSection
                saveButton
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.xl)
        }
        .background(Theme.Colors.background.ignoresSafeArea())
        .onAppear(perform: loadFromProfile)
        .alert("Datos actualizados", isPresented: $showSaved) {
            Button("Listo", role: .cancel) {}
        } message: {
            Text("Tu perfil clínico ha sido guardado correctamente.")
        }
    }

    // MARK: - Subviews

    private var pageHeader: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text("Mi Perfil")
                .font(Theme.Typography.headline(28, weight: .heavy))
            Text("Actualiza tus datos biométricos y de salud")
                .font(Theme.Typography.body(14))
                .foregroundStyle(Theme.Colors.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
                        selection: $birthDate,
                        in: ...Date.now,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    .environment(\.locale, Locale(identifier: "es_ES"))
                    .font(Theme.Typography.headline(18, weight: .semibold))
                }
            }

            HStack(spacing: Theme.Spacing.md) {
                LabeledField(label: "Peso (kg)", placeholder: "00.0",
                             text: $weightText, keyboard: .decimalPad)
                LabeledField(label: "Estatura (cm)", placeholder: "165",
                             text: $heightText, keyboard: .numberPad)
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
                                isSelected: cycleRegularity == option
                            ) { cycleRegularity = option }
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
                                get: { Double(cycleDurationDays) },
                                set: { cycleDurationDays = Int($0) }
                            ),
                            in: 21...45, step: 1
                        )
                        .tint(Theme.Colors.primaryContainer)
                        Text("\(cycleDurationDays)")
                            .font(Theme.Typography.headline(22, weight: .bold))
                            .foregroundStyle(Theme.Colors.primary)
                            .frame(width: 36, alignment: .trailing)
                    }
                }
            }

            HStack(spacing: Theme.Spacing.md) {
                StepperField(label: "Embarazos", value: $pregnancies)
                StepperField(label: "Abortos", value: $abortions)
            }
        }
    }

    private var serverSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            SectionHeader(number: "03", title: "Servidor ML")

            CardContainer {
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    // Campos de IP y puerto
                    HStack(spacing: Theme.Spacing.md) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("DIRECCIÓN IP")
                                .font(Theme.Typography.label(11, weight: .bold))
                                .tracking(1.5)
                                .foregroundStyle(Theme.Colors.secondary)
                            TextField("192.168.1.x", text: $serverHost)
                                .keyboardType(.URL)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                                .font(Theme.Typography.body(16))
                                .padding(.vertical, Theme.Spacing.sm)
                                .padding(.horizontal, Theme.Spacing.md)
                                .background(Theme.Colors.surfaceContainerLow)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm))
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("PUERTO")
                                .font(Theme.Typography.label(11, weight: .bold))
                                .tracking(1.5)
                                .foregroundStyle(Theme.Colors.secondary)
                            TextField("8000", text: $serverPort)
                                .keyboardType(.numberPad)
                                .font(Theme.Typography.body(16))
                                .padding(.vertical, Theme.Spacing.sm)
                                .padding(.horizontal, Theme.Spacing.md)
                                .background(Theme.Colors.surfaceContainerLow)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm))
                        }
                        .frame(width: 80)
                    }

                    // URL actual + botón probar
                    HStack(spacing: Theme.Spacing.sm) {
                        Text("http://\(serverHost):\(serverPort)")
                            .font(Theme.Typography.label(12))
                            .foregroundStyle(Theme.Colors.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)

                        Spacer()

                        Button {
                            testConnection()
                        } label: {
                            HStack(spacing: 6) {
                                if pingState == .checking {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                        .scaleEffect(0.7)
                                }
                                Text(pingState == .checking ? "Probando…" : "Probar")
                                    .font(Theme.Typography.label(13, weight: .semibold))
                            }
                            .foregroundStyle(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, Theme.Spacing.md)
                            .background(Theme.Colors.primary)
                            .clipShape(Capsule())
                        }
                        .disabled(pingState == .checking)
                    }

                    // Resultado del ping
                    if pingState == .online || pingState == .offline {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(pingState == .online ? Color.green : Theme.Colors.error)
                                .frame(width: 8, height: 8)
                            Text(pingState == .online
                                 ? "Servidor en línea"
                                 : "No se pudo conectar al servidor")
                                .font(Theme.Typography.label(13))
                                .foregroundStyle(pingState == .online
                                                 ? Color.green
                                                 : Theme.Colors.error)
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        .animation(.easeInOut(duration: 0.25), value: pingState == .online)
                    }
                }
            }

            Text("Dispositivo físico: usa la IP LAN de tu Mac (ej. 192.168.1.x). Simulador: usa localhost.\nAsegúrate de que el servidor esté corriendo con: uvicorn main:app --host 0.0.0.0 --port 8000")
                .font(Theme.Typography.label(11))
                .foregroundStyle(Theme.Colors.secondary.opacity(0.7))
                .padding(.horizontal, Theme.Spacing.xs)
        }
    }

    private var saveButton: some View {
        PrimaryButton(
            title: "Guardar cambios",
            icon: "checkmark",
            isEnabled: isValid
        ) {
            saveChanges()
        }
        .padding(.top, Theme.Spacing.lg)
    }

    // MARK: - Lógica

    private func loadFromProfile() {
        guard let p = profile else { return }
        birthDate         = p.birthDate
        weightText        = String(format: "%.1f", p.weightKg)
        heightText        = String(format: "%.0f", p.heightCm)
        cycleRegularity   = p.cycleRegularity
        cycleDurationDays = p.cycleDurationDays
        pregnancies       = p.pregnancies
        abortions         = p.abortions
    }

    private func saveChanges() {
        guard let p = profile,
              let weight = Double(weightText.replacingOccurrences(of: ",", with: ".")),
              let height = Double(heightText.replacingOccurrences(of: ",", with: ".")) else { return }

        p.birthDate         = birthDate
        p.weightKg          = weight
        p.heightCm          = height
        p.cycleRegularity   = cycleRegularity
        p.cycleDurationDays = cycleDurationDays
        p.pregnancies       = pregnancies
        p.abortions         = abortions

        try? context.save()
        showSaved = true
    }

    private func testConnection() {
        pingState = .checking
        Task {
            let ok = await service.ping()
            await MainActor.run {
                withAnimation { pingState = ok ? .online : .offline }
            }
        }
    }
}

#Preview {
    ProfileEditView()
        .modelContainer(PersistenceService.makeContainer(inMemory: true))
}

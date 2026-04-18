import Foundation

// MARK: - Configuración persistida (UserDefaults)

enum ServerConfig {
    static let hostKey = "server_host"
    static let portKey = "server_port"

    static var host: String {
        UserDefaults.standard.string(forKey: hostKey) ?? "localhost"
    }
    static var port: String {
        UserDefaults.standard.string(forKey: portKey) ?? "8000"
    }

    /// URL leída en tiempo de ejecución para que los cambios del usuario surtan efecto de inmediato.
    static var baseURL: URL {
        URL(string: "http://\(host):\(port)") ?? URL(string: "http://localhost:8000")!
    }

    static func save(host: String, port: String) {
        UserDefaults.standard.set(host, forKey: hostKey)
        UserDefaults.standard.set(port, forKey: portKey)
    }
}

// MARK: - Errors

enum PredictionError: LocalizedError {
    case invalidResponse
    case serverError(Int, String)
    case decodingFailed
    case missingProfile
    case transport(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:       return "Respuesta inválida del servidor."
        case .serverError(let c, _): return "Error del servidor (\(c))."
        case .decodingFailed:        return "No se pudo interpretar la respuesta."
        case .missingProfile:        return "Falta perfil de usuaria."
        case .transport(let e):      return e.localizedDescription
        }
    }
}

// MARK: - DTOs

struct PredictionResponseDTO: Decodable {
    let label: Int
    let probability: Double
    let riskLevel: String
    let condition: String

    enum CodingKeys: String, CodingKey {
        case label, probability, condition
        case riskLevel = "risk_level"
    }

    var asRiskLevel: RiskLevel {
        switch riskLevel {
        case "high":     return .high
        case "moderate": return .moderate
        default:         return .low
        }
    }
}

struct EndometriosisRequestDTO: Encodable {
    let age: Double
    let menstrualIrregularity: Int
    let chronicPainLevel: Int
    let hormoneLevelAbnormality: Int
    let infertility: Int
    let bmi: Double

    enum CodingKeys: String, CodingKey {
        case age, infertility, bmi
        case menstrualIrregularity   = "menstrual_irregularity"
        case chronicPainLevel        = "chronic_pain_level"
        case hormoneLevelAbnormality = "hormone_level_abnormality"
    }
}

struct SopRequestDTO: Encodable {
    let age: Double
    let weightKg: Double
    let heightCm: Double
    let bmi: Double
    let cycleIrregular: Int
    let cycleLengthDays: Int
    let pregnant: Int
    let abortions: Int
    let weightGain: Int
    let hairGrowth: Int
    let skinDarkening: Int
    let hairLoss: Int
    let pimples: Int

    enum CodingKeys: String, CodingKey {
        case age, bmi, pregnant, abortions, pimples
        case weightKg        = "weight_kg"
        case heightCm        = "height_cm"
        case cycleIrregular  = "cycle_irregular"
        case cycleLengthDays = "cycle_length_days"
        case weightGain      = "weight_gain"
        case hairGrowth      = "hair_growth"
        case skinDarkening   = "skin_darkening"
        case hairLoss        = "hair_loss"
    }
}

// MARK: - Service

@Observable
final class PredictionService {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    // MARK: Health check

    func ping() async -> Bool {
        var request = URLRequest(url: ServerConfig.baseURL.appendingPathComponent("health"))
        request.timeoutInterval = 5
        do {
            let (_, response) = try await session.data(for: request)
            return (response as? HTTPURLResponse)?.statusCode == 200
        } catch {
            return false
        }
    }

    // MARK: Predictions

    func predictEndometriosis(profile: UserProfile,
                              entries: [SymptomEntry]) async throws -> PredictionResponseDTO {
        let payload = Self.makeEndoPayload(profile: profile, entries: entries)
        return try await post(path: "/predict/endometriosis", body: payload)
    }

    func predictSOP(profile: UserProfile,
                    entries: [SymptomEntry]) async throws -> PredictionResponseDTO {
        let payload = Self.makeSopPayload(profile: profile, entries: entries)
        return try await post(path: "/predict/sop", body: payload)
    }

    // MARK: Network

    private func post<Body: Encodable>(path: String, body: Body) async throws -> PredictionResponseDTO {
        var request = URLRequest(url: ServerConfig.baseURL.appendingPathComponent(path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        request.timeoutInterval = 15

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw PredictionError.transport(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw PredictionError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw PredictionError.serverError(http.statusCode, body)
        }
        guard let decoded = try? JSONDecoder().decode(PredictionResponseDTO.self, from: data) else {
            throw PredictionError.decodingFailed
        }
        return decoded
    }

    // MARK: Feature engineering

    private static let ninetyDays: TimeInterval = 60 * 60 * 24 * 90

    private static func recent(_ entries: [SymptomEntry]) -> [SymptomEntry] {
        let cutoff = Date().addingTimeInterval(-ninetyDays)
        return entries.filter { $0.date >= cutoff }
    }

    private static func ageYears(from birth: Date) -> Double {
        let comps = Calendar.current.dateComponents([.year], from: birth, to: .now)
        return Double(comps.year ?? 28)
    }

    private static func hasSymptom(_ id: String, in entries: [SymptomEntry], min: Int = 1) -> Bool {
        entries.filter { $0.symptomIDs.contains(id) }.count >= min
    }

    private static func painLevel(from entries: [SymptomEntry]) -> Int {
        let painful = entries.filter {
            $0.symptomIDs.contains("dolor_pelvico") || $0.symptomIDs.contains("hinchazon")
        }
        guard !painful.isEmpty else { return 0 }
        let avg = Double(painful.map(\.intensity).reduce(0, +)) / Double(painful.count)
        return Int(min(3, (avg / 5.0) * 3.0).rounded())
    }

    static func makeEndoPayload(profile: UserProfile,
                                entries: [SymptomEntry]) -> EndometriosisRequestDTO {
        let recent = recent(entries)
        return EndometriosisRequestDTO(
            age: ageYears(from: profile.birthDate),
            menstrualIrregularity: profile.cycleRegularity == .regular ? 0 : 1,
            chronicPainLevel: painLevel(from: recent),
            hormoneLevelAbnormality: hasSymptom("acne", in: recent, min: 3) ? 1 : 0,
            infertility: 0,
            bmi: profile.bmi > 0 ? profile.bmi : 24
        )
    }

    static func makeSopPayload(profile: UserProfile,
                               entries: [SymptomEntry]) -> SopRequestDTO {
        let recent = recent(entries)
        return SopRequestDTO(
            age: ageYears(from: profile.birthDate),
            weightKg: profile.weightKg > 0 ? profile.weightKg : 59,
            heightCm: profile.heightCm > 0 ? profile.heightCm : 160,
            bmi: profile.bmi > 0 ? profile.bmi : 24,
            cycleIrregular: profile.cycleRegularity == .regular ? 0 : 1,
            cycleLengthDays: profile.cycleDurationDays,
            pregnant: 0,
            abortions: profile.abortions,
            weightGain: hasSymptom("hinchazon", in: recent, min: 2) ? 1 : 0,
            hairGrowth: 0,
            skinDarkening: 0,
            hairLoss: hasSymptom("caida_cabello", in: recent) ? 1 : 0,
            pimples: hasSymptom("acne", in: recent) ? 1 : 0
        )
    }
}

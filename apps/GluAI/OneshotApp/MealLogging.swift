import Foundation
import SwiftUI
import Supabase
import UIKit

struct MealLineItem: Codable, Equatable, Identifiable {
    var id: UUID
    var name: String
    var portionGuess: String
    var calories: Int
    var carbsG: Double

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case portionGuess = "portion_guess"
        case calories
        case carbsG = "carbs_g"
    }

    init(id: UUID = UUID(), name: String, portionGuess: String, calories: Int, carbsG: Double) {
        self.id = id
        self.name = name
        self.portionGuess = portionGuess
        self.calories = calories
        self.carbsG = carbsG
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try c.decode(String.self, forKey: .name)
        portionGuess = try c.decodeIfPresent(String.self, forKey: .portionGuess) ?? ""
        calories = try c.decodeIfPresent(Int.self, forKey: .calories) ?? 0
        carbsG = try c.decodeIfPresent(Double.self, forKey: .carbsG) ?? 0
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encode(portionGuess, forKey: .portionGuess)
        try c.encode(calories, forKey: .calories)
        try c.encode(carbsG, forKey: .carbsG)
    }
}

struct MealTotals: Codable, Equatable {
    let calories: Int?
    let carbsG: Double?
    let fiberG: Double?
    let sugarG: Double?
    let proteinG: Double?
    let fatG: Double?

    init(
        calories: Int?,
        carbsG: Double?,
        fiberG: Double?,
        sugarG: Double?,
        proteinG: Double?,
        fatG: Double?
    ) {
        self.calories = calories
        self.carbsG = carbsG
        self.fiberG = fiberG
        self.sugarG = sugarG
        self.proteinG = proteinG
        self.fatG = fatG
    }

    enum CodingKeys: String, CodingKey {
        case calories
        case carbsG = "carbs_g"
        case fiberG = "fiber_g"
        case sugarG = "sugar_g"
        case proteinG = "protein_g"
        case fatG = "fat_g"
    }
}

struct MealAIOutput: Codable, Equatable {
    var items: [MealLineItem]
    var totals: MealTotals?
    var spikeRisk: String
    var rationale: String
    var disclaimer: String
    var confidence: Double

    enum CodingKeys: String, CodingKey {
        case items
        case totals
        case spikeRisk = "spike_risk"
        case rationale
        case disclaimer
        case confidence
    }

    init(
        items: [MealLineItem],
        totals: MealTotals?,
        spikeRisk: String,
        rationale: String,
        disclaimer: String,
        confidence: Double
    ) {
        self.items = items
        self.totals = totals
        self.spikeRisk = spikeRisk
        self.rationale = rationale
        self.disclaimer = disclaimer
        self.confidence = confidence
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        items = try c.decodeIfPresent([MealLineItem].self, forKey: .items) ?? []
        totals = try c.decodeIfPresent(MealTotals.self, forKey: .totals)
        spikeRisk = try c.decodeIfPresent(String.self, forKey: .spikeRisk) ?? "medium"
        rationale = try c.decodeIfPresent(String.self, forKey: .rationale) ?? ""
        disclaimer = try c.decodeIfPresent(String.self, forKey: .disclaimer)
            ?? "Educational estimate only. Not medical advice."
        confidence = try c.decodeIfPresent(Double.self, forKey: .confidence) ?? 0.5
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(items, forKey: .items)
        try c.encodeIfPresent(totals, forKey: .totals)
        try c.encode(spikeRisk, forKey: .spikeRisk)
        try c.encode(rationale, forKey: .rationale)
        try c.encode(disclaimer, forKey: .disclaimer)
        try c.encode(confidence, forKey: .confidence)
    }

    var calories: Int { totals?.calories ?? items.reduce(0) { $0 + $1.calories } }
    var carbsG: Double { totals?.carbsG ?? items.reduce(0) { $0 + $1.carbsG } }
    var fiberG: Double { totals?.fiberG ?? 0 }
    var sugarG: Double { totals?.sugarG ?? 0 }
    var proteinG: Double { totals?.proteinG ?? 0 }
    var fatG: Double { totals?.fatG ?? 0 }

    static func mock() -> MealAIOutput {
        MealAIOutput(
            items: [MealLineItem(name: "Mixed plate", portionGuess: "1 plate", calories: 520, carbsG: 58)],
            totals: MealTotals(calories: 520, carbsG: 58, fiberG: 6, sugarG: 12, proteinG: 22, fatG: 18),
            spikeRisk: "medium",
            rationale: "Portion looks moderate with visible starch and limited fiber in frame — educational guess only.",
            disclaimer: "Educational estimate only. Not medical advice.",
            confidence: 0.62
        )
    }
}

// MARK: - Spike lesson + versioned meal envelope (server + `meal_logs.envelope`)

struct GluSpikeLesson: Codable, Equatable {
    var risk_band: String
    var headline: String
    var coaching: String

    enum CodingKeys: String, CodingKey {
        case risk_band
        case headline
        case coaching
    }
}

struct GluMealEnvelope: Codable, Equatable {
    var envelope_version: Int
    var prompt_version: String
    var analysis_state: String
    var spike_lesson: GluSpikeLesson
    var user_estimate: MealAIOutput

    enum CodingKeys: String, CodingKey {
        case envelope_version
        case prompt_version
        case analysis_state
        case spike_lesson
        case user_estimate
    }

    /// After user edits line items / macros, only the estimate half may change; spike lesson stays immutable.
    func updatingUserEstimate(_ new: MealAIOutput) -> GluMealEnvelope {
        GluMealEnvelope(
            envelope_version: envelope_version,
            prompt_version: prompt_version,
            analysis_state: analysis_state,
            spike_lesson: spike_lesson,
            user_estimate: new
        )
    }

    /// Legacy rows: synthesize a minimal envelope from flat `MealAIOutput`.
    static func legacy(from output: MealAIOutput) -> GluMealEnvelope {
        let lesson = GluSpikeLesson(
            risk_band: output.spikeRisk,
            headline: String(output.rationale.prefix(90)),
            coaching: output.rationale
        )
        return GluMealEnvelope(
            envelope_version: 1,
            prompt_version: "legacy-import",
            analysis_state: "ready",
            spike_lesson: lesson,
            user_estimate: output
        )
    }
}

extension MealAIOutput {
    /// Rebuilds `totals` from line items; scales fiber/sugar/protein/fat when prior totals existed (ratio vs previous calorie total).
    mutating func recomputeTotalsFromLineItems() {
        let cal = items.reduce(0) { $0 + $1.calories }
        let carbs = items.reduce(0.0) { $0 + $1.carbsG }
        if let t = totals {
            let oldC = max(t.calories ?? cal, 1)
            let ratio = Double(cal) / Double(oldC)
            totals = MealTotals(
                calories: cal,
                carbsG: carbs,
                fiberG: (t.fiberG ?? 0) * ratio,
                sugarG: (t.sugarG ?? 0) * ratio,
                proteinG: (t.proteinG ?? 0) * ratio,
                fatG: (t.fatG ?? 0) * ratio
            )
        } else {
            totals = MealTotals(calories: cal, carbsG: carbs, fiberG: 0, sugarG: 0, proteinG: 0, fatG: 0)
        }
    }
}

private struct MealLogInsert: Encodable {
    let id: UUID
    let user_id: UUID
    let output: MealAIOutput
    let envelope: GluMealEnvelope?
}

private struct MealLogRow: Decodable {
    let id: UUID
    let created_at: Date
    let output: MealAIOutput
    let envelope: GluMealEnvelope?
}

struct MealEntry: Identifiable, Equatable {
    let id: UUID
    let createdAt: Date
    let thumbnailData: Data?
    let output: MealAIOutput
    /// Server envelope when present; legacy rows may be `nil` (UI synthesizes spike copy from `output`).
    var envelope: GluMealEnvelope?

    var timeString: String {
        let f = DateFormatter()
        f.timeStyle = .short
        return f.string(from: createdAt)
    }

    init(
        id: UUID,
        createdAt: Date,
        thumbnailData: Data?,
        output: MealAIOutput,
        envelope: GluMealEnvelope? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.thumbnailData = thumbnailData
        self.output = output
        self.envelope = envelope
    }
}

@Observable
final class MealLogStore {
    private(set) var meals: [MealEntry] = []

    private var supabase: SupabaseClient?
    private var syncUserId: String?

    func configureSync(client: SupabaseClient?, userId: String?) {
        supabase = client
        syncUserId = userId
    }

    /// Loads meal history from `meal_logs` (newest first). Local-only rows stay until refreshed.
    func loadRemoteMeals() async {
        guard let client = supabase, let uidStr = syncUserId, let uid = UUID(uuidString: uidStr) else { return }
        do {
            let rows: [MealLogRow] = try await client
                .from("meal_logs")
                .select()
                .eq("user_id", value: uid.uuidString)
                .order("created_at", ascending: false)
                .execute()
                .value
            let mapped = rows.map {
                MealEntry(
                    id: $0.id,
                    createdAt: $0.created_at,
                    thumbnailData: nil,
                    output: $0.output,
                    envelope: $0.envelope
                )
            }
            await MainActor.run {
                meals = mapped
            }
        } catch {
            #if DEBUG
            print("MealLogStore.loadRemoteMeals:", error)
            #endif
        }
    }

    func add(_ entry: MealEntry) {
        meals.insert(entry, at: 0)
    }

    func delete(id: UUID) {
        meals.removeAll { $0.id == id }
        Task {
            await deleteRemote(id: id)
        }
    }

    /// Deletes a server row without mutating local state (e.g. discard analysis sheet before save).
    func deleteServerOnly(id: UUID) async {
        await deleteRemote(id: id)
    }

    func persistInsert(_ entry: MealEntry) async {
        guard let client = supabase, let uidStr = syncUserId, let uid = UUID(uuidString: uidStr) else { return }
        let row = MealLogInsert(
            id: entry.id,
            user_id: uid,
            output: entry.output,
            envelope: entry.envelope
        )
        do {
            try await client.from("meal_logs").insert(row).execute()
        } catch {
            #if DEBUG
            print("MealLogStore.persistInsert:", error)
            #endif
        }
    }

    func replaceEntry(_ entry: MealEntry) async {
        if let i = meals.firstIndex(where: { $0.id == entry.id }) {
            meals[i] = entry
        }
        await persistUpdateOutput(id: entry.id, output: entry.output, envelope: entry.envelope)
    }

    private struct MealLogOutputEnvelopePatch: Encodable {
        let output: MealAIOutput
        let envelope: GluMealEnvelope?
    }

    private func persistUpdateOutput(id: UUID, output: MealAIOutput, envelope: GluMealEnvelope?) async {
        guard let client = supabase, let uidStr = syncUserId, let uid = UUID(uuidString: uidStr) else { return }
        let patch = MealLogOutputEnvelopePatch(output: output, envelope: envelope)
        do {
            try await client
                .from("meal_logs")
                .update(patch)
                .eq("id", value: id.uuidString)
                .eq("user_id", value: uid.uuidString)
                .execute()
        } catch {
            #if DEBUG
            print("MealLogStore.persistUpdateOutput:", error)
            #endif
        }
    }

    private func deleteRemote(id: UUID) async {
        guard let client = supabase, let uidStr = syncUserId, let uid = UUID(uuidString: uidStr) else { return }
        do {
            try await client
                .from("meal_logs")
                .delete()
                .eq("id", value: id.uuidString)
                .eq("user_id", value: uid.uuidString)
                .execute()
        } catch {
            #if DEBUG
            print("MealLogStore.deleteRemote:", error)
            #endif
        }
    }

    var todayMeals: [MealEntry] {
        let cal = Calendar.current
        return meals.filter { cal.isDateInToday($0.createdAt) }
    }

    var streakDays: Int {
        let cal = Calendar.current
        var streak = 0
        var day = cal.startOfDay(for: Date())
        while meals.contains(where: { cal.isDate($0.createdAt, inSameDayAs: day) }) {
            streak += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: day) else { break }
            day = cal.startOfDay(for: prev)
        }
        return streak
    }
}

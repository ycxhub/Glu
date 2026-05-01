import Foundation

/// One row in `onboarding_steps.json` — data-driven flow (add/replace from PRD `onboarding.md`).
struct OnboardingStepDefinition: Identifiable, Codable, Hashable {
    var id: String
    var kind: Kind
    var title: String
    var subtitle: String?
    var options: [String]?
    var cta: String
    /// When true, multi-select **Continue** works with zero selections (optional screens per `design.md` §10).
    var allowEmptySelection: Bool?

    enum Kind: String, Codable {
        case welcome
        case singleChoice
        case multiChoice
        case info
        case notificationPriming
        case calculating
        case planReveal
    }
}

struct OnboardingPayload: Codable {
    var steps: [OnboardingStepDefinition]
}

enum OnboardingStepsLoader {
    static func load() -> [OnboardingStepDefinition] {
        guard let url = Bundle.main.url(forResource: "onboarding_steps", withExtension: "json") else {
            return Self.fallback
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(OnboardingPayload.self, from: data).steps
        } catch {
            return Self.fallback
        }
    }

    private static let fallback: [OnboardingStepDefinition] = [
        .init(
            id: "welcome",
            kind: .welcome,
            title: "Welcome to Oneshot",
            subtitle: "Your personal companion for this template.",
            options: nil,
            cta: "Get Started",
            allowEmptySelection: nil
        ),
        .init(
            id: "goal",
            kind: .singleChoice,
            title: "What is your main goal?",
            subtitle: nil,
            options: ["Lose weight", "Maintain", "Build habits"],
            cta: "Continue",
            allowEmptySelection: nil
        ),
        .init(
            id: "notify",
            kind: .notificationPriming,
            title: "Stay on track",
            subtitle: "We’ll nudge you at the right time.",
            options: nil,
            cta: "Continue",
            allowEmptySelection: nil
        ),
        .init(
            id: "calculating",
            kind: .calculating,
            title: "Creating your plan...",
            subtitle: nil,
            options: nil,
            cta: "Continue",
            allowEmptySelection: nil
        ),
        .init(
            id: "reveal",
            kind: .planReveal,
            title: "Your plan is ready",
            subtitle: "A preview number for the template.",
            options: nil,
            cta: "Save my plan",
            allowEmptySelection: nil
        ),
    ]
}

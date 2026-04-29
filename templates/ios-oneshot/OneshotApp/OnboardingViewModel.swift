import Foundation
import SwiftUI

@Observable
final class OnboardingViewModel {
    let steps: [OnboardingStepDefinition]
    var index: Int = 0
    var responses: [String: [String]] = [:]

    init(
        steps: [OnboardingStepDefinition] = OnboardingStepsLoader.load()
    ) {
        self.steps = steps
    }

    var current: OnboardingStepDefinition? {
        guard index >= 0, index < steps.count else { return nil }
        return steps[index]
    }

    var isLast: Bool { index >= steps.count - 1 }

    func advance() {
        guard !isLast else { return }
        index += 1
    }

    func record(single: String, stepId: String) {
        responses[stepId] = [single]
    }

    func record(multi: [String], stepId: String) {
        responses[stepId] = multi
    }
}

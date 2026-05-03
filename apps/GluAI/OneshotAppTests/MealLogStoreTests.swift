import Testing
import Foundation
@testable import Glu_AI

// MARK: - MealLogStore hasLoadedOnce Tests
//
// The hasLoadedOnce flag guards empty states so they don't flash
// "Log your first meal" while remote meals are still syncing.
//
// State diagram:
//
//   init (false) ──▶ loadRemoteMeals() ──▶ true (success OR failure)
//                          │
//                          └─ guard fail (no client) ──▶ true
//

@Suite("MealLogStore hasLoadedOnce")
struct MealLogStoreHasLoadedOnceTests {

    @Test("hasLoadedOnce is false on init")
    func initiallyFalse() {
        let store = MealLogStore()
        #expect(store.hasLoadedOnce == false)
    }

    @Test("hasLoadedOnce becomes true after loadRemoteMeals with no client configured")
    @MainActor
    func trueAfterLoadWithNoClient() async {
        let store = MealLogStore()
        // No supabase client configured — guard returns early
        await store.loadRemoteMeals()
        #expect(store.hasLoadedOnce == true)
    }

    @Test("meals array is empty after load with no client")
    @MainActor
    func mealsEmptyAfterNoClient() async {
        let store = MealLogStore()
        await store.loadRemoteMeals()
        #expect(store.meals.isEmpty)
    }

    @Test("hasLoadedOnce becomes true after loadRemoteMeals with nil userId")
    @MainActor
    func trueAfterLoadWithNilUserId() async {
        let store = MealLogStore()
        store.configureSync(client: nil, userId: nil)
        await store.loadRemoteMeals()
        #expect(store.hasLoadedOnce == true)
    }

    @Test("add meal does not affect hasLoadedOnce")
    @MainActor
    func addMealDoesNotSetFlag() {
        let store = MealLogStore()
        let entry = MealEntry(
            id: UUID(),
            createdAt: Date(),
            thumbnailData: nil,
            output: MealAIOutput(
                items: [],
                totals: MealTotals(calories: 500, carbsG: 50, fiberG: nil, sugarG: nil, proteinG: 20, fatG: 15),
                spikeRisk: "Low",
                rationale: "Test rationale",
                disclaimer: "Educational only",
                confidence: 0.95
            ),
            envelope: nil
        )
        store.add(entry)
        #expect(store.hasLoadedOnce == false)
        #expect(store.meals.count == 1)
    }
}

// MARK: - MealLogStore basic operations

@Suite("MealLogStore CRUD")
struct MealLogStoreCRUDTests {

    private func makeMealEntry(calories: Int = 500) -> MealEntry {
        MealEntry(
            id: UUID(),
            createdAt: Date(),
            thumbnailData: nil,
            output: MealAIOutput(
                items: [],
                totals: MealTotals(calories: calories, carbsG: 50, fiberG: nil, sugarG: nil, proteinG: 20, fatG: 15),
                spikeRisk: "Low",
                rationale: "Test rationale",
                disclaimer: "Educational only",
                confidence: 0.95
            ),
            envelope: nil
        )
    }

    @Test("add inserts at front")
    @MainActor
    func addInsertsAtFront() {
        let store = MealLogStore()
        let first = makeMealEntry(calories: 100)
        let second = makeMealEntry(calories: 200)
        store.add(first)
        store.add(second)
        #expect(store.meals.first?.output.totals?.calories == 200)
        #expect(store.meals.count == 2)
    }

    @Test("delete removes by id")
    @MainActor
    func deleteRemovesById() {
        let store = MealLogStore()
        let entry = makeMealEntry()
        store.add(entry)
        #expect(store.meals.count == 1)
        store.delete(id: entry.id)
        #expect(store.meals.isEmpty)
    }

    @Test("delete with unknown id is a no-op")
    @MainActor
    func deleteUnknownIdNoOp() {
        let store = MealLogStore()
        let entry = makeMealEntry()
        store.add(entry)
        store.delete(id: UUID())
        #expect(store.meals.count == 1)
    }
}

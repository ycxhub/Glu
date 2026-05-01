import Foundation
import Supabase

/// Privileged role from `user_staff_roles` (assigned only via Supabase SQL / service role).
enum StaffRole: String, Sendable {
    case admin
    case developer
}

enum AccessEvaluator {
    /// Main app (tabs) for subscribers/trial, staff admin/developer, or **free tier** with remaining analyses.
    static func canUseMainApp(
        staffRole: StaffRole?,
        subscriptionAllowsAccess: Bool,
        choseFreeTier: Bool,
        freeMealAnalysesRemaining: Int
    ) -> Bool {
        if let staffRole {
            switch staffRole {
            case .admin, .developer:
                return true
            }
        }
        if subscriptionAllowsAccess { return true }
        if choseFreeTier && freeMealAnalysesRemaining > 0 { return true }
        return false
    }
}

struct UserStaffRoleRow: Decodable {
    let user_id: UUID
    let role: String
}

@MainActor
enum StaffRoleService {
    static func fetchStaffRole(client: SupabaseClient, userId: UUID) async -> StaffRole? {
        do {
            let rows: [UserStaffRoleRow] = try await client
                .from("user_staff_roles")
                .select()
                .eq("user_id", value: userId.uuidString)
                .limit(1)
                .execute()
                .value
            guard let raw = rows.first?.role else { return nil }
            return StaffRole(rawValue: raw)
        } catch {
            #if DEBUG
            print("StaffRoleService.fetch failed:", error)
            #endif
            return nil
        }
    }
}

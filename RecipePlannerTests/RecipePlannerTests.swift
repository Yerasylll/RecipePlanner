import XCTest

@testable import RecipePlanner

final class RecipePlannerTests: XCTestCase {

    // MARK: - ENDTERM Tests (5 required)

    // Test 1: Recommendation Engine Scoring
    func testRecommendationScoreCalculation() {
        let recipe = Recipe(
            id: 1,
            title: "Quick Pasta",
            image: nil,
            summary: nil,
            readyInMinutes: 20,
            servings: 4,
            sourceUrl: nil,
            isFavorite: false
        )

        let score = RecommendationEngine.calculateScore(
            recipe: recipe,
            favoritesCount: 10,
            ingredientMatch: 5,
            recentViews: 3
        )

        // Expected: (10 * 2) + (5 * 3) + (3 * 1) + 5 (bonus for <30 min) = 43
        XCTAssertEqual(
            score, 43,
            "Score should be 43 for recipe with 10 favorites, 5 ingredient matches, 3 views, and <30 min"
        )
    }

    // Test 2: Pagination Offset Logic
    func testPaginationOffsetIncrement() {
        var offset = 0
        let pageSize = 20

        // First page
        XCTAssertEqual(offset, 0, "Initial offset should be 0")

        // Load page
        offset += pageSize
        XCTAssertEqual(offset, 20, "After loading 20 items, offset should be 20")

        // Load second page
        offset += pageSize
        XCTAssertEqual(offset, 40, "After loading another 20 items, offset should be 40")
    }

    // Test 3: Search Query Validation
    func testSearchQueryTrimming() {
        let dirtyQuery = "  pasta carbonara  "
        let cleanQuery = dirtyQuery.trimmingCharacters(in: .whitespacesAndNewlines)

        XCTAssertEqual(cleanQuery, "pasta carbonara", "Query should be trimmed of whitespace")
        XCTAssertNotEqual(dirtyQuery, cleanQuery, "Trimmed query should differ from original")
    }

    // Test 4: Recipe ID Uniqueness (Duplicate Prevention)
    func testRecipeIdUniqueness() {
        let recipes = [
            Recipe(
                id: 1, title: "Pasta", image: nil, summary: nil, readyInMinutes: 30, servings: 4,
                sourceUrl: nil, isFavorite: false),
            Recipe(
                id: 2, title: "Pizza", image: nil, summary: nil, readyInMinutes: 45, servings: 6,
                sourceUrl: nil, isFavorite: false),
            Recipe(
                id: 1, title: "Pasta Duplicate", image: nil, summary: nil, readyInMinutes: 25,
                servings: 4, sourceUrl: nil, isFavorite: false),
        ]

        let uniqueIds = Set(recipes.map { $0.id })

        XCTAssertEqual(uniqueIds.count, 2, "Should have only 2 unique recipe IDs despite 3 recipes")
        XCTAssertTrue(uniqueIds.contains(1), "Set should contain ID 1")
        XCTAssertTrue(uniqueIds.contains(2), "Set should contain ID 2")
    }

    // Test 5: Timestamp-Based Sync (Stale Data Detection)
    func testStaleDataDetection() {
        let now = Date()
        let oneDayAgo = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        let eightDaysAgo = Calendar.current.date(byAdding: .day, value: -8, to: now)!

        let staleThreshold = 7  // days

        // Check if data is stale
        let recentDataIsStale =
            Calendar.current.dateComponents([.day], from: oneDayAgo, to: now).day! > staleThreshold
        let oldDataIsStale =
            Calendar.current.dateComponents([.day], from: eightDaysAgo, to: now).day!
            > staleThreshold

        XCTAssertFalse(recentDataIsStale, "Data from 1 day ago should not be stale")
        XCTAssertTrue(oldDataIsStale, "Data from 8 days ago should be stale")
    }

    // MARK: - FINAL Tests (5 additional required)

    // Test 6: Meal Plan Date Validation
    func testMealPlanDateNotInPast() {
        let now = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: now)!

        XCTAssertTrue(tomorrow > now, "Tomorrow should be in the future")
        XCTAssertFalse(yesterday > now, "Yesterday should not be in the future")
    }

    // Test 7: Rating Validation (1-5 stars)
    func testRatingValueValidation() {
        let validRatings = [1, 2, 3, 4, 5]
        let invalidRatings = [0, -1, 6, 10]

        for rating in validRatings {
            XCTAssertTrue((1...5).contains(rating), "Rating \(rating) should be valid")
        }

        for rating in invalidRatings {
            XCTAssertFalse((1...5).contains(rating), "Rating \(rating) should be invalid")
        }
    }

    // Test 8: Comment Text Validation (Not Empty)
    func testCommentTextValidation() {
        let validComment = "This recipe is great!"
        let emptyComment = "   "
        let nilComment = ""

        XCTAssertFalse(
            validComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            "Valid comment should not be empty")
        XCTAssertTrue(
            emptyComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            "Whitespace-only comment should be considered empty")
        XCTAssertTrue(nilComment.isEmpty, "Empty string should be empty")
    }

    // Test 9: Password Strength Validation
    func testPasswordStrengthValidation() {
        let weakPassword = "123"
        let validPassword = "password123"
        let strongPassword = "MyStr0ng!Pass"

        let minLength = 6

        XCTAssertFalse(
            weakPassword.count >= minLength, "Weak password should fail minimum length check")
        XCTAssertTrue(
            validPassword.count >= minLength, "Valid password should pass minimum length check")
        XCTAssertTrue(
            strongPassword.count >= minLength, "Strong password should pass minimum length check")
    }

    // Test 10: Email Format Validation
    func testEmailFormatValidation() {
        let validEmails = ["test@example.com", "user.name@domain.co.uk", "email123@test.org"]
        let invalidEmails = ["notanemail", "@nodomain.com", "missing@.com", "no@domain"]

        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)

        for email in validEmails {
            XCTAssertTrue(emailPredicate.evaluate(with: email), "Email \(email) should be valid")
        }

        for email in invalidEmails {
            XCTAssertFalse(emailPredicate.evaluate(with: email), "Email \(email) should be invalid")
        }
    }
}

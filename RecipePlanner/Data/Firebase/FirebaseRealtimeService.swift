import Foundation
import FirebaseDatabase

class FirebaseRealtimeService {
    private let database = Database.database().reference()
    
    // MARK: - Comments
    
    func addComment(recipeId: Int, userId: String, username: String, text: String) async throws {
        let commentRef = database.child("comments").child("\(recipeId)").childByAutoId()
        
        let commentData: [String: Any] = [
            "userId": userId,
            "username": username,
            "text": text,
            "timestamp": ServerValue.timestamp()
        ]
        
        try await commentRef.setValue(commentData)
    }
    
    func observeComments(recipeId: Int, completion: @escaping ([Comment]) -> Void) {
        database.child("comments").child("\(recipeId)")
            .observe(.value) { snapshot in
                var comments: [Comment] = []
                
                for child in snapshot.children {
                    if let snap = child as? DataSnapshot,
                       let dict = snap.value as? [String: Any],
                       let userId = dict["userId"] as? String,
                       let username = dict["username"] as? String,
                       let text = dict["text"] as? String,
                       let timestamp = dict["timestamp"] as? Double {
                        
                        let comment = Comment(
                            id: snap.key,
                            recipeId: recipeId,
                            userId: userId,
                            username: username,
                            text: text,
                            timestamp: timestamp / 1000
                        )
                        comments.append(comment)
                    }
                }
                
                completion(comments.sorted { $0.timestamp > $1.timestamp })
            }
    }
    
    func removeCommentObserver(recipeId: Int) {
        database.child("comments").child("\(recipeId)").removeAllObservers()
    }
    
    func deleteComment(recipeId: Int, commentId: String) async throws {
        try await database.child("comments").child("\(recipeId)").child(commentId).removeValue()
    }
    
    // MARK: - Favorites
    
    func addFavorite(userId: String, recipeId: Int) async throws {
        let ref = database.child("users").child(userId).child("favorites").child("\(recipeId)")
        
        let data: [String: Any] = [
            "recipeId": recipeId,
            "addedAt": ServerValue.timestamp()
        ]
        
        try await ref.setValue(data)
    }
    
    func removeFavorite(userId: String, recipeId: Int) async throws {
        try await database.child("users").child(userId).child("favorites").child("\(recipeId)").removeValue()
    }
    
    func getFavorites(userId: String) async throws -> [Int] {
        let snapshot = try await database.child("users").child(userId).child("favorites").getData()
        
        var recipeIds: [Int] = []
        
        for child in snapshot.children {
            if let snap = child as? DataSnapshot,
               let data = snap.value as? [String: Any],
               let recipeId = data["recipeId"] as? Int {
                recipeIds.append(recipeId)
            }
        }
        
        return recipeIds
    }
    
    // MARK: - Meal Plans
    
    func addMealPlan(_ mealPlan: MealPlan) async throws {
        let ref = database.child("users").child(mealPlan.userId).child("mealPlans").child(mealPlan.id)
        
        let data: [String: Any] = [
            "recipeId": mealPlan.recipeId,
            "recipeName": mealPlan.recipeName,
            "date": mealPlan.date.timeIntervalSince1970,
            "mealType": mealPlan.mealType.rawValue
        ]
        
        try await ref.setValue(data)
    }
    
    func getMealPlans(userId: String) async throws -> [MealPlan] {
        let snapshot = try await database.child("users").child(userId).child("mealPlans").getData()
        
        var mealPlans: [MealPlan] = []
        
        for child in snapshot.children {
            if let snap = child as? DataSnapshot,
               let data = snap.value as? [String: Any],
               let recipeId = data["recipeId"] as? Int,
               let recipeName = data["recipeName"] as? String,
               let dateTimestamp = data["date"] as? Double,
               let mealTypeStr = data["mealType"] as? String,
               let mealType = MealType(rawValue: mealTypeStr) {
                
                let mealPlan = MealPlan(
                    id: snap.key,
                    userId: userId,
                    recipeId: recipeId,
                    recipeName: recipeName,
                    date: Date(timeIntervalSince1970: dateTimestamp),
                    mealType: mealType
                )
                mealPlans.append(mealPlan)
            }
        }
        
        return mealPlans.sorted { $0.date < $1.date }
    }
    
    func deleteMealPlan(userId: String, mealPlanId: String) async throws {
        try await database.child("users").child(userId).child("mealPlans").child(mealPlanId).removeValue()
    }


    // MARK: - Ratings
    func addRating(recipeId: Int, userId: String, username: String, rating: Int, review: String?) async throws {
        let ratingRef = database.child("ratings").child("\(recipeId)").child(userId)
        
        let ratingData: [String: Any] = [
            "userId": userId,
            "username": username,
            "rating": rating,
            "review": review ?? "",
            "timestamp": ServerValue.timestamp()
        ]
        
        try await ratingRef.setValue(ratingData)
    }

    func getRatings(recipeId: Int) async throws -> [Rating] {
        let snapshot = try await database.child("ratings").child("\(recipeId)").getData()
        
        var ratings: [Rating] = []
        
        for child in snapshot.children {
            if let snap = child as? DataSnapshot,
               let dict = snap.value as? [String: Any],
               let userId = dict["userId"] as? String,
               let username = dict["username"] as? String,
               let ratingValue = dict["rating"] as? Int,
               let timestamp = dict["timestamp"] as? Double {
                
                let review = dict["review"] as? String
                
                let rating = Rating(
                    id: snap.key,
                    recipeId: recipeId,
                    userId: userId,
                    username: username,
                    rating: ratingValue,
                    review: review?.isEmpty == false ? review : nil,
                    timestamp: timestamp / 1000
                )
                ratings.append(rating)
            }
        }
        
        return ratings.sorted { $0.timestamp > $1.timestamp }
    }

    func getAverageRating(recipeId: Int) async throws -> Double {
        let ratings = try await getRatings(recipeId: recipeId)
        guard !ratings.isEmpty else { return 0.0 }
        
        let sum = ratings.reduce(0) { $0 + $1.rating }
        return Double(sum) / Double(ratings.count)
    }


    // MARK: - Recently Viewed
    func saveRecentlyViewed(userId: String, recipeId: Int, recipeName: String, imageURL: String?) async throws {
        let ref = database.child("users").child(userId).child("recentlyViewed").child("\(recipeId)")
        
        let data: [String: Any] = [
            "recipeId": recipeId,
            "recipeName": recipeName,
            "imageURL": imageURL ?? "",
            "viewedAt": ServerValue.timestamp()
        ]
        
        try await ref.setValue(data)
    }

    func getRecentlyViewed(userId: String, limit: Int = 10) async throws -> [RecentRecipe] {
        let snapshot = try await database.child("users").child(userId).child("recentlyViewed")
            .queryOrdered(byChild: "viewedAt")
            .queryLimited(toLast: UInt(limit))
            .getData()
        
        var recipes: [RecentRecipe] = []
        
        for child in snapshot.children {
            if let snap = child as? DataSnapshot,
               let dict = snap.value as? [String: Any],
               let recipeId = dict["recipeId"] as? Int,
               let recipeName = dict["recipeName"] as? String,
               let timestamp = dict["viewedAt"] as? Double {
                
                let imageURL = dict["imageURL"] as? String
                
                let recipe = RecentRecipe(
                    recipeId: recipeId,
                    recipeName: recipeName,
                    imageURL: imageURL?.isEmpty == false ? imageURL : nil,
                    viewedAt: Date(timeIntervalSince1970: timestamp / 1000)
                )
                recipes.append(recipe)
            }
        }
        
        return recipes.sorted { $0.viewedAt > $1.viewedAt }
    }
}


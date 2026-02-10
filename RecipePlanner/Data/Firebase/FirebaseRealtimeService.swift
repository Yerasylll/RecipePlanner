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
}


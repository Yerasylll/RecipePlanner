import Foundation
import CoreData

@objc(RecipeEntity)
public class RecipeEntity: NSManagedObject {
    
}

extension RecipeEntity {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecipeEntity> {
        return NSFetchRequest<RecipeEntity>(entityName: "RecipeEntity")
    }
    
    @NSManaged public var id: Int64
    @NSManaged public var title: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var summary: String?
    @NSManaged public var readyInMinutes: Int16
    @NSManaged public var servings: Int16
    @NSManaged public var sourceURL: String?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var timestamp: Date?
    
}

extension RecipeEntity : Identifiable {
    
    public var recipeId: Int {
        return Int(id)
    }
    
    func toRecipe() -> Recipe {
        Recipe(
            id: Int(id),
            title: title ?? "Unknown Recipe",
            image: imageURL,
            summary: summary,
            readyInMinutes: readyInMinutes > 0 ? Int(readyInMinutes) : nil,
            servings: servings > 0 ? Int(servings) : nil,
            sourceUrl: sourceURL,
            isFavorite: isFavorite
        )
    }
}

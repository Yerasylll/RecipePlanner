import Foundation
import CoreData

@objc(RecipeEntity)
public class RecipeEntity: NSManagedObject {
    @NSManaged public var id: Int64
    @NSManaged public var title: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var summary: String?
    @NSManaged public var readyInMinutes: Int16
    @NSManaged public var servings: Int16
    @NSManaged public var sourceURL: String?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var timestamp: Date?
    
    func toRecipe() -> Recipe {
        Recipe(
            id: Int(id),
            title: title ?? "Unknown",
            image: imageURL,
            summary: summary,
            readyInMinutes: Int(readyInMinutes),
            servings: Int(servings),
            sourceUrl: sourceURL,
            isFavorite: isFavorite
        )
    }
}

extension RecipeEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecipeEntity> {
        return NSFetchRequest<RecipeEntity>(entityName: "RecipeEntity")
    }
}

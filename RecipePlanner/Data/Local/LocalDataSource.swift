import Foundation
import CoreData

class LocalDataSource {
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    // MARK: - Save Recipes
    func saveRecipes(_ recipes: [Recipe]) {
        let context = coreDataStack.context
        
        for recipe in recipes {
            let fetchRequest: NSFetchRequest<RecipeEntity> = RecipeEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %d", recipe.id)
            
            do {
                let results = try context.fetch(fetchRequest)
                let entity = results.first ?? RecipeEntity(context: context)
                
                entity.id = Int64(recipe.id)
                entity.title = recipe.title
                entity.imageURL = recipe.image
                entity.summary = recipe.summary
                entity.readyInMinutes = Int16(recipe.readyInMinutes ?? 0)
                entity.servings = Int16(recipe.servings ?? 0)
                entity.sourceURL = recipe.sourceUrl
                entity.timestamp = Date()
                
            } catch {
                print("❌ Error saving recipe: \(error)")
            }
        }
        
        coreDataStack.save()
    }
    
    // MARK: - Get Cached Recipes
    func getCachedRecipes(query: String, offset: Int) -> [Recipe] {
        let context = coreDataStack.context
        let fetchRequest: NSFetchRequest<RecipeEntity> = RecipeEntity.fetchRequest()
        
        if !query.isEmpty && query != "popular" {
            fetchRequest.predicate = NSPredicate(format: "title CONTAINS[cd] %@", query)
        }
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        fetchRequest.fetchLimit = 20
        fetchRequest.fetchOffset = offset
        
        do {
            let entities = try context.fetch(fetchRequest)
            return entities.map { $0.toRecipe() }
        } catch {
            print("❌ Error fetching cached recipes: \(error)")
            return []
        }
    }
    
    // MARK: - Update Favorite Status
    func updateFavoriteStatus(recipeId: Int, isFavorite: Bool) {
        let context = coreDataStack.context
        let fetchRequest: NSFetchRequest<RecipeEntity> = RecipeEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", recipeId)
        
        do {
            if let entity = try context.fetch(fetchRequest).first {
                entity.isFavorite = isFavorite
                coreDataStack.save()
            }
        } catch {
            print("❌ Error updating favorite: \(error)")
        }
    }
    
    // MARK: - Get Favorites
    func getFavorites() -> [Recipe] {
        let context = coreDataStack.context
        let fetchRequest: NSFetchRequest<RecipeEntity> = RecipeEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isFavorite == YES")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        do {
            let entities = try context.fetch(fetchRequest)
            return entities.map { $0.toRecipe() }
        } catch {
            print("❌ Error fetching favorites: \(error)")
            return []
        }
    }
    
    // MARK: - Clear Old Cache
    func clearOldCache(olderThan days: Int = 7) {
        let context = coreDataStack.context
        let fetchRequest: NSFetchRequest<RecipeEntity> = RecipeEntity.fetchRequest()
        
        if let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) {
            fetchRequest.predicate = NSPredicate(format: "timestamp < %@ AND isFavorite == NO", cutoffDate as NSDate)
            
            do {
                let oldEntities = try context.fetch(fetchRequest)
                for entity in oldEntities {
                    context.delete(entity)
                }
                coreDataStack.save()
                print("✅ Cleared \(oldEntities.count) old cached recipes")
            } catch {
                print("❌ Error clearing old cache: \(error)")
                            }
                        }
                    }
                }

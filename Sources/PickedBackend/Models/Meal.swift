
import Fluent
import Vapor

enum FoodType: String, Codable, Content {
    case american
    case asian
    case indian
    case italian
    case mediterranean
    case mexican
    case vegan
    case vegetarian
    case other
}

//MARK: Modelo de Meal con sus atributos para la BBDD
final class Meal: Model, Content, @unchecked Sendable {
    
    static let schema = "meals"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "info")
    var info : String
    
    @Field(key: "photo")
    var photo: String

    @Field(key: "price")
    var price: Float
    
    @Field(key: "units")
    var units: Int
    
    @Field(key: "food_type")
    var type: FoodType
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    @OptionalParent(key: "created_by")
    var creator: User?
    
    @OptionalParent(key: "updated_by")
    var editor: User?
    
    @Parent(key: "restaurant_id")
    var restaurant: Restaurant
    
    init() {}

    init(id: UUID? = nil, name: String, info: String, photo: String, price: Float, restaurantID: UUID) {
        self.id = id
        self.name = name
        self.info = info
        self.photo = photo
        self.price = price
        self.$restaurant.id = restaurantID
    }
}

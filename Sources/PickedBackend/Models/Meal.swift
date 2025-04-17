
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
    
    @Parent(key: "restaurant_id")
    var restaurant: Restaurant
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    @OptionalParent(key: "created_by")
    var creator: User?
    
    @OptionalParent(key: "updated_by")
    var editor: User?
    
    init() {}

    init(id: UUID? = nil, name: String, info: String, photo: String, price: Float, units: Int, type: FoodType, restaurantID: UUID) {
        self.id = id
        self.name = name
        self.info = info
        self.photo = photo
        self.price = price
        self.units = units
        self.type = type
        self.$restaurant.id = restaurantID
    }
}

//MARK: Método que aplica los updates a meal para dejar el metodo del controller más limpio
extension Meal {
    func applyUpdate(from dto: MealUpdateDTO) {
        if let name = dto.name {
            self.name = name
        }
        if let info = dto.info {
            self.info = info
        }
        if let price = dto.price {
            self.price = price
        }
        if let units = dto.units {
            self.units = units
        }
        if let type = dto.type {
            self.type = type
        }
    }
}

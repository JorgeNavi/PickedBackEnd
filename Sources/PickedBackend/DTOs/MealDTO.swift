import Vapor

//MARK: DTO de creación y detalle de plato en la BBDD
struct MealDTO: Content {
    let name: String
    let info: String
    let price: Float
    let units: Int
    let type: FoodType
}

//MARK: DTO para representar un plato básico
struct MealRestaurantDTO: Content {
    let id: UUID
    let name: String
    let units: Int
    let price: Float
    let photo: String
}

//MARK: DTO para la edición de meal
struct MealUpdateDTO: Content {
    let name: String?
    let info: String?
    let price: Float?
    let units: Int?
    let type: FoodType?
}

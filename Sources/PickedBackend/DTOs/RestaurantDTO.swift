import Vapor

// MARK: DTO para el registro de usuario tipo restaurante
struct RestaurantRegisterDTO: Content {
    //Datos del usuario
    let name: String
    let email: String
    let password: String
    let role: UserRole

    //Datos del restaurante
    let restaurantName: String
    let info: String
    let address: String
    let country: String
    let city: String
    let zipCode: String
    let latitude: Double
    let longitude: Double
}

//MARK: DTO para representar los detalles de un restaurante
struct RestaurantDetailDTO: Content {
    let id: UUID
    let name: String
    let info: String
    let photo: String
    let address: String
    let country: String
    let city: String
    let zipCode: String
    let latitude: Double
    let longitude: Double
    let meals: [MealRestaurantDTO]
}

//MARK: DTO para la edición de restaurante
struct RestaurantUpdateDTO: Content {
    let name: String?
    let info: String?
    let address: String?
    let country: String?
    let city: String?
    let zipCode: String?
    let latitude: Double?
    let longitude: Double?
}

//MARK: DTO para que el restaurante vea las compras realizadas a sus platos
struct RestaurantPurchaseDTO: Content {
    let mealName: String
    let consumerName: String
    let quantity: Int
    let date: Date
}

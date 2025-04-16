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

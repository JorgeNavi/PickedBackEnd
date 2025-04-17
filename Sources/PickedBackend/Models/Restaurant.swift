import Fluent
import Vapor

//MARK: Modelo de Restaurant con sus atributos para la BBDD
final class Restaurant: Model, Content, @unchecked Sendable {
    
    static let schema = "restaurants"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "info")
    var info : String
    
    @Field(key: "photo")
    var photo: String
    
    @Field(key: "address")
    var address: String

    @Field(key: "country")
    var country: String

    @Field(key: "city")
    var city: String

    @Field(key: "zip_code")
    var zipCode: String

    @Field(key: "latitude")
    var latitude: Double

    @Field(key: "longitude")
    var longitude: Double
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    @OptionalParent(key: "created_by")
    var creator: User?
    
    @OptionalParent(key: "updated_by")
    var editor: User?
    
    @Parent(key: "user_id")
    var user: User
    
    @Children(for: \.$restaurant)
    var meals: [Meal]
    
    init() {}

    init(id: UUID? = nil, name: String, info: String, photo: String, address: String, country: String, city: String, zipCode: String, latitude: Double, longitude: Double, userID: UUID) {
        self.id = id
        self.name = name
        self.info = info
        self.photo = photo
        self.address = address
        self.country = country
        self.city = city
        self.zipCode = zipCode
        self.latitude = latitude
        self.longitude = longitude
        self.$user.id = userID
    }
}

//MARK: Extension de restaurante para el dto de detalle añadiendo los platos asignados
extension Restaurant {
    func toDetailDTO(meals: [Meal]) -> RestaurantDetailDTO {
        let mealDTOs = meals.map { meal in
            MealRestaurantDTO(id: meal.id!, name: meal.name, price: meal.price, photo: meal.photo)
        }
        return RestaurantDetailDTO(
            id: self.id!,
            name: self.name,
            info: self.info,
            photo: self.photo,
            address: self.address,
            country: self.country,
            city: self.city,
            zipCode: self.zipCode,
            latitude: self.latitude,
            longitude: self.longitude,
            meals: mealDTOs
        )
    }
}

//MARK: Método que aplica los updates a restaurant para dejar el metodo del controller más limpio
extension Restaurant {
    func applyUpdate(from dto: RestaurantUpdateDTO) {
        if let name = dto.name {
            self.name = name
        }
        if let info = dto.info {
            self.info = info
        }
        if let address = dto.address {
            self.address = address
        }
        if let country = dto.country {
            self.country = country
        }
        if let city = dto.city {
            self.city = city
        }
        if let zipCode = dto.zipCode {
            self.zipCode = zipCode
        }
        if let lat = dto.latitude {
            self.latitude = lat
        }
        if let lon = dto.longitude {
            self.longitude = lon
        }
    }
}

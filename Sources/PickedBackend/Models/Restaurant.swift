import Fluent
import Vapor


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

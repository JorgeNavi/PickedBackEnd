import Fluent
import Vapor

enum UserRole: String, Codable, Content {
    case consumer
    case restaurant
    case admin
}


final class User: Model, Content, @unchecked Sendable {
    
    static let schema: String = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "password")
    var password: String
    
    @Field(key: "role")
    var role: UserRole
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() {}

    init(id: UUID? = nil, name: String, email: String, password: String, role: UserRole) {
        self.id = id
        self.name = name
        self.email = email
        self.password = password
        self.role = role
    }
}

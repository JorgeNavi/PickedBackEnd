import Fluent
import Vapor

//MARK: Enum con las distintas opciones para el rol de usuario
enum UserRole: String, Codable, Content {
    case consumer
    case restaurant
    case admin
}


//MARK: Modelo de User con sus atributos para la BBDD
final class User: Model, Content, Authenticatable, @unchecked Sendable {
    
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
    
    @OptionalChild(for: \.$user)
    var restaurant: Restaurant?
    
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

//MARK: Transformador del modelo User a DTO de respuesta
extension User {
    func toLoginResponseDTO(token: String) throws -> UserLoginResponseDTO {
        return try UserLoginResponseDTO(
            id: requireID(),
            name: name,
            email: email,
            role: role,
            token: token
        )
    }
    
    //MARK: Método que aplica los updates a user para dejar el metodo del controller más limpio
    func applyUpdate(from dto: UserUpdateDTO) throws {
        if let name = dto.name {
            self.name = name
        }
        if let email = dto.email {
            self.email = email
        }
        if let password = dto.password {
            self.password = try Bcrypt.hash(password)
        }
    }
}

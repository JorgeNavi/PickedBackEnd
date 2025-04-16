import Vapor

//MARK: DTO de entrada: datos que esperamos recibir desde el frontend para registro
struct UserRegisterDTO: Content {
    let name: String
    let email: String
    let password: String
    let role: UserRole
}

//MARK: DTO de entrada: datos que esperamos recibir desde el frontend para login
struct UserLoginDTO: Content {
    let email: String
    let password: String
}

//MARK: DTO de salida: datos que devolvemos al frontend tras login exitoso
struct UserLoginResponseDTO: Content {
    let id: UUID
    let name: String
    let email: String
    let role: UserRole
    let token: String
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
}

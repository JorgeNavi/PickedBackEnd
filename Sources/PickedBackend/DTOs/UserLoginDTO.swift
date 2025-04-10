import Vapor

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
            id: requireID(),     // Asegura que el ID no es nil (lanza error si lo es)
            name: name,
            email: email,
            role: role,
            token: token
        )
    }
}

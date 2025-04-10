import Vapor

// MARK: - DTO de entrada: datos que esperamos recibir desde el frontend para login
struct UserLoginDTO: Content {
    let email: String      // El email con el que el usuario quiere autenticarse
    let password: String   // La contraseña en texto plano (se verificará contra la hasheada)
}

// MARK: - DTO de salida: datos que devolvemos al frontend tras login exitoso
struct UserLoginResponseDTO: Content {
    let id: UUID           // Identificador único del usuario
    let name: String       // Nombre del usuario
    let email: String      // Email del usuario (sin la contraseña)
    let role: UserRole     // Rol del usuario (consumer, restaurant, admin)
    let token: String      // Token JWT generado para autenticación
}

// MARK: - Transformador del modelo User a DTO de respuesta
extension User {
    /// Convierte un modelo User en un UserLoginResponseDTO, añadiendo el token JWT generado
    /// - Parameter token: El token JWT que se incluirá en la respuesta
    /// - Returns: UserLoginResponseDTO con los datos visibles del usuario + el token
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

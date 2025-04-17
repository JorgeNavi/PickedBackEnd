import Vapor

//MARK: DTO de datos que esperamos recibir desde el frontend para registro
struct UserRegisterDTO: Content {
    let name: String
    let email: String
    let password: String
    let role: UserRole
}

//MARK: DTO de datos que esperamos recibir desde el frontend para login
struct UserLoginDTO: Content {
    let email: String
    let password: String
}

//MARK: DTO de datos que devolvemos al frontend tras login exitoso
struct UserLoginResponseDTO: Content {
    let id: UUID
    let name: String
    let email: String
    let role: UserRole
    let token: String
}

//MARK: DTO de actualización de los datos de usuario
struct UserUpdateDTO: Content {
    let name: String?
    let email: String?
    let password: String?
}

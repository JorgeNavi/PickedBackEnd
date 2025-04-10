import Vapor

//MARK: DTO de entrada: datos que esperamos recibir desde el frontend para registro
struct UserRegisterDTO: Content {
    let name: String
    let email: String
    let password: String
    let role: UserRole
}

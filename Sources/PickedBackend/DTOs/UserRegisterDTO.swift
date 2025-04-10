import Vapor

struct UserRegisterDTO: Content {
    let name: String
    let email: String
    let password: String
    let role: UserRole
}

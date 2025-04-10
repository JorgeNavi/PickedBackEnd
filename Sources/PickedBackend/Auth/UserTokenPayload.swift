import JWT
import Vapor

//aqui indicamos de que va a estar compuesto el Token de usuario
struct UserTokenPayload: JWTPayload {
    var userID: UUID //id del usuario
    var role: UserRole //su role (si es restaurant o si es consumer
    var exp: ExpirationClaim //cuando expira

    //este método es obligatorio y lo usa Vapor para verificar que no ha expirado
    func verify(using signer: JWTSigner) throws {
        try exp.verifyNotExpired()
    }
}

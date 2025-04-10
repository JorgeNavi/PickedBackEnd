import JWT
import Vapor

//MARK: De qué se va a componer el token mediante Payload
struct UserTokenPayload: JWTPayload {
    var userID: UUID
    var role: UserRole
    var exp: ExpirationClaim

    //Método obligatorio de Vapor para comprobar si el token ha expirado
    func verify(using signer: JWTSigner) throws {
        try exp.verifyNotExpired()
    }
}

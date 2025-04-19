import Vapor
import JWT
import Fluent


//MARK: Middleware personalizado que verifica el token JWT y autentica al usuario en la petición
struct UserAuthenticator: AsyncMiddleware {

    func respond(to request: Request, chainingTo next: any AsyncResponder) async throws -> Response {

        //Extraemos el token del header Authorization, asegurándonos de que esté en formato Bearer
        guard let bearer = request.headers.bearerAuthorization else {
            //Si no hay token, se lanza un error 401 Unauthorized
            throw Abort(.unauthorized, reason: "Missing bearer token")
        }

        do {
            //Verificamos y decodificamos el JWT
            let payload = try request.jwt.verify(bearer.token, as: UserTokenPayload.self)

            //Buscamos el usuario
            guard let user = try await User.find(payload.userID, on: request.db) else {
                throw Abort(.unauthorized, reason: "User not found")
            }

            //Autenticamos
            request.auth.login(user)

            //Continuamos con la ejecución
            return try await next.respond(to: request)

        } catch let abort as any AbortError {
            
            //Captura y relanza errores genericos de abort
            debugPrint("Abort error: \(abort.status.code) - \(abort.reason)")
            throw abort
            
        } catch let jwtError as JWTError {
            
            //Captura errores de token inválido o caducado
            debugPrint("JWT Error: \(jwtError)")
            throw Abort(.unauthorized, reason: "Invalid or expired token")
            
        } catch {
            
            //Cualquier otro error inesperado
            debugPrint("unexpected", error)
            throw Abort(.internalServerError, reason: "Unexpected error during authentication")
        }
    }
}

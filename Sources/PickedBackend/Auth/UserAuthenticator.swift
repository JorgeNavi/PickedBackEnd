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

            //Buscamos al usuario en la base de datos con el ID extraído del payload del token
            guard let user = try await User.find(payload.userID, on: request.db) else {
                //Si el usuario no existe, lanzamos otro 401
                throw Abort(.unauthorized, reason: "User not found")
            }

            //Si todo está bien, marcamos al usuario como autenticado en esta request
            request.auth.login(user)

            //Continuamos con la ejecución normal de la petición
            return try await next.respond(to: request)

        } catch {
            //Si falla la verificación del token (token inválido o expirado), lanzamos un 401
            throw Abort(.unauthorized, reason: "Invalid or expired token")
        }
    }
}

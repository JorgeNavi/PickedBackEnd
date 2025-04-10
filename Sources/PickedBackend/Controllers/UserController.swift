import Vapor
import Fluent

struct UserController: RouteCollection { //RouteCollection sirve para agrupar las rutas de peticiones de la API
    
    //el método boot es el que va a ser llamado por Vapor para las rutas. Aqui es donde se establecen las diferentes rutas
    func boot(routes: any RoutesBuilder) throws {
        routes.post("register", use: register) //En este caso, la ruta es un método POST a /register y que use para ello, el método register hecho debajo
    }

    func register(req: Request) async throws -> UserLoginResponseDTO {
        
        do {
            let data = try req.content.decode(UserRegisterDTO.self)

            // Comprobar que no exista ya un usuario con ese email
            if try await User.query(on: req.db)
                .filter(\.$email == data.email)
                .first() != nil {
                throw Abort(.conflict, reason: "Ya existe un usuario con ese email.")
            }

            // Encriptar la contraseña
            let hashedPassword = try Bcrypt.hash(data.password)

            // Crear el usuario
            let user = User(
                name: data.name,
                email: data.email,
                password: hashedPassword,
                role: data.role
            )

            try await user.save(on: req.db)

            // Crear y devolver el token directamente tras registrarse
            let payload = UserTokenPayload(
                userID: try user.requireID(),
                role: user.role,
                exp: .init(value: .now.addingTimeInterval(60 * 60 * 24)) // 24h
            )

            let token = try req.jwt.sign(payload)

            return try user.toLoginResponseDTO(token: token)
        } catch {
            print("❌ Error al registrar usuario: \(String(reflecting: error))")
            throw Abort(.internalServerError, reason: "Error al registrar usuario.")
        }

    }
    
    /// Método que gestiona el login de un usuario.
    /// - Recibe: email y contraseña en el cuerpo de la petición.
    /// - Devuelve: un DTO con los datos del usuario autenticado + su token JWT.
    func login(req: Request) async throws -> UserLoginResponseDTO {
        
        // 1. Decodificamos los datos del body de la petición en el DTO de login
        let loginData = try req.content.decode(UserLoginDTO.self)

        // 2. Buscamos en la base de datos un usuario que tenga ese email
        guard let user = try await User.query(on: req.db)
            .filter(\.$email == loginData.email)
            .first()
        else {
            // Si no existe ningún usuario con ese email, lanzamos un error 401
            throw Abort(.unauthorized, reason: "Email o contraseña incorrectos")
        }

        // 3. Verificamos que la contraseña introducida coincide con la hasheada en la BBDD
        guard try Bcrypt.verify(loginData.password, created: user.password) else {
            // Si no coinciden, también lanzamos un 401 (sin especificar si falló el email o la pass)
            throw Abort(.unauthorized, reason: "Email o contraseña incorrectos")
        }

        // 4. Creamos el payload del JWT con la info del usuario
        let payload = UserTokenPayload(
            userID: try user.requireID(),                     // ID del usuario logueado
            role: user.role,                                  // Su rol (consumer, restaurant, admin)
            exp: .init(value: .now.addingTimeInterval(60 * 60 * 24)) // Expira en 24h
        )

        // 5. Generamos el token firmando el payload con la clave secreta
        let token = try req.jwt.sign(payload)

        // 6. Devolvemos los datos del usuario + el token como un DTO de respuesta
        return try user.toLoginResponseDTO(token: token)
    }
}

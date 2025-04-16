import Vapor
import Fluent

//MARK: Controlador de la lógica de las funcionalidades de Usuario
struct UserController: RouteCollection {
    
    //Método boot en el que se incluyen las rutas de las funcionalidades
    func boot(routes: any RoutesBuilder) throws {
        let userRoutes = routes.grouped("auth")
        userRoutes.post("register-consumer", use: consumerRegister)
        userRoutes.post("login", use: login)
    }

    //Método que se llama al hacer registro
    func consumerRegister(req: Request) async throws -> UserLoginResponseDTO {
        
        do {
            
            let data = try req.content.decode(UserRegisterDTO.self)

            //Comprobar que no exista ya un usuario con ese email
            if try await User.query(on: req.db)
                .filter(\.$email == data.email)
                .first() != nil {
                throw Abort(.conflict, reason: "Error: email already exists.")
            }

            //Encriptación de la contraseña
            let hashedPassword = try Bcrypt.hash(data.password)

            //Creación del usuario
            let user = User(
                name: data.name,
                email: data.email,
                password: hashedPassword,
                role: data.role
            )
            
            //se guarda el usuario en la BBDD
            try await user.save(on: req.db)

            //Creación del token con payload y devolución del mismo directamente tras registrarse
            let payload = UserTokenPayload(
                userID: try user.requireID(),
                role: user.role,
                exp: .init(value: .now.addingTimeInterval(60 * 60 * 24 * 30)) //30 días
            )

            //firma del token (requerido) con payload
            let token = try req.jwt.sign(payload)

            return try user.toLoginResponseDTO(token: token)
            
        } catch {
            print("Error: cannot register user: \(String(reflecting: error))")
            throw Abort(.internalServerError, reason: "Error trying to register user.")
        }

    }
    
    //Método que se llama al hacer el Login
    func login(req: Request) async throws -> UserLoginResponseDTO {
        
        //Decodificamos los datos del body de la petición en el DTO de login
        let loginData = try req.content.decode(UserLoginDTO.self)

        //Buscamos en la base de datos un usuario que tenga ese email
        guard let user = try await User.query(on: req.db)
            .filter(\.$email == loginData.email)
            .first()
        else {
            //Si no existe ningún usuario con ese email, lanzamos un error 401
            throw Abort(.unauthorized, reason: "user doesn't exist.")
        }

        //Verificamos que la contraseña introducida coincide con la hasheada en la BBDD
        guard try Bcrypt.verify(loginData.password, created: user.password) else {
            //Si no coinciden, también lanzamos un 401 (sin especificar si falló el email o la pass)
            throw Abort(.unauthorized, reason: "incorrect email or password. Try again.")
        }

        //Creamos el payload del JWT con la info del usuario
        let payload = UserTokenPayload(
            userID: try user.requireID(),
            role: user.role,
            exp: .init(value: .now.addingTimeInterval(60 * 60 * 24))
        )

        //Generamos el token firmando el payload con la clave secreta
        let token = try req.jwt.sign(payload)

        //Devolvemos los datos del usuario + el token como un DTO de respuesta
        return try user.toLoginResponseDTO(token: token)
    }
}

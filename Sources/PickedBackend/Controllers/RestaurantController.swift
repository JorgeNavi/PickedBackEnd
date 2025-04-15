import Vapor
import Fluent

//MARK: Controlador de la lógica de las funcionalidades de Usuario
struct RestaurantController: RouteCollection {
    
    //Método boot en el que se incluyen las rutas de las funcionalidades
    func boot(routes: any RoutesBuilder) throws {
        routes.post("register-restaurant", use: restaurantRegister)
    }
    
    func restaurantRegister(req: Request) async throws -> UserLoginResponseDTO {
        do {
            //Decodificamos el DTO completo con datos de User + Restaurant
            let data = try req.content.decode(RestaurantRegisterDTO.self)
            
            //Verificamos si ya existe un usuario con ese email
            if try await User.query(on: req.db)
                .filter(\.$email == data.email)
                .first() != nil {
                throw Abort(.conflict, reason: "Error: email already exists.")
            }
            
            //Hasheamos la contraseña
            let hashedPassword = try Bcrypt.hash(data.password)
            
            
            //Creamos el usuario con rol restaurant
            let user = User(
                name: data.name,
                email: data.email,
                password: hashedPassword,
                role: data.role
            )
            
            //Guardamos el usuario
            try await user.save(on: req.db)
            
            //Usamos el método de manejo de imagenes
            let photoURL = try await req.saveImageAndReturnURL(from: "photo")
            
            //Creamos el restaurante vinculado al usuario
            let restaurant = Restaurant(
                name: data.restaurantName,
                info: data.info,
                photo: photoURL,
                address: data.address,
                country: data.country,
                city: data.city,
                zipCode: data.zipCode,
                latitude: data.latitude,
                longitude: data.longitude,
                userID: try user.requireID()
            )
            
            //Guardamos el restaurante
            try await restaurant.save(on: req.db)
            
            //Generamos el payload del JWT
            let payload = UserTokenPayload(
                userID: try user.requireID(),
                role: user.role,
                exp: .init(value: .now.addingTimeInterval(60 * 60 * 24)) // 24h
            )
            
            //Firmamos el token
            let token = try req.jwt.sign(payload)
            
            //Devolvemos el DTO
            return try user.toLoginResponseDTO(token: token)
            
        } catch {
            print("Error: cannot register restaurant: \(String(reflecting: error))")
            throw Abort(.internalServerError, reason: "Error trying to register restaurant.")
        }
    }
}

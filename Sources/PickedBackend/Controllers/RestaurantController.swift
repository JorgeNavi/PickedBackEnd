import Vapor
import Fluent

//MARK: Controlador de la lógica de las funcionalidades de Usuario
struct RestaurantController: RouteCollection {
    
    //Método boot en el que se incluyen las rutas de las funcionalidades
    func boot(routes: any RoutesBuilder) throws {
        let restaurantRoutes = routes.grouped("restaurants")
        restaurantRoutes.post("register", use: restaurantRegister)
        restaurantRoutes.post("nearby", use: getNearbyRestaurants)
        restaurantRoutes.get("all", use: getAllRestaurants)
    }
    
    //Método para registrar restaurante en la BBDD
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
    
    //Método para ver los restaurantes en la zona del consumidor
    func getNearbyRestaurants(req: Request) async throws -> [Restaurant] {
        //Decodificamos la localización del consumidor desde el JSON
        let location = try req.content.decode(LocationDTO.self)
        
        //Obtenemos todos los restaurantes
        let allRestaurants = try await Restaurant.query(on: req.db).all()
        
        //Filtramos solo los que están a 10km o menos usando Haversine
        let nearbyRestaurants = allRestaurants.filter { restaurant in
            let distance = haversineDistance(
                lat1: location.latitude,
                lon1: location.longitude,
                lat2: restaurant.latitude,
                lon2: restaurant.longitude
            )
            return distance <= 10 //KM
        }
        
        return nearbyRestaurants
    }
    
    //Método para que podamos comprobar todos los restaurantes
    func getAllRestaurants(req: Request) async throws -> [Restaurant] {
        try await Restaurant.query(on: req.db).all()
    }
}

//Método Haversine para filtrar la distancia del consumidor con 10km de radio para recibir restaurantes
func haversineDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
    let earthRadius = 6371.0
    let dLat = (lat2 - lat1) * .pi / 180
    let dLon = (lon2 - lon1) * .pi / 180
    
    let a = pow(sin(dLat / 2), 2)
          + cos(lat1 * .pi / 180)
          * cos(lat2 * .pi / 180)
          * pow(sin(dLon / 2), 2)
    
    let c = 2 * atan2(sqrt(a), sqrt(1 - a))
    return earthRadius * c
}

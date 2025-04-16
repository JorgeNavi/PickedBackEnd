import Vapor
import Fluent

//MARK: Controlador de la lógica de las funcionalidades de Restaurante
struct RestaurantController: RouteCollection {
    
    //Método boot en el que se incluyen las rutas de las funcionalidades
    func boot(routes: any RoutesBuilder) throws {
        let restaurantRoutes = routes.grouped("restaurants")
        let protected = restaurantRoutes.grouped(UserAuthenticator())
        restaurantRoutes.post("register", use: restaurantRegister)
        protected.post("nearby", use: getNearbyRestaurants)
        protected.get("all", use: getAllRestaurants)
        protected.get(":id", use: getRestaurantDetails)
        protected.get("me", use: getMyRestaurant)
        protected.put("me", use: updateMyRestaurant)
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
    
    func getRestaurantDetails(req: Request) async throws -> RestaurantDetailDTO {
        //Extraemos el ID del path
        guard let restaurantID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing or invalid restaurant ID.")
        }
        
        //Buscamos el restaurante y cargamos sus platos relacionados
        guard let restaurant = try await Restaurant
            .query(on: req.db)
            .filter(\.$id == restaurantID)
            .with(\.$meals)
            .first()
        else {
            throw Abort(.notFound, reason: "Restaurant not found.")
        }
        
        //Creamos el DTO y lo devolvemos
        return restaurant.toDetailDTO(meals: restaurant.meals)
    }
    
    //Método para que se vea el detalle de restaurante propiedad del usuario restaurante en la pantalla de edición
    func getMyRestaurant(req: Request) async throws -> Restaurant {
        //Verificamos que hay un usuario autenticado
        guard let user = req.auth.get(User.self) else {
            throw Abort(.unauthorized, reason: "User not authenticated.")
        }
        
        //Verificamos que el usuario es un restaurante
        guard user.role == .restaurant else {
            throw Abort(.forbidden, reason: "Only restaurants can access this route.")
        }
        
        //Obtenemos el restaurante vinculado a este usuario
        guard let restaurant = try await user.$restaurant.get(on: req.db) else {
            throw Abort(.notFound, reason: "Restaurant not found for this user.")
        }
        
        return restaurant
    }
    
    //Método para editar la información del restaurante del usuario
    func updateMyRestaurant(req: Request) async throws -> Restaurant {
        //Verifica que hay un usuario autenticado
        guard let user = req.auth.get(User.self) else {
            throw Abort(.unauthorized, reason: "User not authenticated.")
        }

        //Verifica que es un restaurante
        guard user.role == .restaurant else {
            throw Abort(.forbidden, reason: "Only restaurants can update their data.")
        }

        //Busca el restaurante asociado a ese usuario
        guard let restaurant = try await user.$restaurant.get(on: req.db) else {
            throw Abort(.notFound, reason: "Restaurant not found for this user.")
        }

        //Decodifica los nuevos datos
        let data = try req.content.decode(RestaurantUpdateDTO.self)

        //Actualiza los campos del restaurante si hubiese cambios
        if let name = data.name {
            restaurant.name = name
        }
        if let info = data.info {
            restaurant.info = info
        }
        if let address = data.address {
            restaurant.address = address
        }
        if let country = data.country {
            restaurant.country = country
        }
        if let city = data.city {
            restaurant.city = city
        }
        if let zipCode = data.zipCode {
            restaurant.zipCode = zipCode
        }
        if let lat = data.latitude {
            restaurant.latitude = lat
        }
        if let lon = data.longitude {
            restaurant.longitude = lon
        }

        //Si se ha enviado una nueva imagen, la actualizamos
        if let image = try? req.content.get(File.self, at: "photo") {
            let newPhotoURL = try await req.saveImageAndReturnURL(from: "photo")
            restaurant.photo = newPhotoURL
        }

        //Guardamos los cambios
        try await restaurant.save(on: req.db)

        //Devolvemos el restaurante actualizado
        return restaurant
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

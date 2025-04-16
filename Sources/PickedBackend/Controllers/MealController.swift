import Vapor
import Fluent

//MARK: Controlador de la lógica de las funcionalidades de Platos
struct MealController: RouteCollection {
    
    //Método boot en el que se incluyen las rutas de las funcionalidades
    func boot(routes: any RoutesBuilder) throws {
        let mealRoutes = routes.grouped("meals")
        mealRoutes.post("create", use: createMeal)
        mealRoutes.get(":id", use: getMealDetail)
    }
    
    //Método para registrar restaurante en la BBDD
    func createMeal(req: Request) async throws -> Meal {
        //Verificamos que el usuario esté autenticado
        guard let user = req.auth.get(User.self) else {
            throw Abort(.unauthorized, reason: "User not authenticated.")
        }
        
        //Verificamos que el usuario tiene rol de restaurante
        guard user.role == .restaurant else {
            throw Abort(.forbidden, reason: "Only restaurants can create meals.")
        }
        
        //Obtenemos el restaurante vinculado a este usuario
        guard let restaurant = try await user.$restaurant.get(on: req.db) else {
            throw Abort(.notFound, reason: "Restaurant not found for this user.")
        }

        //Decodificamos el DTO con los datos del nuevo plato
        let data = try req.content.decode(MealDTO.self)
        
        //Usamos el método de manejo de imagenes
        let photoURL = try await req.saveImageAndReturnURL(from: "photo")

        //Creamos la entidad del plato
        let meal = Meal(
            name: data.name,
            info: data.info,
            photo: photoURL,
            price: data.price,
            units: data.units,
            type: data.type,
            restaurantID: try restaurant.requireID()
        )

        //Guardamos el plato en la BBDD
        try await meal.save(on: req.db)

        //Devolvemos el plato recién creado (puedes devolver un DTO si prefieres)
        return meal
    }
    
    //Método para obtener el detalle de un plato a partir de su ID
    func getMealDetail(req: Request) async throws -> MealDTO {
        //Extraemos el ID del path
        guard let mealID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing or invalid meal ID.")
        }

        //Buscamos el plato en la BBDD
        guard let meal = try await Meal.find(mealID, on: req.db) else {
            throw Abort(.notFound, reason: "Meal not found.")
        }

        //Devolvemos los datos como DTO
        return MealDTO(
            name: meal.name,
            info: meal.info,
            price: meal.price,
            units: meal.units,
            type: meal.type
        )
    }
}

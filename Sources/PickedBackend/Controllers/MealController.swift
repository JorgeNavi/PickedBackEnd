import Vapor
import Fluent

//MARK: Controlador de la lógica de las funcionalidades de Platos
struct MealController: RouteCollection {
    
    //Método boot en el que se incluyen las rutas de las funcionalidades
    func boot(routes: any RoutesBuilder) throws {
        let mealRoutes = routes.grouped("meals")
        mealRoutes.post("create", use: createMeal)
        mealRoutes.get(":id", use: getMealDetail)
        mealRoutes.put("edit", ":id", use: updateMeal)
        mealRoutes.delete("delete", ":id", use: deleteMeal)
        mealRoutes.get("mine", use: getMyMeals)
    }
    
    //Método para registrar plato en la BBDD
    func createMeal(req: Request) async throws -> Meal {
        
        //Obtenemos el restaurante que tiene el plato
        let restaurant = try await req.authenticatedRestaurant()

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
        
        //Informamos del id de quien a creado el plato (auditoría)
        meal.$creator.id = try req.authenticatedUserID()

        //Guardamos el plato en la BBDD
        try await meal.save(on: req.db)

        return meal
    }
    
    //Método para obtener el detalle de un plato a partir de su ID
    func getMealDetail(req: Request) async throws -> MealDTO {
        
        //Extraemos el ID
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
    
    //Método para editar un plato
    func updateMeal(req: Request) async throws -> Meal {

        //Obtenemos el restaurante que tiene el plato
        let restaurant = try await req.authenticatedRestaurant()

        //Obtenemos el ID del plato a editar
        guard let mealID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing meal ID.")
        }

        //Buscamos el plato y comprobamos que pertenece a este restaurante
        guard let meal = try await Meal
            .query(on: req.db)
            .filter(\.$id == mealID)
            .filter(\.$restaurant.$id == restaurant.requireID())
            .first()
        else {
            throw Abort(.notFound, reason: "Meal not found or does not belong to your restaurant.")
        }

        //Decodificamos los nuevos datos
        let updateData = try req.content.decode(MealUpdateDTO.self)
        
        //Aplicamos el método de actualización de los campos de meal
        meal.applyUpdate(from: updateData)
        
        //Informamos del id de quien a editado el plato (auditoría)
        meal.$editor.id = try req.authenticatedUserID()

        //Verificamos si se ha enviado una nueva imagen
        if (try? req.content.get(File.self, at: "photo")) != nil {
            let newPhotoURL = try await req.saveImageAndReturnURL(from: "photo")
            meal.photo = newPhotoURL
        }

        //Guardamos los cambios
        try await meal.save(on: req.db)

        return meal
    }
    
    //Método para eliminar un plato
    func deleteMeal(req: Request) async throws -> HTTPStatus {
        
        //Obtenemos el restaurante que tiene el plato
        let restaurant = try await req.authenticatedRestaurant()

        //Obtenemos el ID del plato a eliminar
        guard let mealID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing meal ID.")
        }

        //Buscamos el plato y comprobamos que pertenece a este restaurante
        guard let meal = try await Meal
            .query(on: req.db)
            .filter(\.$id == mealID)
            .filter(\.$restaurant.$id == restaurant.requireID())
            .first()
        else {
            throw Abort(.notFound, reason: "Meal not found or does not belong to your restaurant.")
        }
        
        //Comprobamos si el plato tiene foto y la eliminamos
        try req.deleteImageIfExists(at: meal.photo)

        //Eliminamos el plato
        try await meal.delete(on: req.db)

        //Devolvemos que no hay contenido
        return .noContent
    }
    
    func getMyMeals(req: Request) async throws -> [MealRestaurantDTO] {
        
        //Obtenemos el restaurante
        let restaurant = try await req.authenticatedRestaurant()
        
        //Obtenemos todos los platos de ese restaurante
        let meals = try await Meal
            .query(on: req.db)
            .filter(\.$restaurant.$id == restaurant.requireID())
            .all()

        //Mapeamos al DTO
        return try meals.map { meal in
            MealRestaurantDTO(
                id: try meal.requireID(),
                name: meal.name,
                units: meal.units,
                price: meal.price,
                photo: meal.photo
            )
        }
    }
}

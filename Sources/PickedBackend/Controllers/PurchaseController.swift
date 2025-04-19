import Vapor
import Fluent

//MARK: Controlador de la lógica de las funcionalidades de Compras
struct PurchaseController: RouteCollection {
    
    //Método boot en el que se incluyen las rutas de las funcionalidades
    func boot(routes: any RoutesBuilder) throws {
        let purchaseRoutes = routes.grouped("purchases")
        purchaseRoutes.post("create", use: createPurchase)
        purchaseRoutes.get("me", use: getMySales)
        purchaseRoutes.patch("cancel", ":id", use: cancelPurchase)
    }
    
    //Método para registrar plato en la BBDD
    func createPurchase(req: Request) async throws -> PurchaseResponseDTO {
        
        //Verificamos que el usuario este autenticado y sea consumidor
        let consumer = try await req.authenticatedConsumer()
        
        //Decodificamos el DTO de compra que nos llega
        let data = try req.content.decode(PurchaseCreateDto.self)
        
        //Buscamos el plato que quiere ser comprado
        guard let meal = try await Meal
            .query(on: req.db)
            .filter(\.$id == data.mealId)
            .first()
        else {
            throw Abort(.notFound, reason: "Meal not found.")
        }
        
        //Verificamos que haya suficientes unidades del plato disponibles
        guard meal.units >= data.quantity else {
            throw Abort(.badRequest, reason: "Not enough units available.")
        }
        
        //Restamos las unidades compradas al plato
        meal.units -= data.quantity
        
        //guardamos los cambios en el plato
        try await meal.save(on: req.db)
        
        //Creamos el registro de la compra
        let purchase = Purchase(
            consumerID: try consumer.requireID(),
            mealID: try meal.requireID(),
            quantity: data.quantity
        )
        
        print("Compra registrada:", purchase.createdAt ?? Date())
        
        //Informamos del id de quien a creado la compra (auditoría)
        purchase.$creator.id = try consumer.requireID()
        
        //Guardamos la compra en BBDD
        try await purchase.save(on: req.db)
        
        //Devolvemos el DTO de respuesta
        return PurchaseResponseDTO(
            id: try purchase.requireID(),
            mealName: meal.name,
            quantity: data.quantity
        )
    }
    
    //Método que devuelve las compras de un plato de restaurante
    func getMySales(req: Request) async throws -> [RestaurantPurchaseDTO] {
        
        //Obtenemos el restaurante
        let restaurant = try await req.authenticatedRestaurant()

        //Buscamos las compras que correspondan a platos de ese restaurante
        let purchases = try await Purchase
            .query(on: req.db)
            .join(parent: \Purchase.$meal)
            .join(parent: \Purchase.$consumer)
            .filter(Meal.self, \.$restaurant.$id == restaurant.requireID())
            .with(\.$meal)
            .with(\.$consumer)
            .all()

        //Mapeamos al DTO
        return purchases.map { purchase in
            RestaurantPurchaseDTO(
                mealName: purchase.meal.name,
                consumerName: purchase.consumer.name,
                quantity: purchase.quantity,
                date: purchase.createdAt ?? Date()
            )
        }
    }
    
    //Método para cancelar una compra
    func cancelPurchase(req: Request) async throws -> HTTPStatus {
        
        //Verificamos que el usuario esté autenticado y sea consumidor
        let consumer = try await req.authenticatedConsumer()

        //Obtenemos el ID de la compra desde el path
        guard let purchaseID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing or invalid purchase ID.")
        }

        //Buscamos la compra y nos aseguramos de que sea del consumidor autenticado
        guard let purchase = try await Purchase
            .query(on: req.db)
            .filter(\.$id == purchaseID)
            .filter(\.$consumer.$id == consumer.requireID())
            .with(\.$meal)
            .first()
        else {
            throw Abort(.notFound, reason: "Purchase not found or does not belong to the user.")
        }

        //Verificamos que no esté ya cancelada
        guard !purchase.isCanceled else {
            throw Abort(.badRequest, reason: "Purchase is already canceled.")
        }

        //Sumamos de nuevo las unidades al plato
        purchase.meal.units += purchase.quantity
        try await purchase.meal.save(on: req.db)

        //Marcamos la compra como cancelada
        purchase.isCanceled = true
        
        debugPrint("Cancel status:", purchase.isCanceled)

        //Informamos del id de quien a cancelado la compra (auditoría)
        purchase.$editor.id = try consumer.requireID()
        
        debugPrint("Antes de guardar, isCanceled =", purchase.isCanceled)

        //Guardamos los cambios
        try await purchase.save(on: req.db)
        
        debugPrint("Guardado en BBDD")
        
        debugPrint("Compra cancelada:", try purchase.requireID())
        
        return .ok
    }
}

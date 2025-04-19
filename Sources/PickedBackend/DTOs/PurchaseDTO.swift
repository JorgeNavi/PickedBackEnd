import Vapor


//MARK: DTO para registrar una nueva compra
struct PurchaseCreateDto: Content {
    let mealId: UUID
    let quantity: Int
}

//MARK: DTO de respuesta tras la realización de una compra
struct PurchaseResponseDTO: Content {
    let id: UUID
    let mealName: String
    let quantity: Int
}

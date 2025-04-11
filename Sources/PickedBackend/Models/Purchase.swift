import Fluent
import Vapor

//MARK: Modelo de Purchase con sus atributos para la BBDD. Este modelo de tabla va a servir para persistir las compras de los usuarios e informar al restaurante de cuando sus platos han sido vendidos/reservados
final class Purchase: Model, Content, @unchecked Sendable {
    
    static let schema = "purchases"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "consumer_id")
    var consumer: User
    
    @Parent(key: "meal_id")
    var meal: Meal
    
    @Field(key: "quantity")
    var quantity: Int
    
    @Field(key: "is_canceled")
    var isCanceled: Bool
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init() {}
    
    init(id: UUID? = nil, consumerID: UUID, mealID: UUID, quantity: Int, isCanceled: Bool = false) {
        self.id = id
        self.$consumer.id = consumerID
        self.$meal.id = mealID
        self.quantity = quantity
        self.isCanceled = isCanceled
    }
    
}

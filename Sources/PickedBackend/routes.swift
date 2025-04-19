import Fluent
import Vapor

//MARK: Clase que establece las rutas del proyecto
func routes(_ app: Application) throws {
app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }
    
    let protected = app.grouped(UserAuthenticator())
    
    let userController = UserController()
    try app.register(collection: userController)

    let restaurantController = RestaurantController()
    try app.register(collection: restaurantController)
    
    let mealController = MealController()
    try protected.register(collection: mealController)
    
    let purchaseController = PurchaseController()
    try protected.register(collection: purchaseController)

}

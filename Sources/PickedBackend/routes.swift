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
    
    let userController = UserController()
    try app.register(collection: userController)

    let restaurantController = RestaurantController()
    try app.register(collection: restaurantController)

    //try app.register(collection: TodoController())
}

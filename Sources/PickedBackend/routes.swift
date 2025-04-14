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
    app.post("register-consumer", use: userController.consumerRegister)
    app.post("login", use: userController.login)
    
    let restaurantController = RestaurantController()
    app.post("register-restaurant", use: restaurantController.restaurantRegister)

    //try app.register(collection: TodoController())
}

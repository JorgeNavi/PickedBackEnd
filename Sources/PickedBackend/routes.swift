import Fluent
import Vapor

func routes(_ app: Application) throws {
app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }
    
    let userController = UserController()
    app.post("register", use: userController.register)
    app.post("login", use: userController.login)

    //try app.register(collection: TodoController())
}

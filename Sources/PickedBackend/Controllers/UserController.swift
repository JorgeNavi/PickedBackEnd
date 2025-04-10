import Vapor
import Fluent

struct UserController: RouteCollection { //RouteCollection sirve para agrupar las rutas de peticiones de la API
    
    //el método boot es el que va a ser llamado por Vapor para las rutas. Aqui es donde se establecen las diferentes rutas
    func boot(routes: any RoutesBuilder) throws {
        routes.post("register", use: register) //En este caso, la ruta es un método POST a /register y que use para ello, el método register hecho debajo
    }

    func register(req: Request) async throws -> User { //recibe una request y devuelve un usuario
        let userData = try req.content.decode(UserRegisterDTO.self) //se convierte el JSOn que llega en la petición a una instancia de UserRegisterDTO. Si falta algo obligatorio o hay un tipo erróneo, Vapor lanzará automáticamente un Bad Request.
        
        // Validación de email duplicado
        if try await User.query(on: req.db) //Crea una consulta (query) a BBDD. Equivalente en SQL: SELECT * FROM users
            .filter(\.$email == userData.email) //se filtra que email sea equivalente a userData.email que es el que llega en el register
            .first() != nil { //Si existe un email en esa busqueda, se lanza el error consiguiente
            throw Abort(.conflict, reason: "Email ya registrado")
        }

        // Hash de la contraseña
        let passwordHash = try Bcrypt.hash(userData.password)

        // Crear y guardar usuario
        let user = User(
            name: userData.name,
            email: userData.email,
            password: passwordHash,
            role: userData.role
        )

        try await user.save(on: req.db)
        return user
    }
}

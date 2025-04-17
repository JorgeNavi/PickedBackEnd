import Vapor
import Fluent

extension Request {
    
    //MARK: Método que gestiona la autenticación de usuario
    func authenticatedUser() throws -> User {
        
        guard let user = self.auth.get(User.self) else {
            throw Abort(.unauthorized, reason: "User not authenticated.")
        }
        return user
    }
    
    //MARK: Método que gestiona la autenticación de usuario y devuelve su ID
    func authenticatedUserID() throws -> UUID {
        
        let user = try self.authenticatedUser()
        return try user.requireID()
    }
    
    //MARK: Método que guarda una imagen recibida en formato multipart/form-data, valida su tipo, la guarda en disco y devuelve su URL pública como String
    func saveImageAndReturnURL(from field: String) async throws -> String {
        
        //Extraemos el archivo del campo indicado
        guard let imagePart = try? self.content.get(File.self, at: field) else {
            throw Abort(.badRequest, reason: "Missing image file in field '\(field)'")
        }

        //Verificamos la extensión del archivo
        let validExtensions = ["jpg", "jpeg", "png"]
        let fileExtension = imagePart.extension?.lowercased() ?? ""

        guard validExtensions.contains(fileExtension) else {
            throw Abort(.unsupportedMediaType, reason: "Only .jpg, .jpeg or .png images are allowed")
        }

        //Creamos un nombre único para evitar colisiones
        let filename = "\(UUID().uuidString).\(fileExtension)"

        //Definimos la ruta de guardado
        let folder = "Public/restaurant_photos"
        let path = self.application.directory.workingDirectory + folder
        let fullPath = path + "/" + filename

        //Nos aseguramos de que la carpeta existe
        try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
        
        //Convertimos ByteBuffer a Data
        let data = imagePart.data.getData(at: imagePart.data.readerIndex, length: imagePart.data.readableBytes) ?? Data()

        //Guardamos el archivo en el disco
        try await self.fileio.writeFile(.init(data: data), at: fullPath)

        //Devolvemos la URL pública
        return "/restaurant_photos/\(filename)"
    }
    
    //MARK: Método que se encarga de comprobar que el usuario está registrado, que tiene rol de restaurante y recibe el restaurante vinculado
    func authenticatedRestaurant() async throws -> Restaurant {
        
        //Verificamos que el usuario esté autenticado
        let user = try self.authenticatedUser()

        //Verificamos que el usuario tiene rol de restaurante
        guard user.role == .restaurant else {
            throw Abort(.forbidden, reason: "Only restaurants can access this resource.")
        }

        //Obtenemos el restaurante vinculado a este usuario
        guard let restaurant = try await user.$restaurant.get(on: self.db) else {
            throw Abort(.notFound, reason: "Restaurant not found for this user.")
        }

        return restaurant
    }
    
    // MARK: Método para eliminar las fotos de Meal y Restaurant cuando estos son eliminados
    func deleteImageIfExists(at path: String) throws {
           let fullPath = self.application.directory.workingDirectory + "Public" + path
           if FileManager.default.fileExists(atPath: fullPath) {
               try FileManager.default.removeItem(atPath: fullPath)
           }
       }
}

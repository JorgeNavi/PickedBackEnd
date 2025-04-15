import Vapor
import Fluent

// MARK: Método que guarda una imagen recibida en formato multipart/form-data, valida su tipo, la guarda en disco y devuelve su URL pública como String
extension Request {
    
    func saveImageAndReturnURL(from field: String) async throws -> String {
        //Extraemos el archivo del campo indicado (ej: "photo")
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

        //Guardamos el archivo en el disco
        try await self.fileio.writeFile(.init(data: imagePart.data), at: fullPath)

        //Devolvemos la URL pública (asumiendo que el folder "Public" está expuesto por Vapor)
        return "/restaurant_photos/\(filename)"
    }
}

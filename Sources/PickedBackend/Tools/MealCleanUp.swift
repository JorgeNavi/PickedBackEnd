import Vapor
import Fluent

//MARK: struct pensado como herramienta para que haga un borrado de meals que fueron creados hace más de 24 horas
struct MealCleanUp {
    static func start(on app: Application) {
        
        //establecemos un evento en bucle que se lanzará 5 segundos después de arrancar el servidor y se repite cada hora
        app.eventLoopGroup.next().scheduleRepeatedTask(initialDelay: .seconds(5), delay: .hours(1)) { task in
            //En ese bucle hacemos:
            Task {
                do {
                    //Instanciamos la BBDD, la hora actual y establecemos una variable con 24 horas antes
                    let db = app.db
                    let now = Date()
                    let cutoff = now.addingTimeInterval(-60 * 60 * 24)

                    //le decimos que elimine Meal desde la BBDD con el filtro de las 24 horas antes de "now"
                    try await Meal
                        .query(on: db)
                        .filter(\.$createdAt < cutoff)
                        .delete()

                    app.logger.info("Deleted expired meals.")
                    
                //Capturamos posibles errores
                } catch {
                    app.logger.error("Meal cleanup failed: \(error)")
                }
            }
        }
    }
}

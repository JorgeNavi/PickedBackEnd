import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor
import JWT

//MARK: clase de configuración del proyecto
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    let jwtSecret = Environment.get("JWT_SECRET") ?? "super_default_dev_secret"
    print(jwtSecret)
    app.jwt.signers.use(.hs256(key: jwtSecret))

    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)

    //La orden de llevar a cabo las migraciones a la BBDD y que se creen las tablas
    app.migrations.add(CreateUser())
    app.migrations.add(CreateRestaurant())
    app.migrations.add(CreateMeal())
    app.migrations.add(CreatePurchase())

    //Se ejecutan las migraciones de forma automática si no se hicieron antes
    try await app.autoMigrate()
    //register routes
    try routes(app)
}

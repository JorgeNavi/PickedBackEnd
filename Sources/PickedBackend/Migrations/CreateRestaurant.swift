import Fluent

//MARK: Migración de la tabla "restaurants" a la BBDD
struct CreateRestaurant: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Restaurant.schema)
            .id()
            .field("name", .string, .required)
            .field("info", .string, .required)
            .field("photo", .string, .required)
            .field("country", .string, .required)
            .field("city", .string, .required)
            .field("address", .string, .required)
            .field("zip_code", .string, .required)
            .field("longitude", .double, .required)
            .field("latitude", .double, .required)
            .field("created_at", .date)
            .field("updated_at", .date)
            .field("created_by", .uuid, .references("users", "id"))
            .field("updated_by", .uuid, .references("users", "id"))
            .field("user_id", .uuid, .required, .references("users", "id"))
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Restaurant.schema).delete()
    }
}

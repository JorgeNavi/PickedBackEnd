import Fluent

//MARK: Migración de la tabla "meals" a la BBDD
struct CreateMeal: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Meal.schema)
            .id()
            .field("name", .string, .required)
            .field("info", .string, .required)
            .field("photo", .string, .required)
            .field("price", .float, .required)
            .field("units", .int, .required)
            .field("food_type", .string, .required)
            .field("created_at", .date)
            .field("updated_at", .date)
            .field("created_by", .uuid, .references("users", "id"))
            .field("updated_by", .uuid, .references("users", "id"))
            .field("restaurant_id", .uuid, .required, .references("restaurants", "id"))
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Meal.schema).delete()
    }
}

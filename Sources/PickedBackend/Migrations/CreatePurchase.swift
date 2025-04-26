import Fluent

//MARK: Migración de la tabla "purchases" a la BBDD
struct CreatePurchase: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Purchase.schema)
            .id()
            .field("consumer_id", .uuid, .required, .references("users", "id"))
            .field("meal_id", .uuid, .required, .references("meals", "id", onDelete: .cascade))
            .field("quantity", .int, .required)
            .field("is_canceled", .bool, .required, .sql(.default(false)))
            .field("created_at", .date)
            .field("created_by", .uuid, .references("users", "id"))
            .field("updated_by", .uuid, .references("users", "id"))
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Purchase.schema).delete()
    }
}

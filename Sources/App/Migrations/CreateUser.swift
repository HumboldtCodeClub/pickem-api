import Fluent

/// Migration to create the `user` table in the database.
/// This migration defines the schema for the `user` table, including its fields and constraints.
struct CreateUser: AsyncMigration {

  /// The name of the migration, useful for tracking and debugging.
  var name: String { "user.create" }

  /// Prepares the migration by creating the `user` table with the specified schema.
  /// - Parameter database: The database on which to perform the migration.
  /// - Throws: An error if the schema creation fails.
  func prepare(on database: Database) async throws {
    try await database.schema("user")
      // Define the fields of the `user` table.
      .field("id", .int, .identifier(auto: true)) // Auto-incrementing primary key.
      .field("username", .sql(unsafeRaw: "VARCHAR(32)"), .required) // Username, required and limited to 32 characters.
      .field("password", .string, .required) // Hashed password, required.
      .field("password_exp_date", .datetime, .required) // Password expiration date, required.
      .field("admin_yn", .bool, .required) // Indicates if the user has admin privileges, required.
      .field("create_date", .datetime) // Timestamp when the record was created.
      .field("update_date", .datetime) // Timestamp when the record was last updated.
      .field("delete_date", .datetime) // Timestamp when the record was deleted (soft delete).
      // Define constraints on the `user` table.
      .unique(on: "username") // Ensure usernames are unique.
      // Create the table in the database.
      .create()
  }

  /// Reverts the migration by deleting the `user` table.
  /// - Parameter database: The database on which to perform the revert operation.
  /// - Throws: An error if the schema deletion fails.
  func revert(on database: Database) async throws {
    try await database.schema("user").delete()
  }
}

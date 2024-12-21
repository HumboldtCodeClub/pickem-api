import Fluent

struct CreatePickem: AsyncMigration {
  var name: String { "pickem.create" }
  func prepare(on database: Database) async throws {
    try await database.schema("pickem")
      .field("id", .int, .identifier(auto: true))
      .field("user_id", .int, .required, .references("user", "id"))
      .field("game_id", .int, .required, .references("game", "id"))
      .field("team_id", .int, .required, .references("team", "id"))
      .field("tie_breaker_score", .int)
      .field("create_date", .datetime)
      .field("update_date", .datetime)
      .unique(on: "user_id", "game_id")
      .create()
  }

  func revert(on database: Database) async throws {
    try await database.schema("pickem").delete()
  }
}
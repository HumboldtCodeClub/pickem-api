import Fluent

struct CreateGame: AsyncMigration {
  var name: String { "game.create" }
  func prepare(on database: Database) async throws {
    try await database.schema("game")
      .field("id", .int, .identifier(auto: true))
      .field("season", .int, .required)
      .field("week", .int, .required)
      .field("game_type", .string)
      .field("start_time", .datetime, .required)
      .field("home_team_id", .int, .required, .references("team", "id"))
      .field("away_team_id", .int, .required, .references("team", "id"))
      .field("home_score", .int)
      .field("away_score", .int)
      .field("tie_breaker", .bool, .required)
      .field("tie_breaker_order", .int)
      .field("create_date", .datetime)
      .field("update_date", .datetime)
      .create()
  }

  func revert(on database: Database) async throws {
    try await database.schema("team").delete()
  }
}
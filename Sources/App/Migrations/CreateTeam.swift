import Fluent

struct CreateTeam: AsyncMigration {
  var name: String { "team.create" }
  func prepare(on database: Database) async throws {
    try await database.schema("team")
      .field("id", .int, .identifier(auto: true))
      .field("team_city", .sql(unsafeRaw: "VARCHAR(32)"), .required) 
      .field("team_name", .sql(unsafeRaw: "VARCHAR(32)"), .required) 
      .field("team_abbr", .sql(unsafeRaw: "VARCHAR(3)"), .required) 
      .field("create_date", .datetime)
      .field("update_date", .datetime)      
      .unique(on: "team_abbr")
      .create()
  }

  func revert(on database: Database) async throws {
    try await database.schema("team").delete()
  }
}
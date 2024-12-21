import Fluent
import Vapor

final class Pickem: Model, @unchecked Sendable, Content {
  static let schema = "pickem"
  @ID(custom: "id") var id: Int?
  @Parent(key: "user_id") var user: User
  @Parent(key: "game_id") var game: Game
  @Parent(key: "team_id") var team: Team
  @Field(key: "tie_breaker_score") var tieBreakerScore: Int?
  @Timestamp(key: "create_date", on: .create) var created: Date?
  @Timestamp(key: "update_date", on: .update) var updated: Date?

  init() { }

  init(id: Int? = nil, userID: User.IDValue, gameID: Game.IDValue, teamID: Team.IDValue, tieBreakerScore: Int? = nil) {
    self.id = id
    self.$user.id = userID
    self.$game.id = gameID
    self.$team.id = teamID
    self.tieBreakerScore = tieBreakerScore
  }
}
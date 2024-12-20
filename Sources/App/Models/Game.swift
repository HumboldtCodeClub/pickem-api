import Fluent
import Vapor

final class Game: Model, @unchecked Sendable, Content {
  static let schema = "game"
  @ID(custom: "id") var id: Int?
  @Field(key: "season") var season: Int
  @Field(key: "week") var week: Int
  @Field(key: "game_type") var gameType: String?
  @Field(key: "start_time") var start: Date?
  @Parent(key: "home_team_id") var homeTeam: Team
  @Parent(key: "away_team_id") var awayTeam: Team
  @Field(key: "home_score") var homeScore: Int?
  @Field(key: "away_score") var awayScore: Int?
  @Field(key: "tie_breaker") var tieBreaker: Bool
  @Field(key: "tie_breaker_order") var tieBreakerOrder: Int?
  @Timestamp(key: "create_date", on: .create) var created: Date?
  @Timestamp(key: "update_date", on: .update) var updated: Date?

  init() {}

  init(id: Int? = nil, season: Int, week: Int, gameType: String? = nil, start: Date, 
        homeTeamID: Team.IDValue, awayTeamID: Team.IDValue, 
        homeScore: Int? = nil, awayScore: Int? = nil,
        tieBreaker: Bool, tieBreakerOrder: Int? = nil) {
    
    self.id = id
    self.season = season
    self.week = week
    self.gameType = gameType ?? "reg"
    self.start = start
    self.$homeTeam.id = homeTeamID
    self.$awayTeam.id = awayTeamID
    self.homeScore = homeScore
    self.awayScore = awayScore
    self.tieBreaker = tieBreaker
    self.tieBreakerOrder = tieBreakerOrder
  }
}

extension Game {
  struct CreateDTO: Content, Validatable {
    let season: Int
    let week: Int 
    let gameType: String?
    let start: String
    let homeTeam: String
    let awayTeam: String
    let homeScore: Int?
    let awayScore: Int?
    let tieBreaker: Bool?
    let tieBreakerOrder: Int?

    static func validations(_ validations: inout Validations) { }
  }

  struct UpdateDTO: Content, Validatable {
    let homeScore: Int
    let awayScore: Int
    let tieBreaker: Bool?
    let tieBreakerOrder: Int?

    static func validations(_ validations: inout Validations) { }
  }
}
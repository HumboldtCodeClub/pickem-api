import Fluent
import Vapor

/// Request Objects

extension Pickem {
  struct CreateDTO: Content, Validatable {
    let userID: Int
    let gameID: Int
    let teamID: Int
    let score: Int?

    static func validations(_ validations: inout Validations) { }

    func toModel() -> Pickem {
      Pickem(userID: userID, gameID: gameID, teamID: teamID, tieBreakerScore: score)
    }
  }

  struct UpdateDTO: Content {
    let teamID: Int?
    let score: Int?
  }
}

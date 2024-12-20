import Fluent
import Vapor

struct GameController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let games = routes.grouped("games")
    games.get(use: self.findGames)
    games.post(use: self.createGame)
    games.post("search", use: self.searchGames)
    games.group(":gameID") { game in
      game.get(use: self.findGame)
    }
  }

  @Sendable
  func findGames(req: Request) async throws -> [Game] {
    let games = try await Game.query(on: req.db)
      .with(\.$homeTeam)
      .with(\.$awayTeam)
      .all()
    return games
  }

  @Sendable
  func findGame(req: Request) async throws -> Game {
    guard let game = try await Game.find(req.parameters.get("gameID"), on: req.db) else {
      throw Abort(.notFound)
    }
    return game
  }

  @Sendable
  func createGame(req: Request) async throws -> Game {
    // Validate the incoming request content against Game.CreateDTO validation rules
    do {
      try Game.CreateDTO.validate(content: req)
    } catch {
      // If validation fails, return a 400 Bad Request response
      throw Abort(.badRequest)
    }
    // Decode the validated request content into a Game.CreateDTO object
    let dto = try req.content.decode(Game.CreateDTO.self)
    // Get the home and away teams using their abbr
    guard let homeTeamID = try await Team.query(on: req.db).filter(\.$abbr == dto.homeTeam).first()?.id else {
      throw Abort(.notFound)
    }
    guard let awayTeamID = try await Team.query(on: req.db).filter(\.$abbr == dto.awayTeam).first()?.id else {
      throw Abort(.notFound)
    }
    let dF = DateFormatter()
    dF.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let startDate = dF.date(from: dto.start) ?? Date()
    // Create a new Game object using the values from the CreateDTO
    let game = Game(season: dto.season, week: dto.week, gameType: dto.gameType, start: startDate,
                    homeTeamID: homeTeamID, awayTeamID: awayTeamID,
                    homeScore: dto.homeScore, awayScore: dto.awayScore,
                    tieBreaker: dto.tieBreaker ?? false, tieBreakerOrder: dto.tieBreakerOrder)

    do {
      try await game.create(on: req.db)
      return game
    } catch {
      throw Abort(.internalServerError)
    }
  }

  @Sendable
  func searchGames(req: Request) async throws -> HTTPStatus {
    return .imATeapot
  }
}
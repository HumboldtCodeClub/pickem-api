import Fluent
import Vapor

struct TeamController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let teams = routes.grouped("teams")
    teams.get(use: self.findTeams)
    teams.post(use: self.createTeam)
    teams.group(":teamID") { team in
      team.get(use: self.findTeam)
    }
  }

  @Sendable
  func findTeams(req: Request) async throws -> [Team.Public] {
    let teams = try await Team.query(on: req.db).all()
    return teams.convertToPublic()
  }

  @Sendable
  func findTeam(req: Request) async throws -> Team.Public {
    guard let team = try await Team.find(req.parameters.get("teamID"), on: req.db) else {
      throw Abort(.notFound)
    }
    return team.convertToPublic()
  }

  @Sendable
  func createTeam(req: Request) async throws -> Team.Public {
    do {
      try Team.DTO.validate(content: req)
    } catch {
      throw Abort(.badRequest)
    }

    let dto = try req.content.decode(Team.DTO.self)

    if let _ = try await Team.query(on: req.db).filter(\.$abbr == dto.abbr).first() {
      throw Abort(.badRequest)
    }

    let team = Team(city: dto.city, name: dto.name, abbr: dto.abbr)
    do {
      try await team.create(on: req.db)
      return team.convertToPublic()
    } catch let sqlError as DatabaseError {
      throw Abort(.badRequest, reason: "Database error:")
    } catch {
      throw Abort(.internalServerError, reason: "An unexpected error occurred.")
    }
  }
}
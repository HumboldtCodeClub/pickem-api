import Fluent
import Vapor

struct PickemController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let picks = routes.grouped("picks")
    picks.get(use: self.findPicks)
    picks.post(use: self.createPick)
    picks.group(":pickID") { pick in
      pick.get(use: self.findPick)
    }
  }

  @Sendable
  func findPicks(req: Request) async throws -> [Pickem] {
    let picks = try await Pickem.query(on: req.db).all()
    return picks
  }

  @Sendable
  func findPick(req: Request) async throws -> Pickem {
    guard let pick = try await Pickem.find(req.parameters.get("pickID"), on: req.db) else {
      throw Abort(.notFound)
    }
    return pick
  }

  @Sendable
  func createPick(req: Request) async throws -> Pickem {
    do {
      try Pickem.CreateDTO.validate(content: req)
    } catch {
      throw Abort(.badRequest)
    }

    let dto = try req.content.decode(Pickem.CreateDTO.self)
    let pick = dto.toModel();

    do {
      try await pick.create(on: req.db)
      return pick
    } catch let sqlError as DatabaseError {  
      throw Abort(.badRequest, reason: "Database error:")
    } catch {
      throw Abort(.internalServerError, reason: "An unexpected error occurred.")
    }
    
  }
}
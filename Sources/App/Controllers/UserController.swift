import Fluent
import Vapor

/// Controller for managing `User` resources.
/// Provides endpoints for creating, reading, updating, deleting, and restoring users.
struct UserController: RouteCollection {

  /// Registers the routes for user-related operations.
  /// - Parameter routes: The `RoutesBuilder` to register the routes on.
  /// - Throws: An error if route registration fails.
  func boot(routes: RoutesBuilder) throws {
    let users = routes.grouped("users")
    users.get(use: findUsers) // GET /users
    users.get(":userID", use: findUser) // GET /users/:userID
    users.post(use: createUser) // POST /users
    users.patch(":userID", use: updateUser) // PATCH /users/:userID
    users.delete(":userID", use: deleteUser) // DELETE /users/:userID
    users.get(":userID", "restore", use: restoreUser) // GET /users/:userID/restore
  }

  /// Fetches all users and returns their public representation.
  /// - Parameter req: The incoming request.
  /// - Returns: An array of `User.Public` objects.
  @Sendable
  func findUsers(req: Request) async throws -> [User.Public] {
    let users = try await User.query(on: req.db).all()
    return users.convertToPublic()
  }

  /// Fetches a specific user by their ID and returns their public representation.
  /// - Parameter req: The incoming request.
  /// - Returns: A `User.Public` object.
  /// - Throws: A `notFound` error if the user does not exist.
  @Sendable
  func findUser(req: Request) async throws -> User.Public {
    guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
      throw Abort(.notFound)
    }
    return user.convertToPublic()
  }

  /// Creates a new user.
  /// - Parameter req: The incoming request containing the user data.
  /// - Returns: The created user's public representation.
  /// - Throws: A `badRequest` error if validation fails or a user with the same username exists.
  @Sendable
  func createUser(req: Request) async throws -> User.Public {
    do {
      try User.DTO.validate(content: req)
    } catch {
      throw Abort(.badRequest)
    }

    let dto = try req.content.decode(User.DTO.self)

    if let _ = try await User.query(on: req.db).withDeleted().filter(\.$username == dto.username).first() {
      throw Abort(.badRequest)
    }

    let user = User(username: dto.username)
    do {
      try await user.create(on: req.db)
      return user.convertToPublic()
    } catch {
      throw Abort(.internalServerError)
    }
  }

  /// Updates a user's information.
  /// - Parameter req: The incoming request containing the updated user data.
  /// - Returns: The updated user's public representation.
  /// - Throws: A `badRequest` error if validation fails or a `notFound` error if the user does not exist.
  @Sendable
  func updateUser(req: Request) async throws -> User.Public {
    var changesDetected = false

    do {
      try User.DTO.validate(content: req)
    } catch {
      throw Abort(.badRequest)
    }

    let dto = try req.content.decode(User.DTO.self)
    guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
      throw Abort(.notFound)
    }

    if dto.username != user.username {
      if try await User.query(on: req.db).withDeleted().filter(\.$username == dto.username).first() != nil {
        throw Abort(.badRequest)
      }
      user.username = dto.username
      changesDetected = true
    }

    guard changesDetected else {
      throw Abort(.imATeapot)
    }

    try await user.update(on: req.db)
    return user.convertToPublic()
  }

  /// Deletes a user.
  /// - Parameter req: The incoming request.
  /// - Returns: An HTTP status indicating the outcome.
  /// - Throws: A `notFound` error if the user does not exist.
  @Sendable
  func deleteUser(req: Request) async throws -> HTTPStatus {
    guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
      throw Abort(.notFound)
    }

    try await user.delete(on: req.db)
    return .noContent
  }

  /// Restores a soft-deleted user.
  /// - Parameter req: The incoming request.
  /// - Returns: An HTTP status indicating the outcome.
  /// - Throws: A `notFound` error if the user does not exist or is not deleted.
  @Sendable
  func restoreUser(req: Request) async throws -> HTTPStatus {
    guard let user = try await User.query(on: req.db).withDeleted().filter(\.$id == req.parameters.get("userID")!).first() else {
      throw Abort(.notFound)
    }

    guard user.deleted != nil else {
      throw Abort(.notFound)
    }

    try await user.restore(on: req.db)
    return .ok
  }
}

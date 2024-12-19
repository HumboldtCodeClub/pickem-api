import Fluent
import Vapor

/// Represents a user in the system.
/// Conforms to Fluent's `Model` protocol for database interactions and Vapor's `Sendable`.
final class User: Model, @unchecked Sendable {
  // MARK: - Schema

  /// The schema name for the database table.
  static let schema = "user"

  // MARK: - Properties

  /// The unique identifier for the user.
  @ID(custom: "id") var id: Int?

  /// The username of the user.
  @Field(key: "username") var username: String

  /// The hashed password of the user.
  @Field(key: "password") var password: String

  /// The expiration date for the user's password.
  @Field(key: "password_exp_date") var passwordExpires: Date

  /// Whether the user has administrative privileges.
  @Field(key: "admin_yn") var admin: Bool

  /// The date when the user record was created.
  @Timestamp(key: "create_date", on: .create) var created: Date?

  /// The date when the user record was last updated.
  @Timestamp(key: "update_date", on: .update) var updated: Date?

  /// The date when the user record was deleted.
  @Timestamp(key: "delete_date", on: .delete) var deleted: Date?

  // MARK: - Initializers

  /// Default initializer for Fluent.
  init() {}

  /// Custom initializer to create a new user.
  /// - Parameters:
  ///   - id: The unique identifier for the user (optional).
  ///   - username: The username of the user.
  init(id: Int? = nil, username: String) {
    self.id = id
    self.username = username
    self.password = randomPassword()
    self.passwordExpires = Date().addingTimeInterval(60 * 60 * 24 * 90) // 90 days from now.
    self.admin = false
  }
}

// MARK: - Authentication

extension User: ModelAuthenticatable {
  /// The key for the username field in the database.
  static let usernameKey = \User.$username

  /// The key for the password hash field in the database.
  static let passwordHashKey = \User.$password

  /// Verifies the given password against the stored hash.
  /// - Parameter password: The password to verify.
  /// - Throws: An error if the password does not match.
  /// - Returns: A boolean indicating whether the password is correct.
  func verify(password: String) throws -> Bool {
    try Bcrypt.verify(password, created: self.password)
  }
}

// MARK: - Public Representation

extension User {
  /// A public representation of the `User` object.
  /// Conforms to `Content` and `Sendable`.
  struct Public: Content, Sendable {
    /// The unique identifier for the user.
    var id: Int?

    /// The username of the user.
    var username: String

    /// Public initializer.
    /// - Parameters:
    ///   - id: The unique identifier for the user (optional).
    ///   - username: The username of the user.
    init(id: Int?, username: String) {
      self.id = id
      self.username = username
    }
  }

  /// Converts the current user to its public representation.
  /// - Returns: A `User.Public` object.
  func convertToPublic() -> User.Public {
    User.Public(id: id, username: username)
  }
}

// MARK: - Collection Extension

extension Collection where Element: User {
  /// Converts a collection of `User` objects to their public representations.
  /// - Returns: An array of `User.Public` objects.
  func convertToPublic() -> [User.Public] {
    self.map { $0.convertToPublic() }
  }
}

// MARK: - Utility Functions

/// Generates a random password.
/// - Returns: A randomly generated string password.
func randomPassword() -> String {
  enum s {
    /// The character set used to generate passwords.
    static let c = Array("abcdefghjkmnpqrstuvwxyzABCDEFGHJKMNPQRSTUVWXYZ12345789")
    static let k = UInt32(c.count)
  }

  var result = [Character](repeating: "-", count: 11)

  for i in 0..<11 {
    if i == 3 || i == 7 { continue }
    let r = Int.random(in: 0..<s.c.count)
    result[i] = s.c[r]
  }

  return String(result)
}

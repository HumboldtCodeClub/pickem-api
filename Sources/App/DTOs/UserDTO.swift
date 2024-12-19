import Fluent
import Vapor

/// Extension for the `User` model to include a Data Transfer Object (DTO).
/// The DTO is used to handle user-related data for requests and responses in a validated and structured manner.
extension User {
  /// Represents the Data Transfer Object for the `User` model.
  /// Conforms to `Content` for encoding/decoding and `Validatable` for input validation.
  struct DTO: Content, Validatable {
    /// The username associated with the user.
    let username: String

    /// Defines validation rules for the DTO.
    /// - Parameter validations: The validations object to which rules are added.
    static func validations(_ validations: inout Validations) {
      // Ensures the username is not empty.
      validations.add("username", as: String.self, is: !.empty)
    }
  }
}

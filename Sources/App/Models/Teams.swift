import Fluent
import Vapor

final class Team: Model, @unchecked Sendable {
  static let schema = "team"
  @ID(custom: "id") var id: Int?
  @Field(key: "team_city") var city: String
  @Field(key: "team_name") var name: String
  @Field(key: "team_abbr") var abbr: String
  @Timestamp(key: "create_date", on: .create) var created: Date?
  @Timestamp(key: "update_date", on: .update) var updated: Date?  

  init() {}

  init(id: Int? = nil, city: String, name: String, abbr: String) {
    self.id = id
    self.city = city
    self.name = name
    self.abbr = abbr
  }
}

extension Team {
  struct Public: Content, Sendable {
    var id: Int?
    var city: String
    var name: String
    var abbr: String

    init(id: Int?, city: String, name: String, abbr: String) {
      self.id = id
      self.city = city
      self.name = name
      self.abbr = abbr
    }
  }

  func convertToPublic() -> Team.Public {
    Team.Public(id: id, city: city, name: name, abbr: abbr)
  }
}

extension Collection where Element: Team {
  func convertToPublic() -> [Team.Public] {
    self.map { $0.convertToPublic() }
  }
}

extension Team {
  struct DTO: Content, Validatable {
    let city: String
    let name: String
    let abbr: String

    static func validations(_ validations: inout Validations) {     
      validations.add("city", as: String.self, is: !.empty)
      validations.add("name", as: String.self, is: !.empty)
      validations.add("abbr", as: String.self, is: !.empty)
    }
  }
}
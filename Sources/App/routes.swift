import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    try app.register(collection: TodoController())
    try app.register(collection: UserController())
    try app.register(collection: TeamController())
    try app.register(collection: GameController())
    try app.register(collection: PickemController())
}

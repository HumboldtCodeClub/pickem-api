import NIOSSL
import Fluent
import FluentMySQLDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    
    var tls = TLSConfiguration.makeClientConfiguration()
    tls.certificateVerification = .none

    app.databases.use(DatabaseConfigurationFactory.mysql(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? MySQLConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "pickem_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "pickem_password",
        database: Environment.get("DATABASE_NAME") ?? "pickem_database",
        tlsConfiguration: tls
    ), as: .mysql)

    app.migrations.add(CreateTodo())
    app.migrations.add(CreateUser())
    app.migrations.add(CreateTeam())
    app.migrations.add(CreateGame())
    // register routes
    try routes(app)
}

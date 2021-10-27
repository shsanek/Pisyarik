import App
import Vapor

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
#if canImport(FoundationNetworking)
    app.http.server.configuration.hostname = "176.57.214.20"
#endif
defer { app.shutdown() }
try configure(app)
try app.run()

import App
import Vapor

var env = try Environment.detect()

try LoggingSystem.bootstrap(from: &env)

let app = Application(env)

app.http.server.configuration.shutdownTimeout = .seconds(60)
defer { app.shutdown() }
try configure(app)
try app.run()

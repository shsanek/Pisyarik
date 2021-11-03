import App
import Vapor
import APNS

var env = try Environment.detect()

try LoggingSystem.bootstrap(from: &env)

let app = Application(env)

var basePath = ""

#if os(macOS)
basePath = "/Users/a-shipin/ArrleServer"
#endif

do {
    app.apns.configuration = try .init(
        authenticationMethod: .tls(
            privateKeyPath: basePath + "/ser/newfile.key.pem",
            pemPath: basePath + "/ser/newfile.crt.pem",
            pemPassword: nil
        ),
        topic: "com.urodsk.stroganina",
        environment: .sandbox
    )
}
catch {
    print(error)
}

app.http.server.configuration.shutdownTimeout = .seconds(60)
defer { app.shutdown() }
try configure(app)
try app.run()

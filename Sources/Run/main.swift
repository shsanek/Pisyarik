import App
import Vapor
import APNS
import NIOSSL


DebugeNotificationCenter.setup(token: "", chatID: "")

DebugeNotificationCenter.send("Сервер скомпилирован и запущен")

var env = try Environment.detect()

try LoggingSystem.bootstrap(from: &env)

let app = Application(env)

var basePath = ""

#if os(macOS)
basePath = "/Users/a-shipin/ArrleServer"
#else
basePath = "/arrle/ArrleServer"
#endif

do {
    app.apns.configuration = try .init(
        authenticationMethod: .tls(
            privateKeyPath: basePath + "/ser/newfile.key.pem",
            pemPath: basePath + "/ser/newfile.crt.pem",
            pemPassword: nil
        ),
        topic: "com.urodsk.stroganina",
        environment: .production
    )
} catch {
    DebugeNotificationCenter.send("APNS ERROR: \(error)")
    print("APNS ERROR: \(error)")
}

defer { app.shutdown() }
try configure(app)
try app.run()

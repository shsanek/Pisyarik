import App
import Vapor
import APNS
import NIOSSL

#if !os(macOS)
DebugeNotificationCenter.setup(token: "2113672539:AAFxEFUPQh4QLrP72OKJ7SocRVh7yP0w2oQ", chatID: "-543384352")
#endif

DebugeNotificationCenter.send("Запускаю сервер...")

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
DebugeNotificationCenter.send("Настройкка сервера завершена. Сервер запущен")
try app.run()

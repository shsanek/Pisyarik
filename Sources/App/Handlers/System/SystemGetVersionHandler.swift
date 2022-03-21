import Foundation

struct SystemGetVersionHandler: IRequestHandler {
    
    private let version: Int

    var name: String {
        "system/get_version"
    }

    init(version: Int) {
        self.version = version
    }

    func handle(_ parameters: RequestParameters<EmptyRaw>, dataBase: IDataBase) throws -> FuturePromise<Output> {
        .value(Output(serverApiVersion: version))
    }
}

extension SystemGetVersionHandler {
    struct Output: Encodable {
        let serverApiVersion: Int
    }
}

struct CheckHandler: IRequestHandler {
    var name: String {
        "check"
    }

    func handle(_ parameters: RequestParameters<EmptyRaw>, dataBase: IDataBase) throws -> FuturePromise<Output> {
        dataBase.run(request: DBGetVersionRequest()).first().map { result in
            Output(dbVersion: result.version)
        }
    }
}

extension CheckHandler {
    struct Output: Encodable {
        let version = "1"
        let dbVersion: Int?
    }
}

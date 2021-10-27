import PromiseKit
import Foundation

struct UserLoginHandler: IRequestHandler {    
    var name: String {
        "user/login"
    }

    func handle(_ parameters: RequestParameters<Input>, dataBase: IDataBase) -> Promise<Output> {
        guard parameters.authorisationInfo == nil else {
            return .init(error: UserError.alreadyLogin)
        }
        let uuid = UUID().uuidString
        return dataBase
            .run(request: DBGetUserRequest(name: parameters.input.name))
            .firstValue
            .then { user in
                return dataBase.run(
                    request: DBMakeTokenForUserRequest(
                        token: DBTokenRaw(
                            token: uuid,
                            user_id: user.identifier
                        )
                    )
                )
            }.map { _ in
                return Output(token: uuid)
            }
            
    }
}

extension UserLoginHandler {
    struct Input: Codable {
        let name: String
    }
    
    struct Output: Codable {
        let token: String
    }
}

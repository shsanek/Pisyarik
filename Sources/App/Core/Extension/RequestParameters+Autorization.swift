import PromiseKit

extension RequestParameters {
    var onlyLogin: Promise<Self> {
        Promise.value(self).map { result in
            if result.authorisationInfo == nil {
                throw Errors.accessError.description("Только для авторизированных пользователей")
            }
            return result
        }
    }

    var getUser: Promise<AuthorisationInfo> {
        Promise { resolver in
            guard let info = self.authorisationInfo else {
                throw Errors.accessError.description("Только для авторизированных пользователей")
            }
            resolver.fulfill(info)
        }
    }
}

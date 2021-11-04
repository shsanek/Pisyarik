extension RequestParameters {
    var onlyLogin: FuturePromise<Self> {
        self.getUser.next {
            return .value(self)
        }
    }

    var getUser: FuturePromise<AuthorisationInfo> {
        firstly {
            .value(self)
        }.map { value -> AuthorisationInfo in
            guard let result = value.authorisationInfo else {
                throw Errors.accessError.description("Только для авторизированных пользователей")
            }
            return result
        }
    }
}

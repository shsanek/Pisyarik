import Vapor

protocol IUpdateAction {
    func generateUpdaters(_ dataBase: IDataBase) -> FuturePromise<[InformationUpdater]>
}

import RealmSwift
import Foundation

extension Container {

    public func write(_ block: (WriteTransaction) throws -> Void) throws {
        let wrapper = try self.wrapper()
        let transaction = WriteTransaction(realm: wrapper)
        try wrapper.realm.write { try block(transaction) }
    }
    
    /// Write transation in current thread (queue)
    public func write<T: ThreadConfined>(_ obj: T, block: (T, WriteTransaction) throws -> Void) throws {
        let wrapper = try self.wrapper()
        let transaction = WriteTransaction(realm: wrapper)
        try wrapper.realm.write { try block(obj, transaction) }
    }
 
    /// Performs write transaction into the new instance.
    public func instanceWrite<T: ThreadConfined>(_ obj: T, block: (T, WriteTransaction) -> Void) throws {
        try newInstance().write(obj, block: block)
    }
    
    public func writeAsync<T: ThreadConfined>(_ obj: T,
                                              queue: DispatchQueue? = nil,
                                              block: @escaping (T, WriteTransaction) throws -> Void,
                                              errorHandler: @escaping ((_ error: Swift.Error) -> Void) = { _ in return }) {
        do {
            let wrapper = try self.wrapper()
            let transaction = WriteTransaction(realm: wrapper)
            transaction.async(obj, queue: queue, errorHandler: errorHandler, closure: block)
        } catch {
            errorHandler(error)
        }
    }
    
    public func item<Item: Object, KeyType>(_ type: Item.Type, forPrimaryKey id: KeyType) -> Item? {
        self.realm?.object(ofType: type, forPrimaryKey: id)
    }

    public func items<Item: Object>(_ type: Item.Type) throws -> Results<Item>? {
        self.realm?.objects(type)
    }

    public func deleteAll() throws {
        try self.write { tr in
            tr.realm.deleteAll()
        }
    }

    /// - WARNING: Removes all Realm files physically. Use carefully!
    public static func kill(_ settings: SettingsList) throws {
        var conf = Realm.Configuration()
        try settings.affect(&conf)
        try Realm.flushDatabase(with: conf)
    }
    
    public static func wipeAll(at path: FolderPath) throws {
        let url = try path.url()
        try FileManager.default.cleanFolder(at: url)
        // Check results
        let isEmpty = try FileManager.default.folderItems(at: url).isEmpty
        guard isEmpty else {
            throw CocoaError(.fileWriteUnknown)
        }
        try FileManager.default.removeItem(at: url)
    }
}

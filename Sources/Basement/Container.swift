import RealmSwift
import Foundation

/// A Root class wrapper for Realm database.
/// Since Realm is thread contained, we need to make sure that it's always accessed from the same queue it was initialized.
/// Other words, each `Realm()` instance has to be constructed for any perticular queue you're accessing it at the moment.
/// That is what Container does - it wraps each Realm instance and makes it thread safe.
/// Also, it gives a tool like `Container.Configuration` which allows to easily manage Realm databases on disk.
open class Container {
    
    public typealias Configuration = Realm.Configuration

    /// Default configuration for global use
    public static var defaultConfiguration: Configuration = .defaultConfiguration
    /// Thread safe instance of Realm
    private static let _realm: ThreadSpecificVariable<RealmWrapper> = .init()
    
    private let configuration: Realm.Configuration
    private let queue: DispatchQueue?
    
    public init(configuration: Realm.Configuration = Container.defaultConfiguration, queue: DispatchQueue? = nil) throws {
        self.configuration = configuration
        self.queue = queue
        if Container._realm.currentValue == nil || Container._realm.currentValue?.realm.configuration != configuration {
            Container._realm.currentValue = try RealmWrapper(conf: configuration, queue: queue)
        }
    }

    /// Creates a new instance of the `Container` by initializing with exiting configuration.
    public func newInstance(queue: DispatchQueue? = nil) throws -> Container {
        try Container(configuration: configuration, queue: queue)
    }
    
    /// Main getter Realm instance.
    public func realm() throws -> Realm {
        try wrapper().realm
    }
    
    internal func wrapper() throws -> RealmWrapper {
        if let r = Self._realm.currentValue {
            return r
        }
        let r = try RealmWrapper(conf: configuration, queue: self.queue)
        Container._realm.currentValue = r
        if _isDebugAssertConfiguration() {
            let name = Thread.current.name ?? ""
            let part = !name.isEmpty ? name : String(describing: withUnsafePointer(to: Thread.current) { $0 })
            print("🗞 \(type(of: self)): new instance for queue \(part)")
        }
        return r
    }
}

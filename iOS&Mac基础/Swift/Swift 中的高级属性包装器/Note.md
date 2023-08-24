# Swift 中的高级属性包装器  

Swift 中的高级属性包装器,它一直处于高速发展中，为我们提供优秀且快捷的实现方式和使用体验。 
本文将围绕swift中的属性包装器进行探讨和学习  

本文将围绕一下几点进行探讨学习： 
1. 如何使用属性包装器 
2. 应用的领域 
3. 如果自定义属性包装器 
4. 属性包装器使用的限制  
5. 属性包装器的替代方案

## 如何使用属性包装器 
示例说明，首先将在开发中未使用睡醒那个包装器： 
```swift
var username: String {
    get {
        UserDefaults.standard.string(forKey: "user-name")
    }
    set {
        UserDefaults.standard.set(newValue, forKey: "user-name")
    }
}

```
这些用于读取和写入`UserDefaults`的访问器通常分散在应用程序中, 导致大量代码重复,在某种程度上，它们向使用它们的类公开实现详细信息，使代码更加冗长。  

从 iOS 14 开始，`@AppStorage`属性包装器可用于实现相同的结果 - 语法要简单得多。它在 SwiftUI 视图中特别有用。  
假设我们的视图中有一个属性用户名，我们希望与 UserDefaults 同步：

```swift
struct MyView: View {
    @AppStorage("user-name")
    var username = ""
}

```

我们可以像使用任何其他属性一样使用 username 属性, 指定的字符串“username”对应于用于`UserDefaults`的键。  

有三种方法可以访问属性包装器的不同部分：  
* `_username`: 可以访问`AppStorage` 属性包装器本身  
* `username`: 访问包装器的`wrappedValue`, 相当于 `_username.wrappedValue`
* `$username`: 访问包装器的`projectedValue`属性， 该属性可用于属性包装器提供的附加上下文  

|   直接访问   |   间接访问   |   类型   |  
|:------------:| :----------: | :------:|  
|  username    |  _username.wrappedValue  |    `String`  |  
|  _username   |     ❌       |   `AppStorage<String>`   |  
| $username    | _username.projectedValue  |  `Binding<String>`    |  

> 事实上，你可以用属性包装器做的所有事情，你也可以不用它们做, 但是，如果使用正确，属性包装器可以使您的代码更简洁、更简洁。  



### SwiftUI 中常用的属性包装器 
* @State  
* @Environment  
* @EnvironmentObject  
* @ObservedObject 
* @StateObject    

> 以上只是列举出了部分，还有大量的未列举出的  



## 自定义属性包装器 
Apple 只为 UserDefaults ( `@AppStorage`) 提供了一个属性包装器，没有用于 Keychain 访问。

1. 首先定义 `KeychainItem`, 用于 `Keychain` 操作   
```swift
struct KeychainItem {

    // MARK: Nested Types
    enum KeychainError: Error {
        case noPassword
        case unexpectedPasswordData
        case unexpectedItemData
        case unhandledError(status: OSStatus)
    }

    // MARK: Stored Properties
    let service: String
    let account: String
    let accessGroup: String?

    // MARK: Initialization
    init(service: String, account: String, accessGroup: String? = nil) {
        self.service = service
        self.account = account
        self.accessGroup = accessGroup
    }

    // MARK: Methods
    func get() -> String? {
        /*
         Build a query to find the item that matches the service, account and
         access group.
         */
        var query = KeychainItem.query(service: service, account: account, accessGroup: accessGroup)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue

        // Try to fetch the existing keychain item that matches the query.
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }

        // Check the return status and throw an error if appropriate.
        guard status != errSecItemNotFound else { return nil }
        guard status == noErr else { return nil }

        // Parse the password string from the query result.
        guard let existingItem = queryResult as? [String: AnyObject],
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: String.Encoding.utf8)
            else {
                return nil
        }

        return password
    }

    func set(_ value: String?) {
        if let value = value {
            save(value)
        } else {
            delete()
        }
    }

    func save(_ password: String) {
        // Encode the password into an Data object.
        let encodedPassword = Data(password.utf8)

        if get() != nil {
            var attributesToUpdate = [String: AnyObject]()
            attributesToUpdate[kSecValueData as String] = encodedPassword as AnyObject?

            let query = KeychainItem.query(service: service,
                                           account: account,
                                           accessGroup: accessGroup)
            _ = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
        } else {
            var newItem = KeychainItem.query(service: service,
                                             account: account,
                                             accessGroup: accessGroup)

            newItem[kSecValueData as String] = encodedPassword as AnyObject?

            _ = SecItemAdd(newItem as CFDictionary, nil)
        }
    }

    func delete() {
        // Delete the existing item from the keychain.
        let query = KeychainItem.query(service: service, account: account, accessGroup: accessGroup)

        _ = SecItemDelete(query as CFDictionary)
    }

    // MARK: Helpers
    private static func items(forService service: String, accessGroup: String? = nil) throws -> [KeychainItem] {
        // Build a query for all items that match the service and access group.
        var query = KeychainItem.query(service: service, accessGroup: accessGroup)
        query[kSecMatchLimit as String] = kSecMatchLimitAll
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanFalse

        // Fetch matching items from the keychain.
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }

        // If no items were found, return an empty array.
        guard status != errSecItemNotFound else { return [] }

        // Throw an error if an unexpected status was returned.
        guard status == noErr else { throw KeychainError.unhandledError(status: status) }

        // Cast the query result to an array of dictionaries.
        guard let resultData = queryResult as? [[String: AnyObject]] else { throw KeychainError.unexpectedItemData }

        // Create a `KeychainItem` for each dictionary in the query result.
        var items = [KeychainItem]()
        for result in resultData {
            guard let account = result[kSecAttrAccount as String] as? String else {
                continue
            }

            let item = KeychainItem(service: service, account: account, accessGroup: accessGroup)
            items.append(item)
        }

        return items
    }

    private static func query(service: String,
                              account: String? = nil,
                              accessGroup: String? = nil) -> [String: AnyObject] {
        var query = [String: AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = service as AnyObject?

        if let account = account {
            query[kSecAttrAccount as String] = account as AnyObject?
        }

        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }

        return query
    }

}

```

2. 自定义属性包装器(不可归档的)
```swift
@propertyWrapper
struct SecureAppStorage {
    
    var item: KeychainItem
    
    init(_ account: String, service: String = Bundle.main.bundleIdentifier!) {
        self.item = .init(service: service, account: account)
    }
    
    public var wrappedValue: String? {
        get {
            item.get()
        }
        nonmutating set {
            item.set(newValue)
        }
    }
}

extension SecureAppStorage {
    var projectedValue: KeychainItem {
        item
    }
}

```
3. 自定义属性包装器(可归档的) 
```swift 
@propertyWrapper
struct CodableSecureAppStorage<C: Codable> {

    var item: KeychainItem
    var encoder = JSONEncoder()
    var decoder = JSONDecoder()

    init(_ account: String, service: String = Bundle.main.bundleIdentifier!) {
        self.item = .init(service: service, account: account)
    }

    public var wrappedValue: C? {
        get {
            item.get()
                .flatMap { Data(base64Encoded: $0) }
                .flatMap { try? decoder.decode(C.self, from: $0) }
        }
        nonmutating set {
            let string = newValue
                .flatMap { try? encoder.encode($0) }
                .flatMap { $0.base64EncodedString() }
            item.set(string)
        }
    }

}
```






## 属性包装器的限制  
1. 属性包装器始终是私有的。  
    如果不使用自定义计算属性公开属性，则不可能从给定类型的外部访问属性包装器  
2. 属性包装器不能作为别名  
3. 不允许对非属性变量使用属性包装器。  
4. 不能使用包装的属性`override` 
```swift
class SuperClass {

    @SuperClassWrapper
    var value: Value

}

class SubClass: SuperClass {

    @SubClassWrapper
    override var value: Value

}

```
可以通过一下方式避免覆盖：__但不推荐这样__  
```swift
class SuperClass {

    @SuperClassWrapper
    var value: Value

}

class SubClass: SuperClass {

    @SubClassWrapper
    var _value: Value

    override var value: Value {
        get { _value }
        set { _value = newValue }
    }

}
```

5. 属性和属性包装器之间的依赖关系  
```swift
class KeyValueStore {
    let serviceName: String
    let defaults: UserDefaults
    @SecureAppStorage("username", service: serviceName) 
    var username
    @SecureAppStorage("password", service: serviceName)
    var password
    @AppStorage("isFirstLaunch", defaults: defaults)
    var isFirstLaunch = false
    @AppStorage("isLoggedIn", defaults: defaults)
    var isLoggedIn: Bool
}

```
`@SecureAppStorage`属性包装器依赖于`serviceName`属性的值  
__属性包装器不是懒惰加载的__，这意味着您不能使用对 self 或其任何属性的任何引用来初始化它们。以上方式将不能直接使用  

__绕过此限制的唯一方法是在初始值设定项中手动创建属性包装器：__

```swift
class KeyValueStore {

    let serviceName: String
    let defaults: UserDefaults

    init(serviceName: String, defaults: UserDefaults) {
        self.serviceName = serviceName
        self.defaults = defaults
        self._username = SecureAppStorage("username", service: serviceName)
        self._password = SecureAppStorage("password", service: serviceName)
        self._isFirstLaunch = AppStorage(
            wrappedValue: false, 
            "isFirstLaunch", 
            defaults: defaults
        )
        self._isLoggedIn = AppStorage(
            wrappedValue: false, 
            "isLoggedIn", 
            defaults: defaults
        )
    }

    @SecureAppStorage
    var username

    @SecureAppStorage
    var password

    @AppStorage
    var isFirstLaunch: Bool

    @AppStorage
    var isLoggedIn: Bool

}
```
> 以上方式与属性包装器的出发点相背驰。  

6. 协议中不能包含属性包装器。
```swift 
protocol KeyValueStoreProtocol {
    @SecureAppStorage var username { get set }
}
```

7. 您不能使用不同的类型来获取和设置wrappedValue(__类型一定要一致__)   
8. 设置属性包装器的wrappedValue不会导致失败。
    __由于Swift中的变量赋值不能引发错误__，因此属性包装器没有统一的接口来处理失败事件。

9. __属性包装器可能隐藏大量计算__  
    属性包装器的语法非常简约且功能强大。如果属性包装器执行一些繁重的计算来获取和/或存储值，则可能会导致不可预见的性能问题，这些问题在使用包装器的地方不直接可见，因为它看起来只是一个简单的属性分配。为了避免这个问题，属性包装器可能需要遵守某些复杂性标准（例如恒定的访问时间）和/或缓存值，以在很长一段时间内获得恒定的获取/设置时间。
10. 协议类型不能用于具有类型约束的属性包装器。  
    某些属性包装器要求其包装值符合特定协议。如果Swift中的泛型类型存在类型约束，则您不能指定协议作为该类型约束，而必须使用具体类型，即使该协议没有关联类型/自我要求。  
    ```swift 
    MyPropertyWrapper<ValueType: MyProtocol> 
    // 不能以下方式使用 
    @MyPropertyWrapper var value: MyProtocol  
    ```
11. 不能直接使用 self  
12. 同时使用多个属性包装器 
    __只能通过自定义属性包装器实现__ 
    ```swift
    @propertyWrapper
        struct NegatedAppStorage {

            @AppStorage
            private var storedValue: Bool

            init(wrappedValue: Bool, _ name: String) {
                self._storedValue = AppStorage(wrappedValue: wrappedValue, name)
            }

            var wrappedValue: Bool {
                get {
                    return !storedValue
                }
                set {
                    storedValue = !newValue
                }
            }

        }
    
    ```


## 属性包装器的替代方案  
* willSet/didSet  
* get/set
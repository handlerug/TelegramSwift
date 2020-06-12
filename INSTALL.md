# How to Build Telegram for macOS

1. Clone this repository with submodules: `git clone https://github.com/handlerug/TelegramSwift.git --recurse-submodules`
2. Install CMake, Ninja, OpenSSL 1.1 and zlib.
3. Open `Telegram-Mac.xcworkspace` in **Xcode 10.3**.  Avoid Xcode 10.11+ because it causes additional errors when building the libraries with optimizations turned on.  
4. Select Github build target and click **Run**.



# If you want to develop a fork

1. Change bundle Identifier and team ID. The easiest way is to search all mentions `ru.keepcoder.Telegram` and change it to your own. Your team ID can be found on Apple developer portal.
2. Obtain your [API ID](https://core.telegram.org/api/obtaining_api_id). **Note:** The built-in `apiId` usage is highly limited. **Do not use it** in any circumstances except to test your application.
3. Open `Telegram-Mac/Config.swift`, paste example contents from below and replace `apiId` and `apiHash` with yours from previous step. Don't forget to change `teamId` too.
4. Replace or remove `SFEED_URL` and  `APPCENTER_SECRET`  in `*.xcconfig` files. (The former is used for in-app updates and the latter is used for collecting crashes at [AppCenter](https://appcenter.ms))
5. Write good new code!

If you still have a questions feel free to [open new issue](https://github.com/handlerug/TelegramSwift/issues/new).

# Config.swift example contents

```swift
final class ApiEnvironmentExample {
    static var apiId:Int32 {
        return 9
    }
    static var apiHash:String {
        return "3975f648bb682ee889f35483bc618d1c"
    }
    
    static var bundleId: String {
        return "ru.keepcoder.Telegram"
    }
    static var teamId: String {
        return "6N38VWS5BX"
    }
    
    static var group: String {
        return teamId + "." + bundleId
    }
    
    static var appData: Data {
        let apiData = evaluateApiData() ?? ""
        let dict:[String: String] = ["bundleId": bundleId, "data": apiData]
        return try! JSONSerialization.data(withJSONObject: dict, options: [])
    }
    static var language: String {
        return "macos"
    }
    static var version: String {
        var suffix: String = ""
        #if STABLE
            suffix = "STABLE"
        #elseif APP_STORE
            suffix = "APPSTORE"
        #elseif ALPHA
            suffix = "ALPHA"
        #elseif GITHUB
            suffix = "GITHUB"
        #else
            suffix = "BETA"
        #endif
        let shortVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? ""
        return "\(shortVersion) \(suffix)"
    }
}
```

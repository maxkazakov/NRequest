import Foundation

public final class ResponseData {
    public let request: URLRequestable?
    public let body: Data?
    public let response: URLResponse?
    public internal(set) var error: Error?
    public var userInfo: Parameters.UserInfo

    public lazy var url: URL? = {
        return (response as? HTTPURLResponse)?.url
    }()

    public lazy var allHeaderFields: [AnyHashable: Any] = {
        return (response as? HTTPURLResponse)?.allHeaderFields ?? [:]
    }()

    public lazy var statusCode: Int? = {
        return (response as? HTTPURLResponse)?.statusCode
    }()

    public lazy var urlError: URLError? = {
        return error as? URLError
    }()

    init(request: URLRequestable?,
         body: Data?,
         response: URLResponse?,
         error: Error?,
         userInfo: Parameters.UserInfo) {
        self.request = request
        self.body = body
        self.response = response
        self.error = error
        self.userInfo = userInfo
    }
}

import Foundation

public enum Plugins {
    public enum TokenType {
        public enum Operation {
            case set(String)
            case add(String)
        }
        case header(Operation)
        case queryParam(String)
    }

    public static func Bearer(tokenProvider: @escaping TokenPlugin.TokenProvider,
                              type: TokenType = .header(.set("Authorization"))) -> Plugin {
        return TokenPlugin(type: type) {
            return tokenProvider().map { token in
                return "Bearer " + token
            }
        }
    }

    public final class StatusCode: Plugin {
        public init() {
        }

        public func prepare(_ parameters: Parameters, request: inout URLRequestable) {
        }

        public func willSend(_ parameters: Parameters, request: URLRequestable) {
        }

        public func didFinish(_ parameters: Parameters, request: URLRequestable, data: ResponseData) {
        }

        public func verify(data: ResponseData) throws {
            if let error = NRequest.StatusCode(data.statusCode) {
                throw error
            }
        }
    }

    public final class TokenPlugin: Plugin {
        public typealias TokenProvider = () -> String?
        private let tokenProvider: TokenProvider
        private let type: TokenType

        public init(type: TokenType,
                    tokenProvider: @escaping TokenProvider) {
            self.tokenProvider = tokenProvider
            self.type = type
        }

        public func prepare(_ parameters: Parameters,
                            request: inout URLRequestable) {
            guard let apiKey = tokenProvider() else {
                return
            }

            switch type {
            case .header(let operation):
                switch operation {
                case .set(let keyName):
                    request.setValue(apiKey, forHTTPHeaderField: keyName)
                case .add(let keyName):
                    request.addValue(apiKey, forHTTPHeaderField: keyName)
                }
            case .queryParam(let keyName):
                if let requestURL = request.url, var urlComponents = URLComponents(url: requestURL, resolvingAgainstBaseURL: false) {
                    var queryItems: [URLQueryItem] = urlComponents.queryItems ?? []
                    queryItems = queryItems.filter({ $0.name != keyName })
                    queryItems.append(URLQueryItem(name: keyName, value: apiKey))
                    urlComponents.queryItems = queryItems

                    if let url = urlComponents.url {
                        request.url = url
                    }
                }
            }
        }

        public func willSend(_ parameters: Parameters, request: URLRequestable) {
        }

        public func didFinish(_ parameters: Parameters, request: URLRequestable, data: ResponseData) {
        }

        public func verify(data: ResponseData) throws {
        }
    }
}

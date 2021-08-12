import Foundation

public struct RequestAssembly {
    private let commonPluginProvider: PluginProvider?

    public init(commonPluginProvider: PluginProvider? = nil) {
        self.commonPluginProvider = commonPluginProvider
    }

    public func factory() -> RequestFactory {
        return Impl.RequestFactory()
    }

    public func manager<Error: AnyError>(factory: RequestFactory? = nil,
                                         plugins: [Plugin] = [],
                                         pluginProvider: PluginProvider? = nil,
                                         stopTheLine: AnyStopTheLine<Error>? = nil) -> AnyRequestManager<Error> {
        let resolvedPluginProvider: PluginProvider?
        switch (pluginProvider, commonPluginProvider) {
        case (.some(let a), .some(let b)):
            resolvedPluginProvider = PluginProviderContext(plugins: plugins,
                                                           providers: [a, b])
        case (.some(let a), .none):
            resolvedPluginProvider = PluginProviderContext(plugins: plugins,
                                                           providers: [a])
        case (.none, .some(let b)):
            resolvedPluginProvider = PluginProviderContext(plugins: plugins,
                                                           providers: [b])
        case (.none, .none):
            if plugins.isEmpty {
                resolvedPluginProvider = nil
            } else {
                resolvedPluginProvider = PluginProviderContext(plugins: plugins)
            }
        }

        return Impl.RequestManager(factory: factory ?? self.factory(),
                                   pluginProvider: resolvedPluginProvider,
                                   stopTheLine: stopTheLine).toAny()
    }
}

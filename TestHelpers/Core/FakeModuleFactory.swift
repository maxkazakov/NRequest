import Foundation
import NSpry

@testable import NRequest

final class FakeModuleFactory: ModuleFactory, Spryable {
    enum ClassFunction: String, StringRepresentable {
        case empty
    }

    enum Function: String, StringRepresentable {
        case factory = "factory()"
        case manager = "start(factory:pluginProvider:stopTheLine:)"
        case managerWithPlugins = "start(factory:plugins:stopTheLine:)"
        case statusCodePlugin = "statusCodePlugin()"
    }

    override func factory() -> RequestFactory {
        return spryify()
    }

    override func manager<Error: AnyError>(factory: RequestFactory? = nil,
                                           pluginProvider: PluginProvider? = nil,
                                           stopTheLine: AnyStopTheLine<Error>? = nil) -> AnyRequestManager<Error> {
        return spryify(arguments: factory, pluginProvider, stopTheLine)
    }

    override func manager<Error: AnyError>(factory: RequestFactory? = nil,
                                           plugins: [Plugin],
                                           stopTheLine: AnyStopTheLine<Error>? = nil) -> AnyRequestManager<Error> {
        return spryify(arguments: factory, plugins, stopTheLine)
    }

    override func statusCodePlugin() -> Plugins.StatusCode {
        return spryify()
    }
}

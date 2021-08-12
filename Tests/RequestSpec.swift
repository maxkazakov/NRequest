import Foundation
import UIKit

import Quick
import Nimble
import NSpry

@testable import NRequest
@testable import NRequestTestHelpers

class RequestSpec: QuickSpec {
    private enum Constant {
        static let userInfo: Parameters.UserInfo = ["key": 123]
    }

    override func spec() {
        describe("Request") {
            var subject: Request!
            var parameters: Parameters!
            var session: FakeSession!

            beforeEach {
                session = .init()
                parameters = .testMake(userInfo: Constant.userInfo,
                                       session: session)
                subject = Impl.Request(parameters: parameters)
            }

            it("should save parameters to var") {
                expect(subject.parameters) == parameters
            }

            describe("indle request") {
                describe("canceling") {
                    beforeEach {
                        subject.cancel()
                    }

                    it("should nothing happen") {
                        expect(true).to(beTrue())
                    }
                }

                describe("restarting") {
                    it("should throw unexpected assertion") {
                        expect(subject.restart()).to(throwAssertion())
                    }
                }
            }

            describe("starting") {
                var responses: [ResponseData]!
                var task: FakeSessionTask!
                var sessionCompletionHandler: Session.CompletionHandler!

                beforeEach {
                    responses = []

                    task = .init()
                    task.stub(.resume).andReturn()

                    session.stub(.task).andDo { args in
                        sessionCompletionHandler = args[1] as? Session.CompletionHandler
                        return task
                    }

                    subject.start { data in
                        responses.append(data)
                    }
                }

                afterEach {
                    // deinit
                    task.resetCallsAndStubs()
                    task.stub(.isRunning).andReturn(false)

                    subject = nil
                }

                it("should wait response") {
                    expect(responses).to(beEmpty())
                }

                it("should start session task") {
                    expect(task).to(haveReceived(.resume))
                }

                describe("canceling") {
                    beforeEach {
                        task.resetCallsAndStubs()
                        task.stub(.isRunning).andReturn(true)
                        task.stub(.cancel).andReturn()
                        subject.cancel()
                    }

                    it("should cancel previous task") {
                        expect(task).to(haveReceived(.isRunning))
                        expect(task).to(haveReceived(.cancel))
                    }
                }

                describe("restarting") {
                    beforeEach {
                        task.resetCallsAndStubs()
                        task.stub(.resume).andReturn()
                        task.stub(.isRunning).andReturn(true)
                        task.stub(.cancel).andReturn()
                        subject.restart()
                    }

                    it("should cancel previous task and resume new") {
                        expect(task).to(haveReceived(.resume))
                        expect(task).to(haveReceived(.isRunning))
                        expect(task).to(haveReceived(.cancel))
                    }
                }

                context("when request completed") {
                    beforeEach {
                        sessionCompletionHandler(nil, nil, nil)
                    }

                    it("should receive response") {
                        expect(responses).to(equal([.testMake(body: nil,
                                                              response: nil,
                                                              error: nil,
                                                              userInfo: Constant.userInfo)]))
                    }

                    context("when request completed for the second time") {
                        beforeEach {
                            sessionCompletionHandler(nil, nil, nil)
                        }

                        it("should receive response") {
                            expect(responses).to(equal([.testMake(body: nil,
                                                                  response: nil,
                                                                  error: nil,
                                                                  userInfo: Constant.userInfo),
                                                        .testMake(body: nil,
                                                                  response: nil,
                                                                  error: nil,
                                                                  userInfo: Constant.userInfo)]))
                        }
                    }
                }
            }
        }
    }
}

import Combine
import ComposableArchitecture
import WaniKani

extension WaniKani {
    /// Sends a resource to WaniKani and responds accordingly.
    ///
    /// - Parameters:
    ///   - resource: The resource object, which describes how to perform the request
    ///   - pageOptions: Options for pagination, which are ignored by resources that do not involve pagination.
    /// - Returns: the `Response` instance wrapped in an `Effect`
    public func send<R>(_ resource: R, pageOptions: PageOptions? = nil) -> Effect<Response<R>, Swift.Error>
    where R: Resource, R.Content: Decodable {
        Effect.task { [unowned self] in
            try await self.send(resource, pageOptions: pageOptions)
        }
    }

    /// Sends a resource carrying a body to WaniKani and responds accordingly.
    ///
    /// - Parameters:
    ///   - resource: The resource object, which describes how to perform the request
    ///   - pageOptions: Options for pagination, which are ignored by resources that do not involve pagination.
    /// - Returns: the `Response` instance wrapped in an `Effect`
    public func send<R>(_ resource: R, pageOptions: PageOptions? = nil) -> Effect<Response<R>, Swift.Error>
    where R: Resource, R.Body: Encodable, R.Content: Decodable {
        Effect.task { [unowned self] in
            try await self.send(resource, pageOptions: pageOptions)
        }
    }

    public func allPages<R, Inner>(_ resource: R) -> Effect<[Response<R>], Swift.Error>
    where R: Resource, R.Content == ModelCollection<Inner> {
        let pageOptionsPublisher = CurrentValueSubject<PageOptions?, Never>(nil)

        return
            pageOptionsPublisher
            .flatMap { pageOptions in
                return self.send(resource, pageOptions: pageOptions)
            }
            .handleEvents(receiveOutput: { response in
                if let next = response.data.page.next {
                    pageOptionsPublisher.send(next)
                } else {
                    pageOptionsPublisher.send(completion: .finished)
                }
            })
            .reduce([Response<R>]()) { acc, response in
                [response] + acc
            }
            .eraseToEffect()
    }
}

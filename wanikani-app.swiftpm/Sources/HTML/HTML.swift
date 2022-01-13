import Foundation
import SwiftSoup

public func html(data: Data, encoding: String.Encoding) throws -> Document? {
    guard let html = String(data: data, encoding: encoding) else {
        return nil
    }

    return try SwiftSoup.parse(html)
}

extension Document {
    public var csrfToken: String? {
        get throws {
            try head()?
                .select(#"meta[name="csrf-token"]"#)
                .first()?
                .attr("content")
        }
    }

    public var emailAddress: String? {
        get throws {
            try body()?
                .select(#"input[id="user_email"]"#)
                .first()?
                .attr("value")
        }
    }

    public func accessToken(for appName: String) throws -> String? {
        try body()?
            .select(#"td[class="personal-access-token-description"]"#)
            .first(where: { (try $0.text()) == appName })?
            .nextElementSibling()?
            .text()
    }
}

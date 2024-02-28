//  Copyright © 2021 Krasavchik OOO. All rights reserved.

import UIKit

public struct Typography {

    init() {}
}

// MARK: - App Typography

extension Typography {

    public typealias TextStyle = UIFont

    // MARK: - Text Styles

    // A title more generic thing like flow or screen.
    // It's like book title or brand name
    // It's ususally short. Ex.: one or a few words
    public var largeTitle: TextStyle { .preferredFont(forTextStyle: .largeTitle) }
    public var title1: TextStyle { .preferredFont(forTextStyle: .title1) }
    public var title2: TextStyle { .preferredFont(forTextStyle: .title2) }
    public var title3: TextStyle { .preferredFont(forTextStyle: .title3) }

    // Headline describes more specific thing than title.
    // Section name, card name. It's similar to chapter name in book, or article name in magazine.
    // It's usually longer than title. Ex.: looks like phrase, sentence
    public var headline: TextStyle { .preferredFont(forTextStyle: .headline) }
    public var subheadline: TextStyle { .preferredFont(forTextStyle: .subheadline) }

    // Any text content
    public var body: TextStyle { .preferredFont(forTextStyle: .body) }

    // It's action in some way like button
    public var action: TextStyle { .preferredFont(forTextStyle: .body) }

    // It's used like brief explanation of something and appended to an image, scheme, field
    public var caption1: TextStyle { .preferredFont(forTextStyle: .caption1) }
    public var caption2: TextStyle { .preferredFont(forTextStyle: .caption2) }

    //  It's used for notes like Terms of Services and Privacy Policy
    public var footnote: TextStyle { .preferredFont(forTextStyle: .footnote) }

    // It's used for for callouts like map pin description for instance
    public var callout: TextStyle { .preferredFont(forTextStyle: .callout) }
}

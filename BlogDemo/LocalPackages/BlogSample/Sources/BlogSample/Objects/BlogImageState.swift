// Copyright © 2023 Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import UIKit

/// Allowable states for an image in the blog
public enum BlogImageState {
    case loading
    case error(Error)
    case image(UIImage)
}

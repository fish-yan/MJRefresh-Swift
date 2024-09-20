//
//  File.swift
//  MJRefresh
//
//  Created by yan on 2024/9/19.
//

import UIKit

extension UIScrollView {
    
    var inset: UIEdgeInsets {
        adjustedContentInset
    }
    
    var insetT: CGFloat {
        get {
            inset.top
        }
        set {
            contentInset.top = newValue - (adjustedContentInset.top - contentInset.top)
        }
    }
    
    var insetB: CGFloat {
        get {
            inset.bottom
        }
        set {
            contentInset.bottom = newValue - (adjustedContentInset.bottom - contentInset.bottom)
        }
    }
    
    var insetL: CGFloat {
        get {
            inset.left
        }
        set {
            contentInset.left = newValue - (adjustedContentInset.left - contentInset.left)
        }
    }
    
    var insetR: CGFloat {
        get {
            inset.right
        }
        set {
            contentInset.right = newValue - (adjustedContentInset.right - contentInset.right)
        }
    }
}

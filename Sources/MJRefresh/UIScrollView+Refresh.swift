//
//  File.swift
//  MJRefresh
//
//  Created by yan on 2024/9/18.
//

import UIKit

extension UIScrollView: MJWrappable { }

private struct AssociatedKey {
    static var headerTag: Int = -998765
    static var footerTag: Int = -998764
}

public extension MJNameSpace where Base: UIScrollView {
    
    var header: RefreshHeader? {
        base.viewWithTag(AssociatedKey.headerTag) as? RefreshHeader
    }
    
    var footer: RefreshFooter? {
        base.viewWithTag(AssociatedKey.footerTag) as? RefreshFooter
    }
    
    func set(header newValue: RefreshHeader?) {
        if let header, newValue != header {
            header.removeFromSuperview()
        }
        guard let newValue else { return }
        newValue.tag = AssociatedKey.headerTag
        base.insertSubview(newValue, at: 0)
    }
    
    func set(footer newValue: RefreshFooter?) {
        if let footer, newValue != footer {
            footer.removeFromSuperview()
        }
        guard let newValue else { return }
        newValue.tag = AssociatedKey.footerTag
        base.insertSubview(newValue, at: 0)
    }
}

public extension UIScrollView {
    @objc var mj_header: RefreshHeader? {
        get { mj.header }
        set { mj.set(header: newValue) }
    }
    
    @objc var mj_footer: RefreshFooter? {
        get { mj.footer }
        set { mj.set(footer: newValue) }
    }
}

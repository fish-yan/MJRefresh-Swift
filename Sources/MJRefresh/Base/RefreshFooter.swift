//
//  RefreshAutoFooter.swift
//  
//
//  Created by yan on 2024/9/14.
//

import UIKit

@objcMembers @objc(MJRefreshFooter)
open class RefreshFooter: RefreshComponent {
    
    @objc(footerWithRefreshingBlock:)
    public static func footer(block: @escaping RefreshComponentAction) -> Self {
        let footer = Self.init()
        footer.refreshingBlock = block
        return footer
    }
    
    @objc(footerWithRefreshingTarget: refreshingAction:)
    public static func footer(target: Any, action: Selector) -> Self {
        let footer = Self.init()
        footer.setRefreshing(target: target, action: action)
        return footer
    }
    
    public var ignoredScrollViewContentInsetBottom: CGFloat = 0
    
    private var lastBottomDelta: CGFloat = 0
    
    public var isBack = false
        
    open override var state: RefreshState {
        didSet {
            guard let scrollView else { return }
            switch state {
            case .noMoreData, .idle:
                if oldValue == .refreshing {
                    UIView.animate(withDuration: slowAnimationDuration) {
                        scrollView.insetB -= self.lastBottomDelta
                        if self.isAutomaticallyChangeAlpha { self.alpha = 0 }
                    } completion: { _ in
                        self.pullingPercent = 0
                    }
                }
                let deltaH = heightForContentBreakView()
                if oldValue == .refreshing && deltaH > 0 {
                    scrollView.contentOffset.y = scrollView.contentOffset.y
                }
            case .refreshing:
                UIView.animate(withDuration: fastAnimationDuration) {
                    var bootom = self.frame.height + self.scrollViewOriginalInset.bottom
                    let deltaH = self.heightForContentBreakView()
                    if deltaH < 0 {
                        bootom -= deltaH
                    }
                    self.lastBottomDelta = bootom - scrollView.insetB
                    scrollView.insetB = bootom
                    scrollView.contentOffset.y = self.happenOffsetY() + self.frame.height
                } completion: { _ in
                    self.executeRefreshingCallback()
                }
            default: break
            }
        }
    }
    
    open override func prepare() {
        super.prepare()
        frame.size.height = RefreshKey.footerHeight
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        scrollViewContentSizeDidChange(nil)
    }
    
    open func endRefreshingWithNoMoreData() {
        MJDispatchOnMainQueue {
            self.state = .noMoreData
            self.state = .noMoreData
        }
    }
    
    open func resetNoMoreData() {
        MJDispatchOnMainQueue {
            self.state = .idle
        }
    }
    
    open override func scrollViewContentSizeDidChange(_ change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewContentSizeDidChange(change)
        
        guard let scrollView,
            let size = change?[.newKey] as? CGSize else {
            return
        }
        var contentHeight = size.height == 0 ? scrollView.contentSize.height : size.height
        contentHeight += ignoredScrollViewContentInsetBottom
        if isBack {
            let scrollHeight = scrollView.frame.height - scrollViewOriginalInset.top - scrollViewOriginalInset.bottom + ignoredScrollViewContentInsetBottom
            contentHeight = max(contentHeight, scrollHeight)
        }
        if frame.origin.y != contentHeight {
            frame.origin.y = contentHeight
        }
    }
    
    open override func scrollViewContentOffsetDidChange(_ change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewContentOffsetDidChange(change)
        guard let scrollView else { return }
        if state == .refreshing { return }
        
        scrollViewOriginalInset = scrollView.inset
        let currentOffsetY = scrollView.contentOffset.y
        let happenOffsetY = happenOffsetY()
        
        if currentOffsetY <= happenOffsetY { return }
        
        let pullingPercent = (currentOffsetY - happenOffsetY) / frame.height
        if state == .noMoreData {
            self.pullingPercent = pullingPercent
            return
        }
        
        if scrollView.isDragging {
            self.pullingPercent = pullingPercent
            let normal2pullingOffsetY = happenOffsetY + frame.height
            if state == .idle && currentOffsetY > normal2pullingOffsetY {
                state = .pulling
            } else if state == .pulling && currentOffsetY <= normal2pullingOffsetY {
                state = .idle
            }
        } else if state == .pulling {
            beginRefreshing()
        } else if pullingPercent < 1 {
            self.pullingPercent = pullingPercent
        }
    }
    
    private func heightForContentBreakView() -> CGFloat {
        guard let scrollView else { return 0 }
        let h = scrollView.frame.height - scrollViewOriginalInset.bottom - scrollViewOriginalInset.top
        return scrollView.contentSize.height - h
    }
    
    private func happenOffsetY() -> CGFloat {
        let deltaH = heightForContentBreakView()
        if deltaH > 0 {
            return deltaH - scrollViewOriginalInset.top
        } else {
            return -scrollViewOriginalInset.top
        }
    }
    
}

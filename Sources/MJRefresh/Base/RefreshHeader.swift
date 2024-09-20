//
//  RefreshHeader.swift
//  
//
//  Created by yan on 2024/9/14.
//

import UIKit

@objcMembers @objc(MJRefreshHeader)
open class RefreshHeader: RefreshComponent {
    
    @objc(headerWithRefreshingBlock:)
    public static func header(refreshing block: @escaping RefreshComponentAction) -> Self {
        let header = Self.init()
        header.refreshingBlock = block
        return header
    }
    
    @objc(headerWithRefreshingTarget: refreshingAction:)
    public static func header(refreshing target: Any, action: Selector) -> Self {
        let header = Self.init()
        header.setRefreshing(target: target, action: action)
        return header
    }
    
    public var ignoredScrollViewContentInsetTop: CGFloat = 0 {
        didSet {
            frame.origin.y = -frame.height - ignoredScrollViewContentInsetTop
        }
    }
    
    var lastUpdatedTime: Date {
        if let date = UserDefaults.standard.object(forKey: RefreshKey.headerLastUpdatedTime) as? Date {
            return date
        }
        return Date()
    }
    
    private var insetTDelta: CGFloat = 0
    
    open override var state: RefreshState {
        didSet {
            if state == .idle {
                if oldValue != .refreshing { return }
                headerEndingAction()
            } else if state == .refreshing {
                headerRefreshingAction()
            }
        }
    }
    
    open override func prepare() {
        super.prepare()
        frame.size.height = RefreshKey.headerHeight
    }
    
    open override func placeSubViews() {
        super.placeSubViews()
        frame.origin.y = -frame.height - ignoredScrollViewContentInsetTop
    }
    
    private func resetInset() {
        guard let scrollView else { return }
        
        var insetT = -scrollView.contentOffset.y > scrollViewOriginalInset.top ? -scrollView.contentOffset.y : scrollViewOriginalInset.top
        insetT = insetT > frame.height + scrollViewOriginalInset.top ? frame.height + scrollViewOriginalInset.top : insetT
        insetTDelta = scrollViewOriginalInset.top - insetT
        if abs(scrollView.insetT - insetT) > CGFloat(Float.ulpOfOne) {
            scrollView.insetT = insetT
        }
    }

    open override func scrollViewContentOffsetDidChange(_ change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewContentOffsetDidChange(change)
        
        if state == .refreshing {
            resetInset()
            return
        }
        guard let scrollView else { return }
        scrollViewOriginalInset = scrollView.inset
        
        let offsetY = scrollView.contentOffset.y
        
        let happenOffsetY = -scrollViewOriginalInset.top
        
        if offsetY > happenOffsetY { return }
        
        let normal2pullingOffsetY = happenOffsetY - frame.height
        let pullingPercent = (happenOffsetY - offsetY) / frame.height
        
        if scrollView.isDragging {
            self.pullingPercent = pullingPercent
            if state == .idle && offsetY < normal2pullingOffsetY {
                state = .pulling
            } else if state == .pulling && offsetY >= normal2pullingOffsetY {
                state = .idle
            }
        } else if state == .pulling {
            beginRefreshing()
        } else if pullingPercent < 1 {
            self.pullingPercent = pullingPercent
        }
    }
}

private extension RefreshHeader {
    func headerEndingAction() {
        guard let scrollView else { return }
        UserDefaults.standard.setValue(Date(), forKey: RefreshKey.headerLastUpdatedTime)
        UIView.animate(withDuration: slowAnimationDuration) {
            scrollView.insetT += self.insetTDelta
            if self.isAutomaticallyChangeAlpha {
                self.alpha = 0
            }
        } completion: { _ in
            self.pullingPercent = 0
        }
    }
    
    func headerRefreshingAction() {
        guard let scrollView else { return }
        UIView.animate(withDuration: fastAnimationDuration) {
            if scrollView.panGestureRecognizer.state != .cancelled {
                let top = self.scrollViewOriginalInset.top + self.frame.height
                scrollView.insetT = top
                var offset = scrollView.contentOffset
                offset.y = -top
                scrollView.setContentOffset(offset, animated: false)
            }
        } completion: { _ in
            self.executeRefreshingCallback()
        }
    }
}

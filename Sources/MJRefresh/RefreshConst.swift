//
//  File.swift
//  
//
//  Created by yan on 2024/9/14.
//

import Foundation

struct RefreshKey {
    static let contentOffset = "contentOffset"
    static let contentSize = "contentSize"
    static let panState = "state"
    
    static let headerLastUpdatedTime = "MJRefreshHeaderLastUpdatedTimeKey"
    
    static let labelLeftInset: CGFloat = 25
    static let headerHeight: CGFloat = 54
    static let footerHeight: CGFloat = 44
    static let trailWidth: CGFloat = 60
    
    static let didChangeLanguage = Notification.Name("MJRefreshDidChangeLanguageNotification")
    
    static let headerIdleText = "MJRefreshHeaderIdleText"
    static let headerPullingText = "MJRefreshHeaderPullingText"
    static let headerRefreshingText = "MJRefreshHeaderRefreshingText"
    
    static let footerIdleText = "MJRefreshAutoFooterIdleText"
    static let footerRefreshingText = "MJRefreshAutoFooterRefreshingText"
    static let footerNoMoreDataText = "MJRefreshAutoFooterNoMoreDataText"
    
    static let headerLastTimeText = "MJRefreshHeaderLastTimeText"
    static let headerDateTodayText = "MJRefreshHeaderDateTodayText"
    static let headerNoneLastDateText = "MJRefreshHeaderNoneLastDateText"
}

func MJDispatchOnMainQueue(action: @escaping () -> Void) {
    if Thread.isMainThread {
        action()
    } else {
        DispatchQueue.main.async {
            action()
        }
    }
}

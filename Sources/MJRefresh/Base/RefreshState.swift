//
//  RefreshState.swift
//  MJRefresh
//
//  Created by yan on 2024/9/18.
//

import Foundation

@objc(MJRefreshState)
public enum RefreshState: Int {
    case idle
    case pulling
    case refreshing
    case willRefresh
    case noMoreData
    
}

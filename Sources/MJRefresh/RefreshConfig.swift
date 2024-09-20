//
//  File.swift
//  MJRefresh
//
//  Created by yan on 2024/9/18.
//

import Foundation

class RefreshConfig {
    static let `default` = RefreshConfig()
    
    var languageCode: String? {
        didSet {
            NotificationCenter.default.post(name: RefreshKey.didChangeLanguage, object: self)
        }
    }
    
    var i18nFilename: String?
    
    var i18nBundle: Bundle?
}

//
//  File.swift
//  MJRefresh
//
//  Created by yan on 2024/9/18.
//

import Foundation
import UIKit

extension Bundle: MJWrappable {}

extension MJNameSpace where Base == Bundle {
    static func refreshBundle() -> Bundle {
#if SWIFT_PACKAGE
        return Bundle.module
#else
        let containnerBundle = Bundle(for: RefreshComponent.self)
        return Bundle(path: containnerBundle.path(forResource: "MJRefresh", ofType: "bundle")!)!
#endif
    }
    
    static func path(for resource: String, of type: String = "png") -> String? {
        Bundle.mj.refreshBundle().path(forResource: resource, ofType: type)
    }
}

extension MJNameSpace where Base == Bundle {
    static var arrowImage: UIImage = {
        UIImage(contentsOfFile: Bundle.mj.path(for: "arrow@2x")!)!.withRenderingMode(.alwaysTemplate)
    }()
    
    static func localized(key: String, value: String? = nil) -> String? {
        let language = RefreshConfig.default.languageCode ?? Locale.preferredLanguages.first
        guard let language else {
            return nil
        }
        let table = RefreshConfig.default.i18nFilename
        if let value = defaultI18nBundle(with: language)?.localizedString(forKey: key, value: value, table: nil) {
            return value
        } else if let value = mainBundle(with: language)?.localizedString(forKey: key, value: value, table: table) {
            return value
        } else {
            return nil
        }
    }
    
    static func mainBundle(with language: String) -> Bundle? {
        let bundle = RefreshConfig.default.i18nBundle ?? Bundle.main
        if let path = bundle.path(forResource: language, ofType: "lproj") {
           return Bundle(path: path)
        }
        return nil
    }
    
    static func defaultI18nBundle(with language: String) -> Bundle? {
        var selectedLanguage = language
        
        if language.hasPrefix("en") {
            selectedLanguage = "en"
        } else if language.hasPrefix("zh") {
            if language.contains("Hans") {
                selectedLanguage = "zh-Hans" // 简体中文
            } else {
                selectedLanguage = "zh-Hant" // 繁體中文
            }
        } else if language.hasPrefix("ko") {
            selectedLanguage = "ko"
        } else if language.hasPrefix("ru") {
            selectedLanguage = "ru"
        } else if language.hasPrefix("uk") {
            selectedLanguage = "uk"
        } else {
            selectedLanguage = "en"
        }
        
        // 从MJRefresh.bundle中查找资源
        let mjRefreshBundle = Bundle.mj.refreshBundle()
        if let path = mjRefreshBundle.path(forResource: selectedLanguage, ofType: "lproj") {
            return Bundle(path: path)
        }
        
        return nil
    }
    
}

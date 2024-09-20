//
//  RefreshNormalHeader.swift
//  MJRefresh
//
//  Created by yan on 2024/9/18.
//

import UIKit

@objcMembers @objc(MJRefreshNormalHeader)
open class RefreshNormalHeader: RefreshHeader {
    
    public lazy var stateLabel: UILabel = {
        UILabel.mj.normalLabel
    }()
    
    public lazy var lastUpdatedTimeLabel: UILabel = {
        UILabel.mj.normalLabel
    }()

    public lazy var arrowView: UIImageView = {
        let view = UIImageView(image: Bundle.mj.arrowImage)
        view.contentMode = .center
        return view
    }()

    public lazy var loadingView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.hidesWhenStopped = true
        return view
    }()
    
    private lazy var contentStackView: UIStackView = {
        let labelStackView = UIStackView(arrangedSubviews: [stateLabel, lastUpdatedTimeLabel])
        labelStackView.axis = .vertical
        labelStackView.distribution = .fillEqually
        let contentStackView = UIStackView(arrangedSubviews: [arrowView, loadingView, labelStackView])
        contentStackView.spacing = RefreshKey.labelLeftInset
        addSubview(contentStackView)
        return contentStackView
    }()
    
    open override var state: RefreshState {
        didSet {
            switch state {
            case .idle:
                if oldValue == .refreshing {
                    arrowView.transform = .identity
                    UIView.animate(withDuration: slowAnimationDuration) {
                        self.loadingView.alpha = 0
                    } completion: { _ in
                        if self.state != .idle { return }
                        self.loadingView.alpha = 1
                        self.loadingView.stopAnimating()
                        self.arrowView.isHidden = false
                    }
                } else {
                    loadingView.stopAnimating()
                    arrowView.isHidden = false
                    UIView.animate(withDuration: fastAnimationDuration) {
                        self.arrowView.transform = .identity
                    }
                }
            case .pulling:
                loadingView.stopAnimating()
                arrowView.isHidden = false
                UIView.animate(withDuration: fastAnimationDuration) {
                    self.arrowView.transform = CGAffineTransform(rotationAngle: 0.000001 - Double.pi)
                }
            case .refreshing:
                loadingView.alpha = 1
                loadingView.startAnimating()
                arrowView.isHidden = true
            default: break
            }
            textConfiguration()
        }
    }
    
    private var titles: [RefreshState: String] = [
        .idle: Bundle.mj.localized(key: RefreshKey.headerIdleText) ?? "",
        .pulling: Bundle.mj.localized(key: RefreshKey.headerPullingText) ?? "",
        .refreshing: Bundle.mj.localized(key: RefreshKey.headerRefreshingText) ?? "",
    ]
    
    public var lastUpdatedTimeText: ((Date?) -> String)? {
        didSet {
            lastUpdatedTimeLabel.text = updateTime()
        }
    }
    
    open override func prepare() {
        super.prepare()
        textConfiguration()
    }
    
    open override func i18nDidChange() {
        textConfiguration()
        super.i18nDidChange()
    }
    
    open override func placeSubViews() {
        super.placeSubViews()
        arrowView.tintColor = stateLabel.textColor
        let size = contentStackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        contentStackView.frame = CGRect(
            x: (frame.width - size.width) / 2,
            y: (frame.height - size.height) / 2,
            width: size.width,
            height: size.height
        )
    }
    
    @objc(setTitle: forState:)
    public func setTitle(_ title: String?, for state: RefreshState) {
        titles[state] = title
        stateLabel.text = titles[self.state]
    }
}

private extension RefreshNormalHeader {
    
    func textConfiguration() {
        stateLabel.text = titles[state]
        lastUpdatedTimeLabel.text = updateTime()
    }
    func updateTime() -> String {
        let lastUpdatedTime = UserDefaults.standard.object(forKey: RefreshKey.headerLastUpdatedTime) as? Date
        if let lastUpdatedTimeText {
            return lastUpdatedTimeText(lastUpdatedTime)
        }
        var text = Bundle.mj.localized(key: RefreshKey.headerLastTimeText)!
        if let lastUpdatedTime {
            // 1.获得年月日
            let calendar = Calendar(identifier: .gregorian)
            let unitFlags: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute]
            let cmp1 = calendar.dateComponents(unitFlags, from: lastUpdatedTime)
            let cmp2 = calendar.dateComponents(unitFlags, from: Date())

            // 2.格式化日期
            let formatter = DateFormatter()
            if cmp1.day == cmp2.day { // 今天
                formatter.dateFormat = " HH:mm"
                text +=  Bundle.mj.localized(key: RefreshKey.headerDateTodayText)!
            } else if cmp1.year == cmp2.year { // 今年
                formatter.dateFormat = "MM-dd HH:mm"
            } else {
                formatter.dateFormat = "yyyy-MM-dd HH:mm"
            }
            let time = formatter.string(from: lastUpdatedTime)
            text += time
        } else {
            text += Bundle.mj.localized(key: RefreshKey.headerNoneLastDateText)!
        }
        return text
    }
}

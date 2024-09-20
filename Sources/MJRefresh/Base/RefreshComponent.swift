//
//  RefreshComponent.swift
//  
//
//  Created by yan on 2024/9/14.
//

import UIKit

extension UILabel: MJWrappable {}

extension MJNameSpace where Base == UILabel {
    static var normalLabel: UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.autoresizingMask = [.flexibleWidth]
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        return label
    }
    
    var textWidth: CGFloat {
        let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        if let attributedText = base.attributedText {
            if attributedText.length == 0 { return 0 }
            return attributedText.boundingRect(with: size, options: .usesLineFragmentOrigin, context: nil).size.width
        } else if let text = base.text {
            if text.count == 0 { return 0 }
            let attributedText = NSAttributedString(string: text, attributes: [.font: base.font ?? .systemFont(ofSize: 14)])
            return attributedText.boundingRect(with: size, options: .usesLineFragmentOrigin, context: nil).size.width
        } else {
            return 0
        }
    }
}

@objcMembers @objc(MJRefreshComponent)
open class RefreshComponent: UIView {
    
    public typealias RefreshComponentAction = () -> Void
        
    var scrollViewOriginalInset: UIEdgeInsets = .zero
    weak var scrollView: UIScrollView?
    
    private var refreshingTarget: Any?
    private var refreshingAction: Selector?
    
    public var fastAnimationDuration: TimeInterval = 0.25
    public var slowAnimationDuration: TimeInterval = 0.4
    
    public var state: RefreshState = .idle {
        didSet {
            MJDispatchOnMainQueue {
                self.setNeedsLayout()
            }
        }
    }
    public var isRefreshing: Bool {
        state == .refreshing || state == .willRefresh
    }
    
    public var pullingPercent: CGFloat = 0 {
        didSet {
            if isRefreshing { return }
            if isAutomaticallyChangeAlpha {
                alpha = pullingPercent
            }
        }
    }
    public var isAutomaticallyChangeAlpha: Bool = false {
        didSet {
            if isRefreshing { return }
            alpha = isAutomaticallyChangeAlpha ? pullingPercent : 1
        }
    }
    
    public var refreshingBlock: RefreshComponentAction = {}
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func prepare() {
        autoresizingMask = .flexibleWidth
        backgroundColor = .clear
    }
    
    open override func layoutSubviews() {
        placeSubViews()
        super.layoutSubviews()
    }
    
    public func placeSubViews() {
        
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if let newSuperview, !(newSuperview is UIScrollView) { return }
        removeObservers()
        guard let newSuperview = newSuperview as? UIScrollView else { return }
        
        scrollView = newSuperview
        frame.size.width = scrollView!.frame.width
        frame.origin.x = scrollView!.frame.origin.x
        
        scrollView?.alwaysBounceVertical = true
        scrollViewOriginalInset = scrollView!.inset
        
        addObservers()
    }
    
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        if state == .willRefresh {
            state = .refreshing
        }
    }
    
    func executeRefreshingCallback() {
        refreshingBlock()
        if let target = refreshingTarget as? AnyObject,
           let action = refreshingAction,
           target.responds(to: action) {
            _ = target.perform(action)
        }
    }
    
    public func setAnimationDisabled() {
        fastAnimationDuration = 0
        slowAnimationDuration = 0
    }
    
    public func scrollViewContentOffsetDidChange(_ change: [NSKeyValueChangeKey: Any]?) { }
    
    public func scrollViewContentSizeDidChange(_ change: [NSKeyValueChangeKey: Any]?) { }
        
    @objc public func i18nDidChange() {
        placeSubViews()
    }
    
    public func setRefreshing(target: Any, action: Selector) {
        refreshingTarget = target
        refreshingAction = action
    }
    
    public func beginRefreshing() {
        UIView.animate(withDuration: fastAnimationDuration) {
            self.alpha = 1;
        }
        pullingPercent = 1;
        if (window != nil) {
            state = .refreshing
        } else {
            if state != .refreshing {
                state = .willRefresh
                setNeedsDisplay()
            }
        }
    }
    
    public func endRefreshing() {
        MJDispatchOnMainQueue {
            self.state = .idle
        }
    }
}

extension RefreshComponent {
    func addObservers() {
        let options: NSKeyValueObservingOptions = [.new, .old]
        scrollView?.addObserver(self, forKeyPath: RefreshKey.contentOffset, options: options, context: nil)
        scrollView?.addObserver(self, forKeyPath: RefreshKey.contentSize, options: options, context: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(i18nDidChange), name: RefreshKey.didChangeLanguage, object: nil)
    }
    
    func removeObservers() {
        superview?.removeObserver(self, forKeyPath: RefreshKey.contentOffset)
        superview?.removeObserver(self, forKeyPath: RefreshKey.contentSize)
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard isUserInteractionEnabled else { return }
        if keyPath == RefreshKey.contentSize {
            scrollViewContentSizeDidChange(change)
        }
        
        if isHidden { return }
        if keyPath == RefreshKey.contentOffset {
            scrollViewContentOffsetDidChange(change)
        }
    }
}

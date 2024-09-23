//
//  RefreshNormalFooter.swift
//  MJRefresh
//
//  Created by yan on 2024/9/18.
//

import UIKit

@objcMembers @objc(MJRefreshBackNormalFooter)
open class RefreshNormalFooter: RefreshFooter {

    public lazy var stateLabel: UILabel = {
        let label = UILabel.mj.normalLabel
        label.text = titles[state]
        return label
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
        let contentStackView = UIStackView(arrangedSubviews: [arrowView, loadingView, stateLabel])
        contentStackView.spacing = RefreshKey.labelLeftInset
        addSubview(contentStackView)
        return contentStackView
    }()
    
    open override var state: RefreshState {
        didSet {
            switch state {
            case .idle:
                if oldValue == .refreshing {
                    arrowView.transform = CGAffineTransform(rotationAngle: 0.000001 - Double.pi)
                    UIView.animate(withDuration: slowAnimationDuration) {
                        self.loadingView.alpha = 0
                    } completion: { _ in
                        if self.state != .idle { return }
                        self.loadingView.alpha = 1
                        self.loadingView.stopAnimating()
                        self.arrowView.isHidden = false
                    }
                } else {
                    arrowView.isHidden = false
                    loadingView.stopAnimating()
                    UIView.animate(withDuration: fastAnimationDuration) {
                        self.arrowView.transform = CGAffineTransform(rotationAngle: 0.000001 - Double.pi)
                    }
                }
            case .pulling:
                arrowView.isHidden = false
                loadingView.stopAnimating()
                UIView.animate(withDuration: fastAnimationDuration) {
                    self.arrowView.transform = .identity
                }
            case .refreshing:
                arrowView.isHidden = true
                loadingView.startAnimating()
            case .noMoreData:
                arrowView.isHidden = true
                loadingView.stopAnimating()
            default: break
            }
            stateLabel.text = titles[state]
        }
    }
    
    private var titles: [RefreshState: String] = [
        .idle: Bundle.mj.localized(key: RefreshKey.footerIdleText) ?? "",
        .pulling: Bundle.mj.localized(key: RefreshKey.headerPullingText) ?? "",
        .refreshing: Bundle.mj.localized(key: RefreshKey.footerRefreshingText) ?? "",
        .noMoreData: Bundle.mj.localized(key: RefreshKey.footerNoMoreDataText) ?? "",
    ]
    
    open override func prepare() {
        super.prepare()
        stateLabel.isUserInteractionEnabled = true
        stateLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(stateLabelClick)))
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

private extension RefreshNormalFooter {
    @objc func stateLabelClick() {
        if state == .idle {
            beginRefreshing()
        }
    }
}

@objcMembers @objc(MJRefreshAutoNormalFooter)
open class RefreshAutoNormalFooter: RefreshNormalFooter {
    open override func prepare() {
        super.prepare()
        autoBack = false
    }
}

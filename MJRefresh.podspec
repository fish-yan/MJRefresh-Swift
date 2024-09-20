Pod::Spec.new do |s|
    s.name         = 'MJRefresh'
    s.version      = '0.0.1'
    s.summary      = 'An easy way to use pull-to-refresh'
    s.homepage     = 'https://github.com/fish-yan/MJRefresh'
    s.license      = 'MIT'
    s.authors      = {'fish-yan' => '757094197@qq.com'}
    s.platform     = :ios, '13.0'
    s.source       = {:git => 'https://github.com/fish-yan/MJRefresh.git', :tag => s.version}
    s.source_files = 'Sources/MJRefresh/**/*.{h,swift}'
    s.resource = 'Sources/MJRefresh/MJRefresh.bundle'
    s.resource_bundles = { 'MJRefresh.Privacy' => 'Sources/MJRefresh/PrivacyInfo.xcprivacy' }
    s.pod_target_xcconfig = { 'SWIFT_OBJC_INTERFACE_HEADER_NAME' => 'MJRefresh.h' }
end

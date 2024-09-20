// The Swift Programming Language
// https://docs.swift.org/swift-book

public protocol MJWrappable {
    associatedtype T
    var mj: T { get }
    static var mj: T.Type { get }
}

public extension MJWrappable {
    var mj: MJNameSpace<Self> {
        MJNameSpace<Self>(base: self)
    }
    
    static var mj: MJNameSpace<Self>.Type {
        MJNameSpace<Self>.self
    }
}

public struct MJNameSpace<Base> {
    var base: Base
    init(base: Base) {
        self.base = base
    }
}

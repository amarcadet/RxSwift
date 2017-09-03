//
//  Pairwise.swift
//  RxSwift
//
//  Created by Antoine Marcadet on 02/09/2017.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

extension ObservableType {
    
    /**
     Triggers on the `size`th elements and subsequent triggerings of the input observable.
     The `size`th triggering of the input observable passes the arguments from the N-`size`th to Nth triggering as an array.
     
     - seealso: [pairwise operator on reactivex.io](http://reactivex.io/documentation/operators/buffer.html)
     
     - parameter size: The N-wise size.
     - returns: An observable that triggers on successive `size` elements of observations from the input observable as an array.
     */
    public func nwise(_ size: Int) -> Observable<[Self.E]> {
        return Nwise(source: self.asObservable(), size: size)
    }
    
}

final fileprivate class NwiseSink<Element, O: ObserverType> : Sink<O>, ObserverType where O.E == [Element] {
    private let _size: Int
    private var _elements = [Element]()
    
    init(size: Int, observer: O, cancel: Cancelable) {
        _size = size
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(_ event: Event<Element>) {
        switch event {
        case .next(let element):
            _elements = Array(_elements.suffix(_size - 1) + [element])
            forwardOn(.next(_elements))
        case .error(let error):
            forwardOn(.error(error))
            dispose()
        case .completed:
            forwardOn(.completed)
            dispose()
        }
    }
}

final fileprivate class Nwise<Element>: Producer<[Element]> {
    private let _source: Observable<Element>
    private let _size: Int
    
    init(source: Observable<Element>, size: Int) {
        _source = source
        _size = size
    }
    
    override func run<O: ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == [Element] {
        let sink = NwiseSink(size: _size, observer: observer, cancel: cancel)
        let subscription = _source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
}


extension ObservableType {
    
    /**
     Triggers on the second and subsequent triggerings of the input observable.
     The Nth triggering of the input observable passes the arguments from the N-1th and Nth triggering as a pair.
     
     - seealso: [pairwise operator on reactivex.io](http://reactivex.io/documentation/operators/buffer.html)
     
     - returns: An observable that triggers on successive pairs of observations from the input observable as an array.
     */
    public func pairwise() -> Observable<(Self.E, Self.E)> {
        return Pairwise(source: self.asObservable())
    }
    
}

final fileprivate class PairwiseSink<Element, O: ObserverType> : Sink<O>, ObserverType where O.E == (Element, Element) {
    
    private var _previous: Element?
    
    func on(_ event: Event<Element>) {
        switch event {
        case .next(let element):
            if let previous = _previous {
                forwardOn(.next((previous, element)))
            }
            _previous = element
        case .error(let error):
            forwardOn(.error(error))
            dispose()
        case .completed:
            forwardOn(.completed)
            dispose()
        }
    }
}

final fileprivate class Pairwise<Element>: Producer<(Element, Element)> {
    private let _source: Observable<Element>
    
    init(source: Observable<Element>) {
        _source = source
    }
    
    override func run<O: ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == (Element, Element) {
        let sink = PairwiseSink(observer: observer, cancel: cancel)
        let subscription = _source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
}

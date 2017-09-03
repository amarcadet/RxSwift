//
//  Observable+PairwiseTests.swift
//  Tests
//
//  Created by Antoine Marcadet on 04/09/2017.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservablePairwiseTest : RxTest {
}

extension ObservablePairwiseTest {
    
    func testPairwise_Never() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            ])
        
        let res = scheduler.start { xs.pairwise() }
        
        let correctMessages: [Recorded<Event<(Int, Int)>>] = [
        ]
        
        let correctSubscriptions = [
            Subscription(200, 1000)
        ]
        
        print(res.events)
        
//        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testPairwise_OneElement() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            completed(300)
            ])
        
        let res = scheduler.start { xs.pairwise() }
        
        let correctMessages: [Recorded<Event<(Int, Int)>>] = [
        ]
        
        let correctSubscriptions = [
            Subscription(200, 300)
        ]
        
//        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testPairwise_ManyElements() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(300, 2),
            next(450, 3),
            next(600, 4),
            completed(750)
            ])
        
        let res = scheduler.start { xs.pairwise() }
        
        let correctMessages: [Recorded<Event<(Int, Int)>>] = [
            next(300, (1, 2)),
            next(450, (2, 3)),
            next(600, (3, 4)),
            completed(750)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 750)
        ]
        
//        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
}

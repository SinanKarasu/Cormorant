//
//  TestSets.swift
//  Cormorant
//
//  Created by Codex on 3/16/26.
//

import Foundation
import XCTest
@testable import Cormorant

class TestSets : InterpreterTest {
  func testCount() {
    expectThat("(count #{1 2 1})", shouldEvalTo: 2)
  }

  func testContains() {
    expectThat("(contains? #{1 2 3} 2)", shouldEvalTo: true)
    expectThat("(contains? #{1 2 3} 9)", shouldEvalTo: false)
    expectThat("(contains? [:a :b] 1)", shouldEvalTo: true)
    expectThat("(contains? [:a :b] 2)", shouldEvalTo: false)
  }

  func testIntoSet() {
    expectThat("(into #{} [1 2 2 3])", shouldEvalTo: set(containing: 1, 2, 3))
  }

  func testSetAsFunction() {
    let missing = keyword("missing")
    expectThat("(#{1 2} 2)", shouldEvalTo: 2)
    expectThat("(#{1 2} 9)", shouldEvalTo: .nilValue)
    expectThat("(#{1 2} 9 :missing)", shouldEvalTo: .keyword(missing))
  }

  func testSetPredicate() {
    expectThat("(set? #{1})", shouldEvalTo: true)
    expectThat("(set? [1])", shouldEvalTo: false)
  }
}

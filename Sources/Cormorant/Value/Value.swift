//
//  Created by Austin Zheng on 10/21/14.
//  Copyright (c) 2014 Austin Zheng. All rights reserved.
//

import Foundation

/// An opaque type representing a Vector data structure.
public typealias VectorType = [Value]

/// An opaque type representing a Map data structure.
public struct MapType: Collection, ExpressibleByDictionaryLiteral, Equatable {
  public typealias Element = (key: Value, value: Value)
  public typealias Index = Int

  private var entries: [Element]

  public init() {
    entries = []
  }

  public init(dictionaryLiteral elements: (Value, Value)...) {
    entries = []
    for (key, value) in elements {
      self[key] = value
    }
  }

  public var startIndex: Int { entries.startIndex }
  public var endIndex: Int { entries.endIndex }
  public var count: Int { entries.count }
  public var isEmpty: Bool { entries.isEmpty }

  public func index(after i: Int) -> Int {
    entries.index(after: i)
  }

  public subscript(position: Int) -> Element {
    entries[position]
  }

  public subscript(key: Value) -> Value? {
    get {
      entries.first(where: { $0.key == key })?.value
    }
    set {
      if let idx = entries.firstIndex(where: { $0.key == key }) {
        if let value = newValue {
          entries[idx].value = value
        }
        else {
          entries.remove(at: idx)
        }
      }
      else if let value = newValue {
        entries.append((key: key, value: value))
      }
    }
  }

  @discardableResult
  public mutating func removeValue(forKey key: Value) -> Value? {
    if let idx = entries.firstIndex(where: { $0.key == key }) {
      return entries.remove(at: idx).value
    }
    return nil
  }

  public static func ==(lhs: MapType, rhs: MapType) -> Bool {
    guard lhs.count == rhs.count else {
      return false
    }
    for (key, value) in lhs {
      guard rhs[key] == value else {
        return false
      }
    }
    return true
  }
}

/// An opaque type representing a Set data structure.
public struct SetType: Collection, ExpressibleByArrayLiteral, Equatable {
  public typealias Element = Value
  public typealias Index = Int

  private var entries: [Value]
  private var membership: Set<Value>

  public init() {
    entries = []
    membership = []
  }

  public init(arrayLiteral elements: Value...) {
    entries = []
    membership = []
    for element in elements {
      _ = insert(element)
    }
  }

  public var startIndex: Int { entries.startIndex }
  public var endIndex: Int { entries.endIndex }
  public var count: Int { entries.count }
  public var isEmpty: Bool { entries.isEmpty }

  public func index(after i: Int) -> Int {
    entries.index(after: i)
  }

  public subscript(position: Int) -> Value {
    entries[position]
  }

  public func contains(_ value: Value) -> Bool {
    membership.contains(value)
  }

  @discardableResult
  public mutating func insert(_ value: Value) -> Bool {
    let (inserted, _) = membership.insert(value)
    if inserted {
      entries.append(value)
    }
    return inserted
  }

  @discardableResult
  public mutating func remove(_ value: Value) -> Bool {
    guard membership.remove(value) != nil else {
      return false
    }
    if let index = entries.firstIndex(of: value) {
      entries.remove(at: index)
    }
    return true
  }
}

/// An opaque type representing a regular expression.
public typealias RegularExpressionType = NSRegularExpression

/// A sum type representing an atom, collection, or other fundamental Cormorant type.
public indirect enum Value: Hashable {
  case nilValue
  case bool(Bool)
  case int(Int)
  case float(Double)
  case char(Character)
  case string(String)
  case symbol(InternedSymbol)
  case keyword(InternedKeyword)
  case namespace(NamespaceContext)
  case `var`(VarType)
  case auxiliary(AuxiliaryType)
  case seq(SeqType)
  case vector(VectorType)
  case map(MapType)
  case set(SetType)
  case macroLiteral(Macro)
  case functionLiteral(Function)
  case builtInFunction(BuiltIn)
  case special(SpecialForm)
  case readerMacroForm(ReaderMacro)
}


// MARK: Var

/// An explicitly unbound representation of a Var. Note that an UnboundVar is not considered a Var.
final class UnboundVarObject : AuxiliaryType {
  let name : String
  var hashValue : Int { return name.hashValue }

  func describe() -> String { return "#<Unbound Unbound: #'\(name)>" }
  func debugDescribe() -> String { return "Object.UnboundVarObject(\(name))" }
  func toString() -> String { return describe() }

  func equals(_ that: AuxiliaryType) -> Bool {
    if let that = that as? UnboundVarObject {
      return self.name == that.name
    }
    return false
  }

  init(_ name: InternedSymbol, ctx: Context) {
    self.name = name.fullName(ctx)
  }
}

public func ==(lhs: VarType, rhs: VarType) -> Bool {
  return lhs.name == rhs.name && lhs.store == rhs.store
}

public final class VarType : Hashable {
  private(set) var store : Value? = nil

  /// A symbol used to determine how the Var is canonically named.
  let name : InternedSymbol

  public var hashValue : Int { return name.hashValue }
  public func hash(into hasher: inout Hasher) {
    hasher.combine(name)
  }

  /// Whether or not this Var is bound to a value.
  var isBound : Bool { return store != nil }

  func value(usingContext ctx: Context) -> Value {
    return store ?? .auxiliary(UnboundVarObject(name, ctx: ctx))
  }

  /// Bind a new value to this Var
  func bind(value: Value) { store = value }

  init(_ name: InternedSymbol, value: Value? = nil) { self.name = name; store = value }
}

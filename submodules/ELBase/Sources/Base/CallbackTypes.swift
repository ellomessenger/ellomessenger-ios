//
//  CallbackTypes.swift
//  ElloMessenger
//
//

import Foundation

public typealias VoidClosure = () -> ()

public typealias EventClosure<T> = (T) -> ()

public typealias TwoEventsClosure<T, E> = (T, E) -> ()

public typealias UpdateClosure<T,U> = (T) -> (U)

public typealias CallbackClosure<T> = EventClosure<EventClosure<T>?>

public typealias CallbackEventClosure<T,U> = EventClosure<(T,EventClosure<U>?)>

public typealias ReturnClosure<T> = () -> (T)

public typealias ErrorCallback = ((Error)->())

public typealias SuccessCallback<T> = ((T)->())

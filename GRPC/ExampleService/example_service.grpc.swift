//
// DO NOT EDIT.
//
// Generated by the protocol buffer compiler.
// Source: example_service.proto
//

//
// Copyright 2018, gRPC Authors All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
import Dispatch
import Foundation
import SwiftGRPC
import SwiftProtobuf

internal protocol Escrow_ExampleServicePingCall: ClientCallUnary {}

fileprivate final class Escrow_ExampleServicePingCallBase: ClientCallUnaryBase<Escrow_Input, Escrow_Output>, Escrow_ExampleServicePingCall {
  override class var method: String { return "/escrow.ExampleService/Ping" }
}


/// Instantiate Escrow_ExampleServiceServiceClient, then call methods of this protocol to make API calls.
internal protocol Escrow_ExampleServiceService: ServiceClient {
  /// Synchronous. Unary.
  func ping(_ request: Escrow_Input, metadata customMetadata: Metadata) throws -> Escrow_Output
  /// Asynchronous. Unary.
  @discardableResult
  func ping(_ request: Escrow_Input, metadata customMetadata: Metadata, completion: @escaping (Escrow_Output?, CallResult) -> Void) throws -> Escrow_ExampleServicePingCall

}

internal extension Escrow_ExampleServiceService {
  /// Synchronous. Unary.
  func ping(_ request: Escrow_Input) throws -> Escrow_Output {
    return try self.ping(request, metadata: self.metadata)
  }
  /// Asynchronous. Unary.
  @discardableResult
  func ping(_ request: Escrow_Input, completion: @escaping (Escrow_Output?, CallResult) -> Void) throws -> Escrow_ExampleServicePingCall {
    return try self.ping(request, metadata: self.metadata, completion: completion)
  }

}

internal final class Escrow_ExampleServiceServiceClient: ServiceClientBase, Escrow_ExampleServiceService {
  /// Synchronous. Unary.
  internal func ping(_ request: Escrow_Input, metadata customMetadata: Metadata) throws -> Escrow_Output {
    return try Escrow_ExampleServicePingCallBase(channel)
      .run(request: request, metadata: customMetadata)
  }
  /// Asynchronous. Unary.
  @discardableResult
  internal func ping(_ request: Escrow_Input, metadata customMetadata: Metadata, completion: @escaping (Escrow_Output?, CallResult) -> Void) throws -> Escrow_ExampleServicePingCall {
    return try Escrow_ExampleServicePingCallBase(channel)
      .start(request: request, metadata: customMetadata, completion: completion)
  }

}

/// To build a server, implement a class that conforms to this protocol.
/// If one of the methods returning `ServerStatus?` returns nil,
/// it is expected that you have already returned a status to the client by means of `session.close`.
internal protocol Escrow_ExampleServiceProvider: ServiceProvider {
  func ping(request: Escrow_Input, session: Escrow_ExampleServicePingSession) throws -> Escrow_Output
}

extension Escrow_ExampleServiceProvider {
  internal var serviceName: String { return "escrow.ExampleService" }

  /// Determines and calls the appropriate request handler, depending on the request's method.
  /// Throws `HandleMethodError.unknownMethod` for methods not handled by this service.
  internal func handleMethod(_ method: String, handler: Handler) throws -> ServerStatus? {
    switch method {
    case "/escrow.ExampleService/Ping":
      return try Escrow_ExampleServicePingSessionBase(
        handler: handler,
        providerBlock: { try self.ping(request: $0, session: $1 as! Escrow_ExampleServicePingSessionBase) })
          .run()
    default:
      throw HandleMethodError.unknownMethod
    }
  }
}

internal protocol Escrow_ExampleServicePingSession: ServerSessionUnary {}

fileprivate final class Escrow_ExampleServicePingSessionBase: ServerSessionUnaryBase<Escrow_Input, Escrow_Output>, Escrow_ExampleServicePingSession {}

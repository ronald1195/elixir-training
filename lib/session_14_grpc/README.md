# Session 14: gRPC Services

## Learning Objectives

By the end of this session, you will:
- Understand Protocol Buffers and gRPC concepts
- Define gRPC services with protobuf
- Implement gRPC servers and clients in Elixir
- Handle streaming RPCs

## Key Concepts

### Protocol Buffers

```protobuf
syntax = "proto3";

service CreditLimitService {
  rpc CheckLimit(CheckLimitRequest) returns (CheckLimitResponse);
  rpc StreamUpdates(StreamRequest) returns (stream LimitUpdate);
}

message CheckLimitRequest {
  string account_id = 1;
}

message CheckLimitResponse {
  int32 limit = 1;
  int32 available = 2;
}
```

### Implementing gRPC Server

```elixir
defmodule MyApp.CreditLimitServer do
  use GRPC.Server, service: MyApp.CreditLimitService.Service

  def check_limit(request, _stream) do
    %CheckLimitResponse{
      limit: 10000,
      available: 7500
    }
  end
end
```

## Exercises

### Exercise 1: Credit Limit Service

Implement a gRPC service for credit limit checking.

Open `lib/session_14_grpc/credit_limit_service.ex`.

```bash
mix test test/session_14_grpc/ --include pending
```

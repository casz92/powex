# Powex - Proof of Work Implementation in Elixir with Rust NIF

A high-performance Proof of Work implementation for Elixir using Rust NIFs (Native Implemented Functions). This library provides efficient SHA-256 based mining and validation capabilities with support for parallel processing.

## Features

- 🚀 **High Performance**: Rust implementation for CPU-intensive operations
- 🔄 **Parallel Processing**: Multi-threaded mining support
- 🔒 **SHA-256 Hashing**: Industry-standard cryptographic hashing
- ✅ **Comprehensive Validation**: Built-in nonce validation
- 📊 **Flexible Difficulty**: Configurable difficulty levels
- 🧪 **Well Tested**: Comprehensive test suite

## Installation

Add `powex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:powex, "~> 0.1.0"}
  ]
end
```

## Requirements

- Elixir 1.14+
- Rust 1.70+ (for compilation)
- Erlang/OTP 25+

## Usage

### Basic Proof of Work Computation

```elixir
# Compute a nonce for given data and difficulty
{:ok, nonce} = Powex.compute("transaction_data", 5)

# Validate the computed nonce
valid = Powex.valid?("transaction_data", nonce, 5)
# => true
```

### Parallel Processing

For better performance on multi-core systems:

```elixir
# Use 4 threads for parallel computation
{:ok, nonce} = Powex.compute_parallel("blockchain_data", 6, 4)

# Validate the result
Powex.valid?("blockchain_data", nonce, 6)
# => true
```

### Hash Inspection

Get the actual hash for debugging or verification:

```elixir
{:ok, hash} = Powex.get_hash("data", 12345)
# => {:ok, "a1b2c3d4e5f6..."}
```

## API Reference

### `Powex.compute/2`

Computes a Proof of Work nonce for the given data and difficulty.

**Parameters:**
- `data` (binary): The input data to hash
- `difficulty` (integer): Number of leading zeros required (0-64)

**Returns:**
- `{:ok, nonce}` - Valid nonce found
- `{:error, reason}` - Computation failed

### `Powex.valid?/3`

Validates if a nonce produces a valid Proof of Work.

**Parameters:**
- `data` (binary): The input data
- `nonce` (integer): The nonce to validate
- `difficulty` (integer): Required difficulty level

**Returns:**
- `true` - Nonce is valid
- `false` - Nonce is invalid

### `Powex.compute_parallel/3`

Parallel Proof of Work computation using multiple threads.

**Parameters:**
- `data` (binary): The input data to hash
- `difficulty` (integer): Number of leading zeros required
- `threads` (integer): Number of threads to use (1-64)

**Returns:**
- `{:ok, nonce}` - Valid nonce found
- `{:error, reason}` - Computation failed

### `Powex.get_hash/2`

Gets the SHA-256 hash for given data and nonce.

**Parameters:**
- `data` (binary): The input data
- `nonce` (integer): The nonce value

**Returns:**
- `{:ok, hash}` - Hex-encoded hash string
- `{:error, reason}` - Hashing failed

## Examples

### Blockchain Mining Simulation

```elixir
defmodule BlockchainMiner do
  def mine_block(transactions, previous_hash, difficulty) do
    block_data = "#{previous_hash}#{Enum.join(transactions, ",")}"
    
    case Powex.compute_parallel(block_data, difficulty, 8) do
      {:ok, nonce} ->
        {:ok, hash} = Powex.get_hash(block_data, nonce)
        %{
          transactions: transactions,
          previous_hash: previous_hash,
          nonce: nonce,
          hash: hash,
          difficulty: difficulty
        }
      
      {:error, reason} ->
        {:error, "Mining failed: #{reason}"}
    end
  end
  
  def validate_block(block) do
    block_data = "#{block.previous_hash}#{Enum.join(block.transactions, ",")}"
    Powex.valid?(block_data, block.nonce, block.difficulty)
  end
end

# Mine a new block
block = BlockchainMiner.mine_block(
  ["tx1", "tx2", "tx3"], 
  "previous_block_hash", 
  4
)

# Validate the block
BlockchainMiner.validate_block(block)
# => true
```

### Performance Benchmarking

```elixir
defmodule Powex.Benchmark do
  def benchmark_difficulty(data, max_difficulty) do
    Enum.map(1..max_difficulty, fn difficulty ->
      {time, {:ok, nonce}} = :timer.tc(Powex, :compute, [data, difficulty])
      
      %{
        difficulty: difficulty,
        time_microseconds: time,
        nonce: nonce
      }
    end)
  end
end

# Benchmark different difficulties
results = Powex.Benchmark.benchmark_difficulty("benchmark_data", 6)
```

## Performance Considerations

- **Difficulty Scaling**: Computation time increases exponentially with difficulty
- **Parallel Processing**: Use `compute_parallel/3` for difficulties > 4
- **Thread Count**: Optimal thread count usually equals CPU core count
- **Memory Usage**: Minimal memory footprint, CPU-bound operation

## Building from Source

```bash
# Clone the repository
git clone <repository_url>
cd powex

# Install dependencies
mix deps.get

# Compile (this will build the Rust NIF)
mix compile

# Run tests
mix test
```

## Benchmarks

```
mix run examples/benchmark.exs

=== Powex Performance Benchmark ===

1. Sequential vs Parallel Performance:
   Sequential: 96.56 ms (nonce: 24294)
   Parallel:   97.79 ms (nonce: 24294)
   Speedup:    0.99x

2. Difficulty Scaling Analysis:
   Difficulty 1: 0.0 ms (nonce: 0)
     Hash: 0b1fca060b522c417263...
   Difficulty 2: 0.51 ms (nonce: 133)
     Hash: 001a95cc256f9155afa5...
   Difficulty 3: 60.62 ms (nonce: 15715)
     Hash: 000a950b8318c1215e9c...
   Difficulty 4: 170.5 ms (nonce: 43671)
     Hash: 0000f91202ddfac2fc89...
   Difficulty 5: 2739.71 ms (nonce: 716595)
     Hash: 00000cb04780051c45f5...

3. Thread Scaling Performance:
   1 threads: 53.25 ms (nonce: 13199)
   2 threads: 52.53 ms (nonce: 13199)
   4 threads: 60.11 ms (nonce: 13199)
   8 threads: 79.46 ms (nonce: 13199)

4. Hash Rate Estimation:
   Computed 2776 hashes in 10.75 ms
   Hash rate: 258185.0 H/s

=== Benchmark completed ===
```

Thank you for making it this far 🤗

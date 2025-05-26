# Basic Powex usage examples
# Run with: mix run examples/basic_usage.exs

IO.puts("=== Powex Basic Usage Examples ===\n")

# Example 1: Simple computation
IO.puts("1. Simple Proof of Work computation:")
data = "Hello, Blockchain!"
difficulty = 3

IO.puts("   Data: #{inspect(data)}")
IO.puts("   Difficulty: #{difficulty}")

{time, {:ok, nonce}} = :timer.tc(Powex, :compute, [data, difficulty])
IO.puts("   Computed nonce: #{nonce}")
IO.puts("   Time taken: #{time / 1000} ms")

# Validate the result
valid = Powex.valid?(data, nonce, difficulty)
IO.puts("   Valid: #{valid}")

# Get the hash
{:ok, hash} = Powex.get_hash(data, nonce)
IO.puts("   Hash: #{hash}")
IO.puts("   Leading zeros: #{String.duplicate("0", difficulty)}")
IO.puts("")

# Example 2: Parallel computation
IO.puts("2. Parallel Proof of Work computation:")
parallel_data = "Parallel mining example"
parallel_difficulty = 4
threads = 4

IO.puts("   Data: #{inspect(parallel_data)}")
IO.puts("   Difficulty: #{parallel_difficulty}")
IO.puts("   Threads: #{threads}")

{parallel_time, {:ok, parallel_nonce}} =
  :timer.tc(Powex, :compute_parallel, [parallel_data, parallel_difficulty, threads])

IO.puts("   Computed nonce: #{parallel_nonce}")
IO.puts("   Time taken: #{parallel_time / 1000} ms")

# Validate parallel result
parallel_valid = Powex.valid?(parallel_data, parallel_nonce, parallel_difficulty)
IO.puts("   Valid: #{parallel_valid}")
IO.puts("")

# Example 3: Difficulty comparison
IO.puts("3. Difficulty scaling demonstration:")
base_data = "Difficulty scaling test"

Enum.each([1, 2, 3, 4], fn diff ->
  {scale_time, {:ok, scale_nonce}} = :timer.tc(Powex, :compute, [base_data, diff])
  {:ok, scale_hash} = Powex.get_hash(base_data, scale_nonce)

  IO.puts("   Difficulty #{diff}:")
  IO.puts("     Nonce: #{scale_nonce}")
  IO.puts("     Time: #{Float.round(scale_time / 1000, 2)} ms")
  IO.puts("     Hash: #{String.slice(scale_hash, 0, 16)}...")
  IO.puts("     Leading zeros: #{String.slice(scale_hash, 0, diff)}")
end)

IO.puts("\n=== Examples completed ===")

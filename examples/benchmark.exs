# Performance benchmark for Powex implementation
# Run with: mix run examples/benchmark.exs

defmodule POWBenchmark do
  def run_benchmark do
    IO.puts("=== Powex Performance Benchmark ===\n")

    # Test data
    data = "benchmark_test_data_#{:rand.uniform(1000)}"

    # Sequential vs Parallel comparison
    IO.puts("1. Sequential vs Parallel Performance:")
    difficulty = 4

    {seq_time, {:ok, seq_nonce}} = :timer.tc(Powex, :compute, [data, difficulty])
    {par_time, {:ok, par_nonce}} = :timer.tc(Powex, :compute_parallel, [data, difficulty, 4])

    IO.puts("   Sequential: #{Float.round(seq_time / 1000, 2)} ms (nonce: #{seq_nonce})")
    IO.puts("   Parallel:   #{Float.round(par_time / 1000, 2)} ms (nonce: #{par_nonce})")
    IO.puts("   Speedup:    #{Float.round(seq_time / par_time, 2)}x")
    IO.puts("")

    # Difficulty scaling
    IO.puts("2. Difficulty Scaling Analysis:")
    base_data = "scaling_test"

    Enum.each([1, 2, 3, 4, 5], fn diff ->
      {time, {:ok, nonce}} = :timer.tc(Powex, :compute, [base_data, diff])
      {:ok, hash} = Powex.get_hash(base_data, nonce)

      IO.puts("   Difficulty #{diff}: #{Float.round(time / 1000, 2)} ms (nonce: #{nonce})")
      IO.puts("     Hash: #{String.slice(hash, 0, 20)}...")
    end)

    IO.puts("")

    # Thread scaling
    IO.puts("3. Thread Scaling Performance:")
    thread_data = "thread_scaling_test"
    thread_difficulty = 4

    Enum.each([1, 2, 4, 8], fn threads ->
      {time, {:ok, nonce}} = :timer.tc(Powex, :compute_parallel, [thread_data, thread_difficulty, threads])
      IO.puts("   #{threads} threads: #{Float.round(time / 1000, 2)} ms (nonce: #{nonce})")
    end)

    IO.puts("")

    # Hash rate calculation
    IO.puts("4. Hash Rate Estimation:")
    hash_test_data = "hash_rate_test"
    hash_difficulty = 3

    {time, {:ok, nonce}} = :timer.tc(Powex, :compute, [hash_test_data, hash_difficulty])
    hash_rate = nonce / (time / 1_000_000)  # hashes per second

    IO.puts("   Computed #{nonce} hashes in #{Float.round(time / 1000, 2)} ms")
    IO.puts("   Hash rate: #{Float.round(hash_rate, 0)} H/s")

    IO.puts("\n=== Benchmark completed ===")
  end
end

POWBenchmark.run_benchmark()

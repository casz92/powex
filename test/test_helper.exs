ExUnit.start()

# Configure test timeout for potentially long-running PoW computations
ExUnit.configure(timeout: 60_000)

defmodule POWTestHelper do
  @moduledoc """
  Helper functions for Powex tests
  """

  @doc """
  Generates random test data of specified length
  """
  def random_data(length \\ 32) do
    :crypto.strong_rand_bytes(length)
  end

  @doc """
  Measures execution time of a function
  """
  def measure_time(fun) do
    {time, result} = :timer.tc(fun)
    {time / 1000, result}  # Convert to milliseconds
  end

  @doc """
  Validates that a hash meets the specified difficulty
  """
  def hash_meets_difficulty?(hash, difficulty) do
    required_zeros = String.duplicate("0", difficulty)
    String.starts_with?(hash, required_zeros)
  end

  @doc """
  Generates test cases for different difficulties
  """
  def difficulty_test_cases do
    [
      {0, "zero_difficulty"},
      {1, "low_difficulty"},
      {2, "medium_low_difficulty"},
      {3, "medium_difficulty"},
      {4, "medium_high_difficulty"}
    ]
  end
end

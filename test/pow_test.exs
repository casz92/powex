defmodule POWTest do
  use ExUnit.Case
  doctest Powex

  describe "compute/2" do
    test "computes valid nonce for difficulty 0" do
      assert {:ok, nonce} = Powex.compute("test data", 0)
      assert is_integer(nonce)
      assert nonce >= 0
    end

    test "computes valid nonce for low difficulty" do
      data = "hello world"
      difficulty = 2

      assert {:ok, nonce} = Powex.compute(data, difficulty)
      assert is_integer(nonce)
      assert Powex.valid?(data, nonce, difficulty)
    end

    test "computes valid nonce for medium difficulty" do
      data = "blockchain"
      difficulty = 4

      assert {:ok, nonce} = Powex.compute(data, difficulty)
      assert is_integer(nonce)
      assert Powex.valid?(data, nonce, difficulty)
    end

    test "returns error for extremely high difficulty" do
      assert {:error, _reason} = Powex.compute("test", 65)
    end

    test "works with binary data" do
      data = <<1, 2, 3, 4, 5>>
      difficulty = 2

      assert {:ok, nonce} = Powex.compute(data, difficulty)
      assert Powex.valid?(data, nonce, difficulty)
    end

    test "works with empty data" do
      assert {:ok, nonce} = Powex.compute("", 1)
      assert Powex.valid?("", nonce, 1)
    end
  end

  describe "valid?/3" do
    test "validates correct nonce" do
      data = "test validation"
      difficulty = 3

      {:ok, nonce} = Powex.compute(data, difficulty)
      assert Powex.valid?(data, nonce, difficulty)
    end

    test "rejects incorrect nonce" do
      data = "test validation"
      difficulty = 3

      {:ok, correct_nonce} = Powex.compute(data, difficulty)
      wrong_nonce = correct_nonce + 1

      refute Powex.valid?(data, wrong_nonce, difficulty)
    end

    test "validates with difficulty 0" do
      assert Powex.valid?("any data", 12345, 0)
    end

    test "rejects when difficulty not met" do
      # This nonce is very unlikely to meet difficulty 10
      refute Powex.valid?("test", 1, 10)
    end

    test "works with binary data" do
      data = <<255, 254, 253>>
      difficulty = 2

      {:ok, nonce} = Powex.compute(data, difficulty)
      assert Powex.valid?(data, nonce, difficulty)
    end
  end

  describe "compute_parallel/3" do
    test "computes valid nonce using parallel processing" do
      data = "parallel test"
      difficulty = 3
      threads = 4

      assert {:ok, nonce} = Powex.compute_parallel(data, difficulty, threads)
      assert is_integer(nonce)
      assert Powex.valid?(data, nonce, difficulty)
    end

    test "returns error for invalid thread count" do
      assert {:error, _reason} = Powex.compute_parallel("test", 2, 0)
      assert {:error, _reason} = Powex.compute_parallel("test", 2, 100)
    end

    test "returns error for extremely high difficulty" do
      assert {:error, _reason} = Powex.compute_parallel("test", 65, 4)
    end

    test "works with single thread" do
      data = "single thread"
      difficulty = 2

      assert {:ok, nonce} = Powex.compute_parallel(data, difficulty, 1)
      assert Powex.valid?(data, nonce, difficulty)
    end
  end

  describe "get_hash/2" do
    test "returns hash for given data and nonce" do
      data = "test data"
      nonce = 12345

      assert {:ok, hash} = Powex.get_hash(data, nonce)
      assert is_binary(hash)
      assert String.length(hash) == 64  # SHA-256 hex string length
      assert String.match?(hash, ~r/^[0-9a-f]+$/)
    end

    test "returns consistent hash for same inputs" do
      data = "consistent test"
      nonce = 98765

      {:ok, hash1} = Powex.get_hash(data, nonce)
      {:ok, hash2} = Powex.get_hash(data, nonce)

      assert hash1 == hash2
    end

    test "returns different hash for different inputs" do
      nonce = 555

      {:ok, hash1} = Powex.get_hash("data1", nonce)
      {:ok, hash2} = Powex.get_hash("data2", nonce)

      assert hash1 != hash2
    end

    test "works with binary data" do
      data = <<1, 2, 3>>
      nonce = 777

      assert {:ok, hash} = Powex.get_hash(data, nonce)
      assert String.length(hash) == 64
    end
  end

  describe "integration tests" do
    test "complete workflow: compute -> validate -> get_hash" do
      data = "integration test data"
      difficulty = 3

      # Compute a valid nonce
      {:ok, nonce} = Powex.compute(data, difficulty)

      # Validate the nonce
      assert Powex.valid?(data, nonce, difficulty)

      # Get the hash and verify it meets difficulty
      {:ok, hash} = Powex.get_hash(data, nonce)
      leading_zeros = String.duplicate("0", difficulty)
      assert String.starts_with?(hash, leading_zeros)
    end

    test "parallel vs sequential computation produces valid results" do
      data = "comparison test"
      difficulty = 2

      {:ok, nonce1} = Powex.compute(data, difficulty)
      {:ok, nonce2} = Powex.compute_parallel(data, difficulty, 2)

      # Both should be valid (though potentially different)
      assert Powex.valid?(data, nonce1, difficulty)
      assert Powex.valid?(data, nonce2, difficulty)
    end
  end
end

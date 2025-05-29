defmodule Powex do
  @moduledoc """
  Proof of Work implementation using Rust NIF for high-performance mining.

  This module provides functions to compute and validate Proof of Work using SHA-256 hashing.
  The implementation uses Rust for performance-critical operations.
  """

  use Rustler,
    otp_app: :powex,
    crate: "powex_nif",
    path: "native/powex_nif"

  @doc """
  Computes a Proof of Work nonce for the given data and difficulty.

  ## Parameters
  - `data`: The input data (string or binary) to hash
  - `difficulty`: Number of leading zeros required in the hash (integer)

  ## Returns
  - `{:ok, nonce}` when a valid nonce is found
  - `{:error, reason}` if computation fails

  ## Examples
      iex> {:ok, nonce} = Powex.compute("hello world", 4)
      iex> is_integer(nonce)
      true

      iex> Powex.compute("", 0)
      {:ok, 0}
  """
  @spec compute(binary(), non_neg_integer()) :: {:ok, non_neg_integer()} | {:error, String.t()}
  def compute(_data, _difficulty), do: :erlang.nif_error(:nif_not_loaded)

  @doc """
  Validates if a nonce produces a valid Proof of Work for the given data and difficulty.

  ## Parameters
  - `data`: The input data (string or binary) that was hashed
  - `nonce`: The nonce value to validate (integer)
  - `difficulty`: Number of leading zeros required in the hash (integer)

  ## Returns
  - `true` if the nonce is valid for the given difficulty
  - `false` if the nonce is invalid

  ## Examples
      iex> {:ok, nonce} = Powex.compute("test data", 3)
      iex> Powex.valid?("test data", nonce, 3)
      true

      iex> Powex.valid?("test data", 12345, 3)
      false
  """
  @spec valid?(binary(), non_neg_integer(), non_neg_integer()) :: boolean()
  def valid?(_data, _nonce, _difficulty), do: :erlang.nif_error(:nif_not_loaded)

  @doc """
  Computes a Proof of Work nonce using parallel processing for improved performance.

  ## Parameters
  - `data`: The input data (string or binary) to hash
  - `difficulty`: Number of leading zeros required in the hash (integer)
  - `threads`: Number of threads to use for parallel computation (default: number of CPU cores)

  ## Returns
  - `{:ok, nonce}` when a valid nonce is found
  - `{:error, reason}` if computation fails

  ## Examples
      iex> {:ok, nonce} = Powex.compute_parallel("hello world", 4, 4)
      iex> is_integer(nonce)
      true
  """
  @spec compute_parallel(binary(), non_neg_integer(), pos_integer()) ::
    {:ok, non_neg_integer()} | {:error, String.t()}
  def compute_parallel(_data, _difficulty, _threads), do: :erlang.nif_error(:nif_not_loaded)

  @doc """
  Gets the hash for given data and nonce combination.

  ## Parameters
  - `data`: The input data (string or binary)
  - `nonce`: The nonce value (integer)

  ## Returns
  - `{:ok, hash}` where hash is the SHA-256 hash as a hex string
  - `{:error, reason}` if hashing fails

  ## Examples
      iex> {:ok, hash} = Powex.get_hash("test", 123)
      iex> String.length(hash)
      64
  """
  @spec get_hash(binary(), non_neg_integer()) :: {:ok, String.t()} | {:error, String.t()}
  def get_hash(_data, _nonce), do: :erlang.nif_error(:nif_not_loaded)
end

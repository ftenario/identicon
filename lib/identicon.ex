defmodule Identicon do
  @moduledoc """
  Documentation for Identicon.
  """

  @doc """
    main entry point. Get the passed parameter and pipe to hash_input function
  """
  def main(input) do
    input
    |> hash_input
  end

  @doc """
    Get the passed parameter and do a hashing using the md5 algorithm.
    Pipe the result to binary.bin_to_list to get 16 Hex list
  """
  def hash_input(input) do
    :crypto.hash(:md5, input)
    |> :binary.bin_to_list
  end

end

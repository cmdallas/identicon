defmodule Identicon do
  @moduledoc """
    Generate you an identicon!
  """

  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
  end

  @doc """
    MD5 hash of the input string

  ## Example

        iex> Identicon.hash_input("Chris")
        %Identicon.Image{
          seed: [148, 79, 172, 254, 177, 83, 180, 240, 25, 22, 160, 241, 102, 252, 195,
            21]
        }

  """
  def hash_input(input) do
    seed =
      :crypto.hash(:md5, input)
      |> :binary.bin_to_list()

    %Identicon.Image{seed: seed}
  end

  @doc """
    Generate a color using the first 3 digits of the `Identicon.Image` seed

  ## Example

        iex> image = Identicon.hash_input("Chris") |> Identicon.pick_color
        iex> image.rgb
        {148, 79, 172}

  """
  def pick_color(%Identicon.Image{seed: [r, g, b | _tail]} = image) do
    %Identicon.Image{image | rgb: {r, g, b}}
  end

  @doc """
    Take idx 0, 1 of a list and duplicate idx 1 as idx 3 and idx 0 as idx 4

  ## Example

        iex> Identicon.mirror_row([0, 1, 2])
        [0, 1, 2, 1, 0]

  """
  def mirror_row(row) do
    [first, second | _tail] = row
    row ++ [second, first]
  end

  @doc """
    Generate the 5x5 grid

  ## Example

        iex> (Identicon.hash_input("Chris")
        iex> |> Identicon.pick_color
        iex> |> Identicon.build_grid)
        %Identicon.Image{
          grid: [
            {148, 0},
            {79, 1},
            {172, 2},
            {79, 3},
            {148, 4},
            {254, 5},
            {177, 6},
            {83, 7},
            {177, 8},
            {254, 9},
            {180, 10},
            {240, 11},
            {25, 12},
            {240, 13},
            {180, 14},
            {22, 15},
            {160, 16},
            {241, 17},
            {160, 18},
            {22, 19},
            {102, 20},
            {252, 21},
            {195, 22},
            {252, 23},
            {102, 24}
          ],
          rgb: {148, 79, 172},
          seed: [148, 79, 172, 254, 177, 83, 180, 240, 25, 22, 160, 241, 102, 252, 195,
           21]
        }

  """
  def build_grid(%Identicon.Image{seed: seed} = image) do
    grid =
      seed
      |> Enum.chunk(3)
      |> Enum.map(&mirror_row/1)
      |> List.flatten()
      |> Enum.with_index()

    %Identicon.Image{image | grid: grid}
  end
end

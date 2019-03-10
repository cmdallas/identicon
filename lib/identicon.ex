defmodule Identicon do
  @moduledoc """
    Generate you an identicon!
  """

  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
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

  @doc """
    Filter any squares that contain an odd value

  ## Example

        iex> (Identicon.hash_input("Chris")
        iex> |> Identicon.pick_color
        iex> |> Identicon.build_grid
        iex> |> Identicon.filter_odd_squares)
        %Identicon.Image{
          grid: [
            {148, 0},
            {172, 2},
            {148, 4},
            {254, 5},
            {254, 9},
            {180, 10},
            {240, 11},
            {240, 13},
            {180, 14},
            {22, 15},
            {160, 16},
            {160, 18},
            {22, 19},
            {102, 20},
            {252, 21},
            {252, 23},
            {102, 24}
          ],
          rgb: {148, 79, 172},
          seed: [148, 79, 172, 254, 177, 83, 180, 240, 25, 22, 160, 241, 102, 252, 195,
           21]
        }

  """
  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid =
      Enum.filter(grid, fn {hex_value, _idx} ->
        rem(hex_value, 2) == 0
      end)

    %Identicon.Image{image | grid: grid}
  end

  @doc """
    For each tuple, produce a set of X,Y coords for top left and bottom right points
    of each square

    ## Example

          iex> (Identicon.hash_input("Chris")
          iex> |> Identicon.pick_color
          iex> |> Identicon.build_grid
          iex> |> Identicon.filter_odd_squares
          iex> |> Identicon.build_pixel_map)
          %Identicon.Image{
            grid: [
              {148, 0},
              {172, 2},
              {148, 4},
              {254, 5},
              {254, 9},
              {180, 10},
              {240, 11},
              {240, 13},
              {180, 14},
              {22, 15},
              {160, 16},
              {160, 18},
              {22, 19},
              {102, 20},
              {252, 21},
              {252, 23},
              {102, 24}
            ],
            pixel_map: [
              {{0, 0}, {50, 50}},
              {{100, 0}, {150, 50}},
              {{200, 0}, {250, 50}},
              {{0, 50}, {50, 100}},
              {{200, 50}, {250, 100}},
              {{0, 100}, {50, 150}},
              {{50, 100}, {100, 150}},
              {{150, 100}, {200, 150}},
              {{200, 100}, {250, 150}},
              {{0, 150}, {50, 200}},
              {{50, 150}, {100, 200}},
              {{150, 150}, {200, 200}},
              {{200, 150}, {250, 200}},
              {{0, 200}, {50, 250}},
              {{50, 200}, {100, 250}},
              {{150, 200}, {200, 250}},
              {{200, 200}, {250, 250}}
            ],
            rgb: {148, 79, 172},
            seed: [148, 79, 172, 254, 177, 83, 180, 240, 25, 22, 160, 241, 102, 252, 195,
             21]
          }

  """
  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map =
      Enum.map(grid, fn {_hex_value, idx} ->
        horizontal = rem(idx, 5) * 50
        vertical = div(idx, 5) * 50

        top_left = {horizontal, vertical}
        bottom_right = {horizontal + 50, vertical + 50}

        {top_left, bottom_right}
      end)

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  @doc """
    Use the Erlang Graphical Drawer to generate an identicon
  """
  def draw_image(%Identicon.Image{rgb: rgb, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(rgb)

    Enum.each(pixel_map, fn {start, stop} ->
      :egd.filledRectangle(image, start, stop, fill)
    end)

    :egd.render(image)
  end

  def save_image(image, input) do
    File.write("#{input}.png", image)
  end
end

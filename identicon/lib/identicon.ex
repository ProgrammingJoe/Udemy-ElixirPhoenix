defmodule Identicon do
  @moduledoc """
  Documentation for Identicon.
  """

  @doc """
  Main function

  ## Examples

      iex> Identicon.main("Joe")
      :ok

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
  Saves an image with filename `filename`
  """
  def save_image(image, filename) do
    File.write("#{filename}.png", image)
  end

  @doc """
  Converts an Image into an image file
  """
  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  @doc """
  Creates pixel blocks for every grid value

  ## Examples

      iex> Identicon.build_pixel_map(%Identicon.Image{grid: [{123, 0}, {123, 1}, {60, 2}, {123, 3}, {123, 4}, {123, 5}, {45, 6}, {60, 7}, {45, 8}, {123, 9}]})
      %Identicon.Image{
        grid: [{123, 0}, {123, 1}, {60, 2}, {123, 3}, {123, 4}, {123, 5}, {45, 6}, {60, 7}, {45, 8}, {123, 9}],
        pixel_map: [{{0, 0}, {50, 50}}, {{50, 0}, {100, 50}},
          {{100, 0}, {150, 50}}, {{150, 0}, {200, 50}},
          {{200, 0}, {250, 50}}, {{0, 50}, {50, 100}},
          {{50, 50}, {100, 100}}, {{100, 50}, {150, 100}},
          {{150, 50}, {200, 100}}, {{200, 50}, {250, 100}}]
      }

  """
  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({_code, index}) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50

      top_left = {horizontal, vertical}

      bottom_right = {horizontal + 50, vertical + 50}

      {top_left, bottom_right}
    end

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  @doc """
  Converts a string into a hash

  ## Examples

      iex> Identicon.hash_input("Joe")
      %Identicon.Image{hex: [58, 54, 136, 24, 183, 52, 29, 72, 102, 14, 141, 214, 197, 167, 125, 190]}

  """
  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end

  @doc """
  Converts the first 3 hex values of an image into a color

  ## Examples

      iex> Identicon.pick_color(%Identicon.Image{hex: [123, 123, 60, 123, 45, 60]})
      %Identicon.Image{
        hex: [123, 123, 60, 123, 45, 60],
        color: {123, 123, 60},
      }

  """
  def pick_color(%Identicon.Image{hex: [red, green, blue | _tail]} = image) do
    %Identicon.Image{image | color: {red, green, blue}}
  end

  @doc """
  Converts a list of hex values into grid values

  ## Examples

      iex> Identicon.build_grid(%Identicon.Image{hex: [123, 123, 60, 123, 45, 60]})
      %Identicon.Image{
        grid: [{123, 0}, {123, 1}, {60, 2}, {123, 3}, {123, 4}, {123, 5}, {45, 6}, {60, 7}, {45, 8}, {123, 9}],
        hex: [123, 123, 60, 123, 45, 60],
      }


  """
  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid =
      hex
      |> Enum.chunk(3)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index

    %Identicon.Image{image | grid: grid}
  end

  @doc """
  Mirrors a list

  ## Examples

      iex> Identicon.mirror_row([1, 2, 3])
      [1, 2, 3, 2, 1]

  """
  def mirror_row(row) do
    [first, second | _tail] = row
    row ++ [second, first]
  end

  @doc """
  Removes the odd values from the grid

  ## Examples

      iex> Identicon.filter_odd_squares(%Identicon.Image{color: nil, grid: [{123, 0}, {123, 1}, {60, 2}, {123, 3}, {123, 4}, {123, 5}, {45, 6}, {60, 7}, {45, 8}, {123, 9}], hex: nil, pixel_map: nil})
      %Identicon.Image{color: nil, grid: [{60, 2}, {60, 7}], hex: nil, pixel_map: nil}

  """
  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter grid, fn({code, _index}) ->
      rem(code, 2) == 0
    end

    %Identicon.Image{image | grid: grid}
  end

end

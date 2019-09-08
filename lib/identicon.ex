defmodule Identicon do

  @doc """
  Creates a PNG file with the given `filename` with a unique
  representation of `input`
  """
  def main(input, filename) do
    input
    |> hash_string
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(filename)
  end

  defp hash_string(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list()

    %Identicon.Image{hex: hex}
  end

  defp pick_color(%Identicon.Image{hex: [r, g, b | _]} = image) do
    %Identicon.Image{image | color: {r, g, b}}
  end

  defp build_grid(%Identicon.Image{hex: hex} = image) do
    grid = hex
    |> Enum.chunk_every(3, 3, :discard)
    |> mirror_rows
    |> List.flatten
    |> Enum.with_index

    %Identicon.Image{image | grid: grid}

  end

  defp mirror_rows(hex) do
    hex
    |> Enum.map(fn [x, y, z] -> [x, y, z, y, x] end)
  end

  defp filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    odds = Enum.filter(grid, fn {value, _} -> rem(value, 2) == 0 end)
    %Identicon.Image{image | grid: odds}
  end

  defp build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map(grid, fn {_, index} -> 
      h = rem(index, 5) * 50
      v = div(index, 5) * 50

      {{h, v}, {h + 50, v + 50}}
       end)

    %Identicon.Image{image | pixel_map: pixel_map}
      
  end

  defp draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each(pixel_map, fn {start, stop} -> 
      :egd.filledRectangle(image, start, stop, fill)
    end)

    :egd.render(image)
  end

  defp save_image(image, filename) do
    File.write("#{filename}.png", image)
  end


end

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
    |> pick_color2
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  def save_image(image, input) do
    File.write("#{input}.png", image)
  end

  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250) 
    fill = :egd.color(color)
    
    Enum.each pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  @doc """
    - passed the Image struct
    - Enum.map to get each element and apply the anonymous function.
    - Get the horizontal data. 
    - Get the vertical data
    - construct the top left and bottom right positions
    - return a tuple of top_left and bottom_right
    - Update the Image struct with the new struct element (pixel_map)
  """
  def build_pixel_map(%Identicon.Image{ grid: grid} = image) do
    pixel_map = Enum.map grid, fn({_code, index}) -> 
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 5
      top_left = {horizontal, vertical}
      bottom_right = {horizontal+50, vertical + 50}

      {top_left, bottom_right}
    end

    %Identicon.Image{image| pixel_map: pixel_map}
  end

  @doc """
    - passed the Image struct 
    - Use Enum.filter and call an anonymous function, patter match the tuple
    - if remainder is 0, return true
    - Update the Image struct with the grid var
  """
  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter grid, fn({code, _index}) -> 
      rem(code,2) == 0
    end

    %Identicon.Image{image | grid: grid}
  end

  @doc """
    Enum.chunk(3) - SPlit the list by 3 chunks
    Enum.map(&mirror_row/1) - For every row, returns a list after a function 
      reference is called 
    Lst.flatten - join the list of list into one list 
    Enum.with_index - adds index to the list 
  """
  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid = 
      hex
      |> Enum.chunk(3)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index

    #create a new struct with the added 'grid' attribute  
    %Identicon.Image{image | grid: grid}
  end

  def mirror_row(row) do
    # [145, 46, 200]
    [ first, second | _tail ] = row
  
    # [145, 46, 200, 46, 145]
    row ++ [second, first]
  end

  @doc """
    Get the first 3 element and create an RGB color.
    Use pattern matching to get the first 3 element
  """
  def pick_color(image) do
    %Identicon.Image{hex: hex_list} = image
    
    #pattern matching: r,g,b macted to the first 3 elements of the list.
    # _list matched the rest of the list which we dont care at this point
    [r, g, b | _tail] = hex_list
    
    #implicit return the 3 elements
    #[r, g, b]
    
    # a shorter code. Replace hex_list with [r, g, b | _tail] 
    # %Identicon.Image{hex:[r, g, b | _tail]} = image

    # Create a new struct, add the original hex list and the color property
    %Identicon.Image{image | color: {r, g, b}}

  end

  @doc """
    Elixir support direct pattern matching direct out of the argument list.
    So this is the new version of pick_color
  """
  def pick_color2(%Identicon.Image{hex: [r, g, b | _tail]} = image) do
    %Identicon.Image{image | color: {r, g, b}}
  end

  @doc """
    Get the passed parameter and do a hashing using the md5 algorithm.
    Pipe the result to binary.bin_to_list to get Hex list.
    Place hex result into a struct (Identicon.Image)
  """
  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    # the benefit of a struct, rather than a map, is you cannot
    #make a mistake of adding another element
    %Identicon.Image{hex: hex}
  end

end

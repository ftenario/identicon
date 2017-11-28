defmodule Identicon.Image do
    @doc """
        define a struct that contains only one property: hex
        - Add another property to the struct: color
    """
    defstruct hex: nil, color: nil, grid: nil, pixel_map: nil
end
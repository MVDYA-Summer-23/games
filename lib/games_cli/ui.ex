defmodule GamesCLI.UI do
  alias Owl.{Box, Data}

  @fg_colors GamesCLI.UI.Colors.values().foreground
  @bg_colors GamesCLI.UI.Colors.values().background
  @space_maker fn n -> if(n === 0, do: "", else: String.duplicate(" ", n)) end
  @spaces Enum.reduce(0..10, %{}, fn n, acc -> Map.put(acc, n, @space_maker.(n)) end)

  @reset IO.ANSI.reset()
  @bold IO.ANSI.bright()

  @doc "Create a container with a top margin, rounded corners, a cyan border, and absolute-centered text"
  def show_main_header(header_text) do
    IO.puts("")

    Box.new(header_text,
      border_style: :solid_rounded,
      min_width: 70,
      horizontal_align: :center,
      padding_y: 1,
      border_tag: :cyan
    )
    |> Owl.IO.puts()
  end

  @doc "Create a container with a cyan border and absolute-centered text "
  def show_game_header(header_text) do
    Box.new(header_text,
      border_style: :double,
      min_width: 70,
      horizontal_align: :center,
      padding_y: 1,
      border_tag: :cyan
    )
    |> Owl.IO.puts()
  end

  @doc "Create a container with a default-colored border, a center-aligned title, and left-aligned instructions"
  def show_game_rules(%{header: header_text, description: description}) do
    [
      Box.new(header_text,
        padding_bottom: 1,
        min_width: 64,
        border_style: :none,
        horizontal_align: :center
      ),
      Box.new(
        description,
        min_width: 64,
        border_style: :none
      )
    ]
    |> Box.new(max_width: 70, padding_x: 2, padding_y: 1)
    |> Owl.IO.puts()
  end

  def play_again?(restart_game) do
    again = Owl.IO.confirm(message: Data.tag("Play again?", @fg_colors.yellow), default: true)

    case again do
      true ->
        restart_game.()

      false ->
        Games.start()
    end
  end

  def get_guess(label), do: Owl.IO.input(label: label)

  @doc """
  Returns a formatted ANSI code for a block-style string with bold weight, dark text and colored background for a provided string and color.
  If background color is :black, text color will be white.
  """
  @spec style_text(String.t(), [any]) :: String.t()
  def style_text(text, opts \\ []) do
    text_color = Keyword.get(opts, :text_color, nil)
    bg_color = Keyword.get(opts, :bg_color, nil)
    bold = Keyword.get(opts, :bold, false)
    block = Keyword.get(opts, :block, false)
    compound = Keyword.get(opts, :compound, false)

    p = if block, do: Keyword.get(opts, :padding, 1), else: 0
    # IO.inspect(p, label: "p")
    padding = Map.get(@spaces, p) || " "
    # IO.inspect(padding, label: "padding")
    s = Keyword.get(opts, :spacing) || 0
    spacing = Map.get(@spaces, s)
    text = String.graphemes(text) |> Enum.join(spacing)

    {text_color, bg_color, padding} =
      case {block, compound} do
        {true, false} ->
          fg_color = if bg_color === :black, do: :white, else: :black
          {@fg_colors[fg_color], @bg_colors[bg_color], padding}

        {true, true} ->
          {"", @bg_colors[bg_color], padding}

        _ ->
          {@fg_colors[text_color], "", ""}
      end

    bold = (bold && @bold) || ""
    reset = (compound && "") || @reset
    Enum.join([bg_color, padding, bold, text_color, text, padding, reset], "")
  end

  @doc """
  Returns a list of formatted ANSI codes for a list of tuples with strings and colors, and an option for block-style letters
  """
  @spec style_letter_list([{String.t(), :atom}], any) :: list
  def style_letter_list(word_list, opts \\ []) do
    # only add bold to front of list if available
    bold = if Keyword.get(opts, :bold) === true, do: @bold, else: ""
    padding = Keyword.get(opts, :padding, 0)

    # if block, color in tuple applies to background
    # if not block, color in tuple applies to text

    block = Keyword.get(opts, :block, false)

    {spacing, padding, text_color} =
      if block do
        {
          "",
          if(padding === 0, do: 1, else: padding),
          @fg_colors[:black]
        }
      else
        {
          Map.get(@spaces, Keyword.get(opts, :spacing, 0)) || "",
          0,
          ""
        }
      end

    rest_settings = [block: block, compound: true]

    letters =
      Enum.map(word_list, fn {text, color} ->
        block_settings =
          if block, do: [bg_color: color, padding: padding], else: [text_color: color]

        opts = Enum.concat(block_settings, rest_settings)
        # |> IO.inspect()

        style_text(text, opts)
      end)
      # this add extra spaces at the end :/
      # |> Enum.concat((block && [""]) || [])
      |> Enum.join(spacing)

    Enum.concat([[bold, text_color], [letters], [@reset]])
    # |> IO.inspect()
  end
end

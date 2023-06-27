defmodule Games.Wordle do
  @spec feedback(String.t(), String.t()) :: list()
  def feedback(target, guess) do
    # Count occurrences of each letter in the target word
    target_counts = String.graphemes(target) |> Enum.frequencies()

    # First find all green (letter and location) matches, and remaining letters to be found.
    # This helps with accurate counting of green and yellow matches
    {green_matches, remaining_counts} =
      Enum.map([target, guess], &String.graphemes/1)
      |> Enum.zip()
      |> Enum.reduce({[], target_counts}, fn {target_char, guess_char}, {so_far, counts} ->
        if target_char === guess_char do
          {[:green | so_far], Map.update!(counts, target_char, &(&1 - 1))}
        else
          {[guess_char | so_far], counts}
        end
      end)

    # Return green and remaining yellow and gray non-matches
    Enum.reduce(green_matches, {[], remaining_counts}, fn
      :green, {so_far, counts} ->
        {[:green | so_far], counts}

      char, {so_far, counts} ->
        case counts[char] do
          nil -> {[:gray | so_far], counts}
          0 -> {[:gray | so_far], counts}
          _ -> {[:yellow | so_far], Map.update!(counts, char, &(&1 - 1))}
        end
    end)
    |> elem(0)
  end
end
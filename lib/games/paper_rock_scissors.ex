defmodule Games.PaperRockScissors do
  @game_title Games.paper_rock_scissors()

  @moduledoc """
  Paper, Rock, Scissors game logic

  As this involves non-deterministic side effects from player interaction,
  there are no public functions to test.
  """

  @doc """
  Play a game of Paper, Rock, Scissors from the iex shell
  """
  @spec play :: :ok
  def play do
    IO.puts("Let's play #{@game_title}}!")
    choice = IO.gets("Choose rock, paper, or scissors: ") |> String.trim()
    computer_choice = Enum.random(["paper", "rock", "scissors"])
    IO.puts(check_choice(choice, computer_choice))
  end

  @spec check_choice(String.t(), String.t()) :: String.t()
  def check_choice(choice, computer_choice) do
    if choice === computer_choice do
      "It's a tie!"
    else
      case {choice, computer_choice} do
        {"rock", "paper"} ->
          "You lose! paper beats rock."

        {"paper", "scissors"} ->
          "You lose! scissors beats paper."

        {"scissors", "rock"} ->
          "You lose! rock beats scissors."

        {"rock", "scissors"} ->
          "You win! rock beats scissors."

        {"paper", "rock"} ->
          "You win! paper beats rock."

        {"scissors", "paper"} ->
          "You win! scissors beats paper."
      end
    end
  end
end

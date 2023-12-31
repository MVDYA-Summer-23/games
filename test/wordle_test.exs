defmodule WordleTest do
  import Games.Wordle
  use ExUnit.Case
  doctest Games.Wordle

  describe "testing feedback/2 check rounds" do
    test "returns all green for exact match" do
      assert feedback("race", "race") === [:green, :green, :green, :green]
    end

    test "returns partial green for inexact match" do
      assert feedback("pace", "race") === [:gray, :green, :green, :green]
    end

    test "returns yellow for out of place character" do
      assert feedback("tree", "feet") === [:gray, :yellow, :green, :yellow]
    end

    test "returns gray for out of place character which cannot appear again in word" do
      assert feedback("treat", "fleet") === [:gray, :gray, :green, :gray, :green]
    end

    test "returns all gray for 0 character matches" do
      assert feedback("limbo", "ranch") === [:gray, :gray, :gray, :gray, :gray]
    end

    test "returns 3 yellow for out of place characters" do
      assert feedback("shrimp", "blimpy") === [
               :gray,
               :gray,
               :yellow,
               :yellow,
               :yellow,
               :gray
             ]
    end

    test "returns mostly gray for 1 matching characters" do
      assert feedback("brash", "sssss") == [
               :gray,
               :gray,
               :gray,
               :green,
               :gray
             ]
    end
  end
end

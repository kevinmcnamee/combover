defmodule Combover.Responders.Surf do
  @moduledoc false

  use Hedwig.Responder
  use HTTPoison.Base

  @links [
    "Holla back son"
  ]

  @expected_fields ~w(
    Analysis
  )

  @usage """
  surf in {num} days - sends surf forecast for num days out
  surf for {date} - sends surf forecast for today or tomorrow
  """
  hear ~r/surf for (?<thing>.*)/i, msg do
    start
    reply msg, for_day msg.matches["thing"]
  end

  hear ~r/surf in (?<number>.*) days/i, msg do
    start
    {int, _} = Integer.parse(msg.matches["number"])
    reply msg, for_day int
  end

  hear ~r/list surf spots/i, msg do
    start
    reply msg, list_spots
  end

  defp list_spots do
    surf_spot_mapping()
    |> Map.values
    |> Enum.join(", ")
  end

  defp surf_spot_mapping do
    %{"2147" => "Belmar, NJ"}
  end

  defp for_day "today" do
    Enum.at(get!('2147').body[:Analysis]["surfRange"], 0)
  end

  defp for_day "tomorrow" do
    Enum.at(get!('2147').body[:Analysis]["surfRange"], 1)
  end

  defp for_day(num) when num < 10 do
    Enum.at(get!('2147').body[:Analysis]["surfRange"], num)
  end

  defp process_url(location) do
    "http://api.surfline.com/v1/forecasts/" <> location
  end

  def process_response_body(body) do
    body
    |> Poison.decode!
    |> Map.take(@expected_fields)
    |> Enum.map(fn({k, v}) -> {String.to_atom(k), v} end)
  end
end


defmodule Pipesine.Sound do
  @moduledoc """
  The Sound context.
  """

  import Ecto.Query, warn: false
  alias Pipesine.Repo

  alias Pipesine.Sound.Composition

  def compose_composition(score) do
    seq_length = Regex.scan(~r/\n/, score) |> Enum.count()
    digits = Regex.scan(~r/\d/, score) |> Enum.count()
    characters = Regex.scan(~r/\w/, score) |> Enum.count()
    pipes = Regex.scan(~r/(?:\|>)/, score) |> Enum.count()
    defs = Regex.scan(~r/(?:def)/, score) |> Enum.count()

    instrument2 =
      cond do
        defs >= 5 -> "MembraneSynth"
        defs == 4 -> "AMSynth"
        defs == 3 -> "PluckSynth"
        defs == 2 -> "MetalSynth"
        defs <= 1 -> "NoiseSynth"
      end
    # instrument2 = Enum.find("AMSynth")
    instrument3 = "MembraneSynth"

    length_div =
      case digits do
        0 -> 1
        _ -> digits
      end

    bits = abs(div(characters, 16))

    crusher =
      cond do
        bits <= 16 && bits >= 4 -> bits
        true -> 16
      end

    chebyshev = (pipes * characters + bits) |> rem(100) |> abs()

    delay_time =
      cond do
        pipes >= 100 -> pipes * 0.001
        pipes >= 10 -> pipes * 0.01
        pipes >= 1 -> pipes * 0.1
        true -> 0.25
      end

    # does this need its own defp? so that it can reset first?
    delay_feedback =
      cond do
        chebyshev >= 100 -> chebyshev * 0.001
        chebyshev >= 10 -> chebyshev * 0.01
        chebyshev >= 1 -> chebyshev * 0.1
        true -> 0.05
      end

    panner = delay_feedback - 0.5
    filter_frequency = 100 * crusher - characters

    reverb_decay = 0.1

    reverb_wet = 0.3

    pattern = "randomWalk"
    humanize = "4n"

    note1 = seq_length / length_div * 146.30
    note2 = seq_length / length_div * 292.61
    note3 = seq_length / length_div * 438.91
    note4 = seq_length / length_div * 585.22
    note5 = seq_length / length_div * 731.63

    array2 = [note2, note3, note5]
    array3 = [note1, note2]
      # cond do
      #   pipes >= 100 -> [note1, note2, note3, note4, note5]
      #   pipes >= 10 -> [note1, note2, note3]
      #   pipes >= 1 -> [note1]
      #   true -> []
      # end

    IO.inspect(characters, label: "CHARS")
    IO.inspect(pipes, label: "PIPES")
    IO.inspect(crusher, label: "CRUSHES")
    IO.inspect(delay_time, label: "DELAYTIME")
    IO.inspect(delay_feedback, label: "DELAYFB")
    IO.inspect(chebyshev, label: "CHEBY")
    IO.inspect(panner, label: "PANNY")
    IO.inspect(instrument2, label: "INST2")

    %{
      # filterFrequency: filter_frequency,
      note1: note1,
      note2: note2,
      note3: note3,
      note4: note4,
      note5: note5,
      pannerPan: panner,
      crusher: crusher,
      chebyshev: chebyshev,
      reverbDecay: reverb_decay,
      reverbWet: reverb_wet,
      # delayTime: delay_time,
      # delayFeedback: delay_feedback,
      instrument2: instrument2,
      instrument3: instrument3,
      pattern: pattern,
      humanize: humanize,
      array3: array3
    }
  end

  @doc """
  Returns the list of compositions.

  ## Examples

      iex> list_compositions()
      [%Composition{}, ...]

  """
  def list_compositions do
    Repo.all(Composition)
  end

  @doc """
  Gets a single composition.

  Raises `Ecto.NoResultsError` if the Composition does not exist.

  ## Examples

      iex> get_composition!(123)
      %Composition{}

      iex> get_composition!(456)
      ** (Ecto.NoResultsError)

  """
  def get_composition!(id), do: Repo.get!(Composition, id)

  @doc """
  Creates a composition.

  ## Examples

      iex> create_composition(%{field: value})
      {:ok, %Composition{}}

      iex> create_composition(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_composition(attrs \\ %{}) do
    %Composition{}
    |> Composition.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a composition.

  ## Examples

      iex> update_composition(composition, %{field: new_value})
      {:ok, %Composition{}}

      iex> update_composition(composition, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_composition(%Composition{} = composition, attrs) do
    composition
    |> Composition.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a composition.

  ## Examples

      iex> delete_composition(composition)
      {:ok, %Composition{}}

      iex> delete_composition(composition)
      {:error, %Ecto.Changeset{}}

  """
  def delete_composition(%Composition{} = composition) do
    Repo.delete(composition)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking composition changes.

  ## Examples

      iex> change_composition(composition)
      %Ecto.Changeset{data: %Composition{}}

  """
  def change_composition(%Composition{} = composition, attrs \\ %{}) do
    Composition.changeset(composition, attrs)
  end
end

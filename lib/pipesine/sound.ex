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
    # easter egg
    specs = Regex.scan(~r/@/, score) |> Enum.count()
    atoms = Regex.scan(~r/:/, score) |> Enum.count()
    parens = Regex.scan(~r/\(/, score) |> Enum.count()
    enums = Regex.scan(~r/Enum/, score) |> Enum.count()
    hashes = Regex.scan(~r/#/, score) |> Enum.count()
    kernels = Regex.scan(~r/Kernel/, score) |> Enum.count()

    swing =
      Enum.filter([atoms, pipes, seq_length, digits, characters, defs, specs], fn int -> int < 10 end) |> List.first() |> Kernel.*(0.1)

    time_signature =
      Enum.filter([seq_length, digits, characters, defs, atoms, pipes, specs], fn int -> int <= 11 end) |> List.first()

    vibrato_frequency =
      if specs > 0 do
        specs * 200
      else
        5
      end

    vibrato_depth =
      if vibrato_frequency > 400 do
        0.9
      else
        0.05
      end

    instrument2 =
      cond do
        defs >= 3 ->
          "FMSynth"

        defs == 2 ->
          "AMSynth"

        defs < 2 ->
          "PluckSynth"
      end

    instrument3 =
      cond do
        atoms >= 11 ->
          "MembraneSynth"

        atoms >= 7 or atoms > 11 ->
          "MetalSynth"

          atoms >= 3 or atoms > 7 ->
          "AMSynth"

        atoms < 3 ->
          "PluckSynth"
      end

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

    filter_frequency = 100 * atoms + 2 * characters

    reverb_decay = abs(delay_feedback - delay_time)

    reverb_wet = abs(delay_feedback * delay_time)

    pattern =
      cond do
        parens >= 9 -> "alternateDown"
        parens == 7 or parens == 8 -> "downUp"
        parens == 5 or parens == 6 -> "upDown"
        parens == 3 or parens == 4 -> "randomWalk"
        parens < 3 -> "down"
      end

    pattern3 =
      cond do
        enums >= 9 -> "alternateDown"
        enums == 7 or enums == 8 -> "downUp"
        enums == 5 or enums == 6 -> "upDown"
        enums == 3 or enums == 4 -> "randomWalk"
        enums < 3 -> "down"
      end

    # note1 = seq_length / length_div * 100
    # note2 = seq_length / length_div * 200
    # note3 = seq_length / length_div * 300
    # note4 = seq_length / length_div * 400
    # note5 = seq_length / length_div * 500
    # note6 = seq_length / length_div * 600
    # note7 = seq_length / length_div * 700
    # note8 = seq_length / length_div * 800
    # note9 = seq_length / length_div * 900
    # note10 = seq_length / length_div * 1000

    note1 = seq_length / length_div * 133.238
    note2 = seq_length / length_div * 301.847
    note3 = seq_length / length_div * 435.084
    note4 = seq_length / length_div * 582.512
    note5 = seq_length / length_div * 736.931
    note6 = seq_length / length_div * 884.359
    note7 = seq_length / length_div * 1017.596
    note8 = seq_length / length_div * 1165.024
    note9 = seq_length / length_div * 1319.443
    note10 = seq_length / length_div * 1466.871

    all_notes = Enum.map([note1, note2, note3, note4, note5, note6, note7, note8, note9, note10], fn each ->
      each
      |> Float.round(0)
      |> trunc()
    end)

    phrase =
      Enum.filter(all_notes, fn note -> rem(note, 2) == 0 end)

    phrase2 =
      Enum.filter(all_notes, fn note -> rem(note, 3) == 0 end)

    phrase3 =
      Enum.filter(all_notes, fn note -> rem(note, 5) == 0 end)

    tempo = min(abs(note5 - note4) / 3, 400)

    IO.inspect(filter_frequency, label: "FILTER FREQ")
    IO.inspect(panner, label: "PANNER")
    IO.inspect(parens, label: "PARNES")
    IO.inspect(all_notes, label: "ALLNOTES")
    IO.inspect(pattern, label: "PATTERN")
    IO.inspect(pattern3, label: "PATTERN3")
    IO.inspect(phrase, label: "PHRS")
    IO.inspect(phrase2, label: "PHRS2")
    IO.inspect(phrase3, label: "PHRS3")
    IO.inspect(atoms, label: "ATOMS")
    IO.inspect(enums, label: "ENUMS")

    %{
      atoms: atoms,
      filterFrequency: filter_frequency,
      note1: note1,
      note2: note2,
      note3: note3,
      note4: note4,
      note5: note5,
      note6: note6,
      note7: note7,
      note8: note8,
      note9: note9,
      note10: note10,
      all_notes: all_notes,
      panner: panner,
      crusher: crusher,
      chebyshev: chebyshev,
      reverbDecay: reverb_decay,
      reverbWet: reverb_wet,
      # delayTime: delay_time,
      # delayFeedback: delay_feedback,
      instrument2: instrument2,
      instrument3: instrument3,
      pattern: pattern,
      pattern3: pattern3,
      phrase: phrase,
      phrase2: phrase2,
      phrase3: phrase3,
      swing: swing,
      tempo: tempo,
      timeSignature: time_signature,
      vibratoFrequency: vibrato_frequency,
      vibratoDepth: vibrato_depth
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

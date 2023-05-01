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

        defs <= 1 ->
          "PluckSynth"
      end

    instrument3 =
      cond do
        vibrato_frequency >= 600 ->
          "MembraneSynth"

        vibrato_frequency == 400 ->
          "MetalSynth"

        vibrato_frequency == 200 ->
          "AMSynth"

        vibrato_frequency <= 5 ->
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

    filter_frequency = 100 * crusher + 2 * characters

    reverb_decay = abs(delay_feedback - delay_time)

    reverb_wet = abs(delay_feedback * delay_time)

    pattern =
      cond do
        parens >= 9 -> "alternateDown"
        parens >= 7 -> "downUp"
        parens >= 5 -> "upDown"
        parens >= 3 -> "randomWalk"
        parens <= 2 -> "down"
      end

    pattern3 = "upDown"

    note1 = seq_length / length_div * 133.238 |> Float.round(0) |> trunc()
    note2 = seq_length / length_div * 301.847 |> Float.round(0) |> trunc()
    note3 = seq_length / length_div * 435.084 |> Float.round(0) |> trunc()
    note4 = seq_length / length_div * 582.512 |> Float.round(0) |> trunc()
    note5 = seq_length / length_div * 736.931 |> Float.round(0) |> trunc()
    note6 = seq_length / length_div * 884.359 |> Float.round(0) |> trunc()
    note7 = seq_length / length_div * 1017.596 |> Float.round(0) |> trunc()
    note8 = seq_length / length_div * 1165.024 |> Float.round(0) |> trunc()
    note9 = seq_length / length_div * 1319.443 |> Float.round(0) |> trunc()
    note10 = seq_length / length_div * 1466.871 |> Float.round(0) |> trunc()

    all_notes = [note1, note2, note3, note4, note5, note6, note7, note8, note9, note10]

    # note1 = seq_length / length_div * 146.30
    # note2 = seq_length / length_div * 292.61
    # note3 = seq_length / length_div * 438.91
    # note4 = seq_length / length_div * 585.22
    # note5 = seq_length / length_div * 731.63

    phrase =
      Enum.filter(all_notes, fn note -> rem(note, 2) == 1 end)

    phrase2 = [note1, note2, note3, note4, note5]
    phrase3 = [note1, note2, note4]

    tempo = min(abs(note5 - note4) / 3, 400)

    # cond do
    #   pipes >= 100 -> [note1, note2, note3, note4, note5]
    #   pipes >= 10 -> [note1, note2, note3]
    #   pipes >= 1 -> [note1]
    #   true -> []
    # end

    IO.inspect(filter_frequency, label: "FILTER FREQ")
    IO.inspect(panner, label: "PANNER")
    IO.inspect(parens, label: "PARNES")
    IO.inspect(all_notes, label: "ALLNOTES")
    IO.inspect(pattern, label: "PATTERN")
    
    %{
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

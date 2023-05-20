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
    specs = Regex.scan(~r/@/, score) |> Enum.count()
    atoms = Regex.scan(~r/:\w/, score) |> Enum.count()
    reduces = Regex.scan(~r/.reduce/, score) |> Enum.count()
    oks = Regex.scan(~r/{:ok/, score) |> Enum.count()
    parens = Regex.scan(~r/\(/, score) |> Enum.count()
    enums = Regex.scan(~r/Enum/, score) |> Enum.count()
    hashes = Regex.scan(~r/(#)/, score) |> Enum.count() |> Kernel.*(5)
    kernels = Regex.scan(~r/Kernel/, score) |> Enum.count()
    defstructs = Regex.scan(~r/(?:%\w)/, score) |> Enum.count()
    gens = Regex.scan(~r/Genserver/, score) |> Enum.count()
    conds = Regex.scan(~r/cond/, score) |> Enum.count()
    cases = Regex.scan(~r/case/, score) |> Enum.count()
    capts = Regex.scan(~r/&/, score) |> Enum.count()
    pchars = Regex.scan(~r/[!?@#$~%^*_0-9]/, score) |> Enum.count() |> max(1)

    scale =
      Regex.run(
        ~r/bohlen_pierce|tonality-diamond|pentatonic|sa_murcchana|just_intonation|22_edo|\w/,
        score
      )
      |> List.first()

    touche =
      (gens + conds + cases + kernels + capts + defstructs + atoms + enums + pipes) /
        max(pchars, 1)

    swing =
      Enum.filter([atoms, pipes, seq_length, digits, characters, defs, specs], fn int ->
        int < 10
      end)
      |> List.first()
      |> Kernel.*(0.1)
      |> Kernel.+(0.3)

    swing_subdivision =
      cond do
        touche > 0.5 -> "4n"
        touche > 0.3 -> "8n"
        touche > 0.2 -> "16n"
        true -> "32n"
      end

    note_length2 =
      cond do
        rem(digits, 9) == 0 -> "4n"
        rem(digits, 7) == 0 -> "8n"
        rem(digits, 5) == 0 -> "16n"
        rem(digits, 3) == 0 -> "32n"
        true -> "16n"
      end

    note_length3 =
      cond do
        rem(digits, 9) == 0 -> "32n"
        rem(digits, 7) == 0 -> "16n"
        rem(digits, 5) == 0 -> "8n"
        rem(digits, 3) == 0 -> "4n"
        true -> "8n"
      end

    time_signature =
      Enum.filter([seq_length, digits, characters, defs, atoms, pipes, specs], fn int ->
        int <= 11
      end)
      |> List.first()
      |> max(4)

    instrument1 =
      cond do
        hashes >= 25 ->
          "FMSynth"

        hashes >= 20 ->
          "PolySynth"

        hashes >= 15 ->
          "PluckSynth"

        hashes >= 10 ->
          "FMSynth"

        hashes >= 5 ->
          "MembraneSynth"

        hashes < 5 ->
          "PolySynth"
      end

    instrument2 =
      cond do
        defs >= 6 ->
          "FMSynth"

        defs >= 4 ->
          "AMSynth"

        defs >= 2 ->
          "PluckSynth"

        defs < 2 ->
          "PolySynth"
      end

    instrument3 =
      cond do
        atoms >= 11 ->
          "FMSynth"

        atoms >= 7 ->
          "MembraneSynth"

        atoms >= 3 ->
          "AMSynth"

        atoms >= 2 ->
          "PluckSynth"

        atoms < 2 ->
          "PolySynth"
      end

    digits_div =
      case digits do
        0 -> 1
        _ -> digits
      end

    bits = abs(rem(characters, 16))

    crusher =
      cond do
        bits <= 16 && bits >= 6 -> bits
        true -> 12
      end

    chebyshev = (pipes * pchars + bits) |> rem(17) |> abs()

    delay_time =
      cond do
        pipes >= 100 -> pipes * 0.001
        pipes >= 10 -> pipes * 0.01
        pipes >= 1 -> pipes * 0.1
        true -> 0.0
      end

    # does this need its own defp? so that it can reset first?
    delay_feedback =
      cond do
        chebyshev >= 10 -> chebyshev * 0.04
        chebyshev >= 5 -> chebyshev * 0.03
        chebyshev >= 1 -> chebyshev * 0.02
        true -> 0.05
      end

    panner = delay_feedback - 0.5

    reverb_decay = abs(delay_feedback - delay_time) |> max(0.1)

    reverb_wet = abs(delay_feedback * delay_time) |> max(0.1) |> min(0.75)

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
        enums >= 7 -> "alternateDown"
        enums == 5 or enums == 8 -> "downUp"
        enums == 3 or enums == 6 -> "upDown"
        enums == 2 or enums == 4 -> "randomWalk"
        enums < 2 -> "down"
      end

    fundamental_init = seq_length * 432 / digits_div

    fundamental =
      cond do
        fundamental_init > 6000 -> fundamental_init / 12
        fundamental_init > 5000 -> fundamental_init / 10
        fundamental_init > 4000 -> fundamental_init / 8
        fundamental_init > 3000 -> fundamental_init / 6
        fundamental_init > 2000 -> fundamental_init / 4
        fundamental_init > 1000 -> fundamental_init / 2
        true -> fundamental_init / 1
      end

    all_notes =
      case scale do
        "tonality_diamond" ->
          Enum.map(
            [
              fundamental / 8,
              fundamental / 4,
              fundamental / 2,
              fundamental,
              fundamental * (8 / 7),
              fundamental * (7 / 6),
              fundamental * (6 / 5),
              fundamental * (5 / 4),
              fundamental * (4 / 3),
              fundamental * (7 / 5),
              fundamental * (10 / 7),
              fundamental * (3 / 2),
              fundamental * (8 / 5),
              fundamental * (5 / 3),
              fundamental * (12 / 7),
              fundamental * (7 / 4),
              fundamental * 2,
              fundamental * 4
            ],
            fn each ->
              each
              |> Float.round(0)
              |> trunc()
            end
          )

        "bohlen_pierce" ->
          Enum.map(
            [
              fundamental / 8,
              fundamental / 4,
              fundamental / 2,
              fundamental,
              fundamental * (27 / 25),
              fundamental * (25 / 21),
              fundamental * (9 / 7),
              fundamental * (7 / 5),
              fundamental * (75 / 49),
              fundamental * (5 / 3),
              fundamental * (9 / 5),
              fundamental * (49 / 25),
              fundamental * (15 / 7),
              fundamental * (7 / 3),
              fundamental * (63 / 25),
              fundamental * (25 / 9),
              fundamental * 2,
              fundamental * 4
            ],
            fn each ->
              each
              |> Float.round(0)
              |> trunc()
            end
          )

        # https://bolprocessor.org/raga-intonation/
        "sa_murcchana" ->
          Enum.map(
            [
              fundamental / 8,
              fundamental / 4,
              fundamental / 2,
              fundamental,
              fundamental * (256 / 243),
              fundamental * (10 / 9),
              fundamental * (32 / 27),
              fundamental * (5 / 4),
              fundamental * (4 / 3),
              fundamental * (45 / 32),
              fundamental * (40 / 27),
              fundamental * (128 / 81),
              fundamental * (5 / 3),
              fundamental * (16 / 9),
              fundamental * (15 / 8),
              fundamental * (15 / 8),
              fundamental * 2,
              fundamental * 4
            ],
            fn each ->
              each
              |> Float.round(0)
              |> trunc()
            end
          )

        "just_intonation" ->
          Enum.map(
            [
              fundamental / 8,
              fundamental / 4,
              fundamental / 2,
              fundamental,
              fundamental * (16 / 15),
              fundamental * (10 / 9),
              fundamental * (9 / 8),
              fundamental * (6 / 5),
              fundamental * (5 / 4),
              fundamental * (4 / 3),
              fundamental * (45 / 32),
              fundamental * (64 / 45),
              fundamental * (3 / 2),
              fundamental * (8 / 5),
              fundamental * (5 / 3),
              fundamental * (7 / 4),
              fundamental * 2,
              fundamental * 4
            ],
            fn each ->
              each
              |> Float.round(0)
              |> trunc()
            end
          )

        "22_edo" ->
          Enum.map(
            [
              fundamental / 8,
              fundamental / 4,
              fundamental / 2,
              fundamental,
              fundamental * (36 / 35),
              fundamental * (12 / 11),
              fundamental * (20 / 17),
              fundamental * (96 / 77),
              fundamental * (14 / 11),
              fundamental * (24 / 17),
              fundamental * (14 / 9),
              fundamental * (28 / 17),
              fundamental * (17 / 10),
              fundamental * (9 / 5),
              fundamental * (28 / 15),
              fundamental * (31 / 16),
              fundamental * 2,
              fundamental * 4
            ],
            fn each ->
              each
              |> Float.round(0)
              |> trunc()
            end
          )

        "pentatonic" ->
          Enum.map(
            [
              fundamental / 8,
              fundamental / 4,
              fundamental / 2,
              fundamental,
              fundamental * (9 / 8),
              fundamental * (5 / 4),
              fundamental * (3 / 2),
              fundamental * (7 / 4),
              fundamental * (18 / 8),
              fundamental * (10 / 4),
              fundamental * (6 / 2),
              fundamental * (14 / 4),
              fundamental * (27 / 8),
              fundamental * (15 / 4),
              fundamental * (9 / 2),
              fundamental * (21 / 4),
              fundamental * 2,
              fundamental * 4
            ],
            fn each ->
              each
              |> Float.round(0)
              |> trunc()
            end
          )

        # Superpyth Supra https://en.xen.wiki/w/Superpyth
        _ ->
          Enum.map(
            [
              fundamental / 8,
              fundamental / 4,
              fundamental / 2,
              fundamental,
              fundamental * (33 / 32),
              fundamental * (12 / 11),
              fundamental * (9 / 8),
              fundamental * (7 / 6),
              fundamental * (11 / 9),
              fundamental * (14 / 11),
              fundamental * (4 / 3),
              fundamental * (11 / 8),
              fundamental * (16 / 11),
              fundamental * (18 / 11),
              fundamental * (7 / 4),
              fundamental * (27 / 14),
              fundamental * 2,
              fundamental * 4
            ],
            fn each ->
              each
              |> Float.round(0)
              |> trunc()
            end
          )
      end

    now = :erlang.timestamp()
    :rand.seed(:exsss, now)

    indx = max(1, digits + atoms)

    # melody (synth)
    phrase =
      case rem(atoms, 2) do
        0 ->
          if instrument1 == "PolySynth" do
            Enum.shuffle(all_notes)
            |> Enum.filter(fn note -> rem(note, 2) == 0 end)
            |> Enum.chunk_every(3, 2)
          else
            Enum.filter(all_notes, fn note -> rem(note, 2) == 0 end)
            |> List.insert_at(indx, fundamental / 8)
            |> Enum.shuffle()
            |> Enum.map(fn each ->
              (each * 3 / 2)
              |> trunc()
            end)
          end

        _ ->
          Enum.filter(all_notes, fn note -> rem(note, 2) == 0 end)
          |> List.insert_at(indx, fundamental / 8)
          |> Enum.shuffle()
      end

    # Enum.filter(all_notes, fn note -> rem(note, 2) == 0 end) |> List.insert_at(indx, fundamental/8) |> Enum.shuffle()

    # harmony (synth)
    # phrase =
    #   Enum.shuffle(all_notes)
    #   |> Enum.filter(fn note -> rem(note, 2) == 0 end)
    #   |> Enum.chunk_every(3, 2)

    phrase2 = Enum.filter(all_notes, fn note -> rem(note, 3) == 0 end) |> Enum.shuffle()

    phrase3 =
      case rem(capts, 3) do
        0 ->
          Enum.filter(all_notes, fn note -> rem(note, 2) == 0 end)
            |> List.insert_at(indx, fundamental / 8)
            |> Enum.shuffle()
            |> Enum.map(fn each ->
              (each * 15 / 8)
              |> trunc()
            end)
        _ ->
          Enum.filter(all_notes, fn note -> rem(note, 5) == 0 end) |> Enum.shuffle()
      end

    tempo = min(abs(fundamental) / max(reduces + oks, 3), 400)

    vibrato_depth =
      if fundamental > 435 do
        0.99
      else
        0.0
      end

    vibrato_frequency =
      if fundamental > 770 do
        770
      else
        0.99
      end

    # filter_frequency = 100 * atoms + 2 * characters |> min(2000)

    note4 = Enum.fetch!(all_notes, 7)
    note6 = Enum.fetch!(all_notes, 9)
    note9 = Enum.fetch!(all_notes, 12)
    note11 = Enum.fetch!(all_notes, 14)

    filter_frequency = note4
    filter2_frequency = note11
    filter3_frequency = note9 * 2

    IO.inspect(indx, label: "INDX")
    IO.inspect(pchars, label: "PCHARS")
    IO.inspect(digits, label: "FIGITS")

    %{
      note4: note4,
      note6: note6,
      note9: note9,
      note11: note11,
      all_notes: all_notes,
      atoms: atoms,
      capts: capts,
      conds: conds,
      crusher: crusher,
      chebyshev: chebyshev,
      defstructs: defstructs,
      delayTime: delay_time,
      delayFeedback: delay_feedback,
      filterFrequency: filter_frequency,
      filter2Frequency: filter2_frequency,
      filter3Frequency: filter3_frequency,
      fundamental: fundamental,
      hashes: hashes,
      instrument1: instrument1,
      instrument2: instrument2,
      instrument3: instrument3,
      kernels: kernels,
      noteLength2: note_length2,
      noteLength3: note_length3,
      panner: panner,
      pattern: pattern,
      pattern3: pattern3,
      phrase: phrase,
      phrase2: phrase2,
      phrase3: phrase3,
      reverbDecay: reverb_decay,
      reverbWet: reverb_wet,
      swing: swing,
      swingSubdivision: swing_subdivision,
      tempo: tempo,
      touche: touche,
      timeSignature: time_signature,
      vibratoFrequency: vibrato_frequency,
      vibratoDepth: vibrato_depth
    }
    |> IO.inspect(label: "DATA 4 JS")
  end

  @doc """
  Returns the list of compositions.

  ## Examples

      iex> list_compositions()
      [%Composition{}, ...]

  """
  def list_compositions do
    Repo.all(Composition)
    |> Repo.preload([:composer])
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
    |> broadcast(:composition_created)
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

  def subscribe do
    Phoenix.PubSub.subscribe(Pipesine.PubSub, "compositions")
  end

  defp broadcast({:error, _reason} = error, _event), do: error

  defp broadcast({:ok, composition}, event) do
    Phoenix.PubSub.broadcast(Pipesine.PubSub, "compositions", {event, composition})
    {:ok, composition}
  end
end

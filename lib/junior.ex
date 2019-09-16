defmodule Junior do
  @moduledoc """
  Documentation for Junior.
  """

  import Pdf2htmlex

  @home_dir System.get_env("HOME")
  @target_dir "#{@home_dir}/Downloads/tmp/junior"

  def start(source) do
    convert(source)

    parsed_document =
      get_html_doc(source)
      |> parse(source)
      |> get_student_names(source)
      |> get_student_grades(source)

    case parsed_document do
      {:ok, document} ->
        IO.inspect(document, label: "parsed document retrieved.....")

        #       {:error, err} ->
        #         IO.puts("no parsed document found.....")
    end
  end

  def convert(source) do
    if not File.exists?(@target_dir) do
      IO.inspect(@target_dir, label: "target dir does not exist, creating it.......")

      case File.mkdir_p(@target_dir) do
        :ok ->
          IO.inspect(@target_dir, label: "target dir created!")

        {:error, err} ->
          IO.inspect(err, label: "oops! there was a problem")
      end
    end

    ProgressBar.render_spinner(
      [
        frames: :braille,
        text: "Converting PDF to HTML…",
        spinner_color: IO.ANSI.magenta(),
        done: [IO.ANSI.green(), "✓", IO.ANSI.reset(), " Done Converting."]
      ],
      fn ->
        open(source)
        |> convert_to!(@target_dir)
      end
    )
  end

  defp get_html_doc(source) do
    filename = convert_filename(source, "pdf", "html")

    html_doc =
      case File.read("#{@target_dir}/#{filename}") do
        {:ok, file} ->
          file

        {:error, _err} ->
          nil
      end

    {:ok, html_doc}
  end

  defp convert_filename(filename, from, to) do
    converted =
      filename
      |> String.split("/")
      |> List.last()
      |> String.replace_suffix(".#{from}", ".#{to}")

    converted
  end

  defp get_student_names({:ok, parsed_contents}, source) do
    filename = convert_filename(source, "pdf", "txt")
    IO.inspect(filename, label: "filename to write to")

    student_names =
      parsed_contents
      |> Floki.find(".pf .pc .c.x7.yb.w4.h2")
      |> Floki.text(sep: "|")
      |> String.replace("|", "\n")
      |> String.trim()

    File.write!("#{@target_dir}/#{filename}", student_names, [:write])

    {:ok, parsed_contents}
  end

  defp get_student_grades({:ok, parsed_contents}, _source) do
    # sixth_grade_classes = ["SociaStGr6", "Science Gr 6", "English LA6", "Math, Grade 6"]

    # seventh_grade_classes = [
    #   "English Gr 7",
    #   "Math 7 Adv",
    #   "LifeSci Gr7",
    #   "Citiz Gr 7",
    #   "Geog Gr 7",
    #   "Math Gr 7"
    # ]

    # class_target = ".w16.ha"
    # grade_target = ".x20.w18"

    # filename = convert_filename(source, "pdf", "txt")
    # IO.inspect(filename, label: "filename to write to")

    # student_names =
    #   parsed_contents
    #   |> Floki.find(".pf .pc .c.x7.yb.w4.h2")
    #   |> Floki.text(sep: "|")
    #   |> String.replace("|", "\n")
    #   |> String.trim()

    # File.write!("#{@target_dir}/#{filename}", student_names, [:append])

    {:ok, parsed_contents}
  end

  defp parse({:ok, html_doc}, _source) do
    ProgressBar.render_spinner(
      [
        frames: :braille,
        text: "Reading HTML…",
        spinner_color: IO.ANSI.magenta(),
        done: [IO.ANSI.green(), "✓", IO.ANSI.reset(), " Done Reading."]
      ],
      fn ->
        parsed_contents = Floki.parse(html_doc)
        {:ok, parsed_contents}
      end
    )
  end
end

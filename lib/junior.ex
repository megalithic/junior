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
      |> parse

    case parsed_document do
      {:ok, document} ->
        IO.inspect(document, label: "parsed document retrieved.....")

      {:error, _} ->
        IO.puts("no parsed document found.....")
    end
  end

  def convert(source) do
    if not File.exists?(@target_dir) do
      IO.inspect(@target_dir, label: "target dir does not exist, creating it.......")

      case File.mkdir_p(@target_dir) do
        :ok ->
          IO.inspect(@target_dir, label: "target dir created!")

        {:error, err} ->
          IO.inspect(err, "oops! there was a problem")
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
    source_as_html =
      source
      |> String.split("/")
      |> List.last()
      |> String.replace_suffix(".pdf", ".html")
      |> IO.inspect(label: "source_as_html")

    html_doc =
      case File.read("#{@target_dir}/#{source_as_html}") do
        {:ok, file} ->
          file

        {:error, _err} ->
          nil
      end

    html_doc
  end

  defp parse(nil) do
    {:error, ""}
  end

  defp parse(html) do
    ProgressBar.render_spinner(
      [
        frames: :braille,
        text: "Reading HTML…",
        spinner_color: IO.ANSI.magenta(),
        done: [IO.ANSI.green(), "✓", IO.ANSI.reset(), " Done Reading."]
      ],
      fn ->
        document = Meeseeks.parse(html)
        {:ok, document}
      end
    )
  end
end

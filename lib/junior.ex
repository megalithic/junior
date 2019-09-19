defmodule Junior do
  @moduledoc """
  Documentation for Junior.
  """

  import Pdf2htmlex

  alias Junior.Page
  alias Junior.Utils

  @home_dir System.get_env("HOME")
  @target_dir "#{@home_dir}/Downloads/tmp/junior"

  def start(source, should_clean) do
    Page.start_link()

    if should_clean do
      clean(source)
    end

    convert_pdf_to_html(source)

    write_column_headers(source)

    get_html_doc(source)
    |> parse(source)
    |> get_pages(source)
    |> Enum.each(fn page ->
      Page.save_data(page, source)
      |> write_data(source)
    end)

    IO.puts("Students written to file: #{Enum.count(Page.get_students())}")
  end

  def clean(source) do
    ProgressBar.render_spinner(
      [
        frames: :braille,
        text: "Cleaning Previously Stored Files…",
        spinner_color: IO.ANSI.magenta(),
        done: [IO.ANSI.green(), "✓", IO.ANSI.reset(), " Done Cleaning Previous Files."]
      ],
      fn ->
        html_source_filename = Utils.convert_filename(source, "pdf", "html")
        txt_target_filename = Utils.convert_filename(source, "pdf", "txt")
        csv_target_filename = Utils.convert_filename(source, "pdf", "csv")

        File.rm("#{@target_dir}/#{html_source_filename}")
        File.rm("#{@target_dir}/#{txt_target_filename}")
        File.rm("#{@target_dir}/#{csv_target_filename}")
      end
    )
  end

  def convert_pdf_to_html(source) do
    if not File.exists?(@target_dir) do
      case File.mkdir_p(@target_dir) do
        :ok ->
          IO.inspect(@target_dir, label: "Target dir created!")

        {:error, err} ->
          IO.inspect(err, label: "Oops! There was a problem creating the target dir")
      end
    end

    ProgressBar.render_spinner(
      [
        frames: :braille,
        text: "Converting PDF to HTML…",
        spinner_color: IO.ANSI.magenta(),
        done: [IO.ANSI.green(), "✓", IO.ANSI.reset(), " Done Converting PDF to HTML."]
      ],
      fn ->
        open(source)
        |> convert_to!(@target_dir)
      end
    )
  end

  defp get_html_doc(source) do
    filename = Utils.convert_filename(source, "pdf", "html")

    html_doc =
      case File.read("#{@target_dir}/#{filename}") do
        {:ok, file} ->
          file

        {:error, _err} ->
          nil
      end

    html_doc
  end

  defp parse(html_doc, _source) do
    ProgressBar.render_spinner(
      [
        frames: :braille,
        text: "Parsing HTML…",
        spinner_color: IO.ANSI.magenta(),
        done: [IO.ANSI.green(), "✓", IO.ANSI.reset(), " Done Parsing HTML."]
      ],
      fn ->
        parsed_contents = Floki.parse(html_doc)
        parsed_contents
      end
    )
  end

  defp get_pages(parsed_contents, _source) do
    ProgressBar.render_spinner(
      [
        frames: :braille,
        text: "Compiling Pages…",
        spinner_color: IO.ANSI.magenta(),
        done: [IO.ANSI.green(), "✓", IO.ANSI.reset(), " Done Compiling Pages."]
      ],
      fn ->
        pages =
          parsed_contents
          |> Floki.find(".pf.w0.h0")

        pages
      end
    )
  end

  defp write_column_headers(source) do
    ProgressBar.render_spinner(
      [
        frames: :braille,
        text: "Writing Column Headers…",
        spinner_color: IO.ANSI.magenta(),
        done: [
          IO.ANSI.green(),
          "✓",
          IO.ANSI.reset(),
          " Done Writing Column Headers."
        ]
      ],
      fn ->
        filename = Utils.convert_filename(source, "pdf", "csv")

        entry = "Last,First Middle,Year,Cumulative Grade\n"

        File.write("#{@target_dir}/#{filename}", entry, [])
      end
    )
  end

  defp write_data(student, source) do
    ProgressBar.render_spinner(
      [
        frames: :braille,
        text: "Writing Student (#{student.name}) Data to File…",
        spinner_color: IO.ANSI.magenta(),
        done: [
          IO.ANSI.green(),
          "✓",
          IO.ANSI.reset(),
          " Done Writing Student (#{student.name}) Data."
        ]
      ],
      fn ->
        filename = Utils.convert_filename(source, "pdf", "csv")

        entry = "#{student.name},#{student.year},#{student.cumulative}\n"

        File.write("#{@target_dir}/#{filename}", entry, [:append])
      end
    )
  end
end

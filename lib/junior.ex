defmodule Junior do
  @moduledoc """
  Documentation for Junior.
  """

  import Pdf2htmlex

  @home_dir System.get_env("HOME")
  @target_dir "#{@home_dir}/Downloads/tmp/junior"

  def start(source) do
    convert(source)

    get_html_doc(source)
    |> parse(source)
    |> get_pages(source)
    |> Enum.map(fn page ->
      write_data(page, source)
    end)
  end

  def convert(source) do
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

    html_doc
  end

  defp parse(html_doc, _source) do
    ProgressBar.render_spinner(
      [
        frames: :braille,
        text: "Parsing HTML…",
        spinner_color: IO.ANSI.magenta(),
        done: [IO.ANSI.green(), "✓", IO.ANSI.reset(), " Done Parsing."]
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
        text: "Reading Pages…",
        spinner_color: IO.ANSI.magenta(),
        done: [IO.ANSI.green(), "✓", IO.ANSI.reset(), " Done Reading."]
      ],
      fn ->
        pages =
          parsed_contents
          |> Floki.find(".pf.w0.h0")

        pages
      end
    )
  end

  defp write_data(data, source) do
    {"div", _attr, page} = data

    ProgressBar.render_spinner(
      [
        frames: :braille,
        text: "writing student data to file…",
        spinner_color: IO.ANSI.magenta(),
        done: [IO.ANSI.green(), "✓", IO.ANSI.reset(), " Done Writing Data."]
      ],
      fn ->
        filename = convert_filename(source, "pdf", "txt")

        page
        |> find_and_write_name(filename)
        |> find_and_write_grades(filename)
      end
    )
  end

  defp find_and_write_name(page, filename) do
    name_target = ".c.x7.yb.w4.h2"

    name =
      page
      |> Floki.find(name_target)
      |> Floki.text()
      |> String.trim()
      |> Kernel.<>("\t")

    File.write("#{@target_dir}/#{filename}", name, [])

    page
  end

  defp find_and_write_grades(page, filename) do
    class_target = ".w16.ha"
    grade_target = ".x20.w18"
    _cumulative_grades = 0
    grades = []
    classes = get_classes(filename)

    Enum.each(classes, fn class ->
      found_class_target =
        page
        |> Floki.find(class_target)
        |> Enum.filter(fn c -> Floki.text(c) == class end)
        |> Enum.at(0)

      found_class_target_text =
        Floki.text(found_class_target)
        |> IO.inspect(label: "found_class_target_text")

      if found_class_target_text == class do
        # TODO: take the `yxx` class pattern and find all that match; the last one in the html-tree list should be the grade
        found_class_target_css =
          Floki.attribute(found_class_target, "class")
          |> Enum.at(0)
          |> String.replace(" ", ".")
          |> String.replace("c.", ".c.")

        common_class =
          Regex.run(~r/(.[y]\w+)/, found_class_target_css)
          |> Enum.uniq()
          |> Enum.at(0)
          |> IO.inspect(label: "captured common_class regex")

        class_grade_sibling_target =
          "#{found_class_target_css} ~ #{grade_target <> common_class}"
          |> IO.inspect(label: "class_grade_sibling_target")

        class_grade_target =
          Floki.find(page, class_grade_sibling_target)
          |> Floki.text()
          |> Integer.parse()
          |> Kernel.elem(0)

        IO.inspect(class_grade_target, label: "class_grade_target")

        # grades = grades ++ Floki.text(class_grade_target)
        # IO.inspect(grades, label: "grades we're updating.........")
      end

      #       if found_class == class do
      #         class_grade =
      #           page
      #           |> Floki.find(grade_target)
      #           |> Floki.text()
      #           |> IO.inspect(label: "found class grade")

      #         grades = grades ++ class_grade
      #       end
    end)

    IO.inspect(grades, label: "total grades")

    # grades =
    #   page
    #   |> Floki.find(name_target)
    #   |> Floki.text()
    #   |> String.trim()
    #   |> Kernel.<>("\t")

    # File.write("#{@target_dir}/#{filename}", cumulative_grades, [])

    page
  end

  defp get_classes(filename) do
    cond do
      filename =~ "6th grade" ->
        ["SociaStGr6", "Science Gr 6", "English LA6", "Math, Grade 6"]

      filename =~ "7th grade" ->
        [
          "English Gr 7",
          "Math 7 Adv",
          "LifeSci Gr7",
          "Citiz Gr 7",
          "Geog Gr 7",
          "Math Gr 7"
        ]

      false ->
        []
    end
  end

  defp convert_filename(filename, from, to) do
    converted =
      filename
      |> String.split("/")
      |> List.last()
      |> String.replace_suffix(".#{from}", ".#{to}")

    converted
  end
end

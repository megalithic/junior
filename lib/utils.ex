defmodule Junior.Utils do
  def convert_filename(filename, from, to) do
    converted =
      filename
      |> String.split("/")
      |> List.last()
      |> String.replace_suffix(".#{from}", ".#{to}")

    converted
  end

  def get_classes(filename) do
    cond do
      filename =~ "6th grade" ->
        {6, ["SociaStGr6", "Science Gr 6", "English LA6", "Math, Grade 6"]}

      filename =~ "7th grade" ->
        {7,
         [
           "English Gr 7",
           "Math 7 Adv",
           "LifeSci Gr7",
           "Citiz Gr 7",
           "Geog Gr 7",
           "Math Gr 7"
         ]}

      true ->
        []
    end
  end
end

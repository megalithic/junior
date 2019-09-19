defmodule Junior.Page do
  use Agent
  alias Junior.Utils

  def start_link() do
    {:ok, pid} = Agent.start_link(fn -> [] end, name: __MODULE__)
    pid
  end

  def save_data({"div", _attr, page}, source) do
    {year, classes} = Utils.get_classes(source)
    initial_student = %{name: "", grades: [], cumulative: 0, page: page, year: year}

    student =
      initial_student
      |> set_name
      |> set_grades(classes)
      |> set_cumulative

    student_to_save = Map.drop(student, [:page])

    Agent.update(__MODULE__, fn students ->
      students ++ [student_to_save]
    end)

    student_to_save
  end

  def get_students() do
    students = Agent.get(__MODULE__, fn students -> students end)
    students
  end

  defp set_name(student) do
    name_target = ".c.x7.yb.w4.h2"

    name =
      student.page
      |> Floki.find(name_target)
      |> Floki.text()
      |> String.trim()

    updated_student = Map.put(student, :name, name)
    updated_student
  end

  defp set_grades(student, classes) do
    class_target = ".w16.ha"
    grade_target = ".w18.hc"

    grades =
      Enum.map(classes, fn class ->
        found_class_target =
          student.page
          |> Floki.find(class_target)
          |> Enum.filter(fn c -> Floki.text(c) == class end)
          |> Enum.at(0)

        if found_class_target do
          found_class_target_text = Floki.text(found_class_target)

          if found_class_target_text == class do
            found_class_target_css =
              Floki.attribute(found_class_target, "class")
              |> Enum.at(0)
              |> String.replace(" ", ".")
              |> String.replace("c.", ".c.")

            common_class =
              Regex.run(~r/(.[y]\w+)/, found_class_target_css)
              |> Enum.uniq()
              |> Enum.at(0)

            class_grade_sibling_target =
              "#{found_class_target_css} ~ #{grade_target <> common_class}"

            class_grade_target =
              Floki.find(student.page, class_grade_sibling_target)
              |> Floki.text()

            grade =
              if class_grade_target == "",
                do: 0,
                else: class_grade_target |> Integer.parse() |> Kernel.elem(0)

            {found_class_target_text, grade}
          else
            {"Unknown Class", 0}
          end
        end
      end)
      |> Enum.filter(fn class -> not is_nil(class) end)

    updated_student = Map.put(student, :grades, grades)
    updated_student
  end

  defp set_cumulative(student) do
    case student.grades do
      [] ->
        IO.puts("#{student.name} has no grades!")
        student

      _ ->
        sum =
          Enum.reduce(student.grades, 0, fn {_class, grade}, acc ->
            if not is_nil(grade) do
              grade + acc
            else
              acc
            end
          end)

        cumulative =
          (sum / Enum.count(student.grades))
          |> Kernel.round()

        updated_student = Map.put(student, :cumulative, cumulative)
        updated_student
    end
  end
end

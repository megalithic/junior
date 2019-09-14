defmodule Junior.CLI do
  @moduledoc false

  use ExCLI.DSL, escript: true

  alias Junior

  name("junior")
  description("Parsing and grade calculation CLI tool")

  long_description(~s"""
  Parsing and grade calculation CLI tool
  """)

  command :start do
    aliases([])
    description("Begins the grade extraction and calculation process..")

    long_description("""
    Begins the grade extraction and calculation process..
    """)

    argument(:source)

    run context do
      IO.puts("Extracting and parsing grades..")
      Junior.start(context.source)
    end
  end
end

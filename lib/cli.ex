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

    argument(:source)
    option(:clean, type: :boolean, help: "Deletes previously stored files")

    run context do
      Junior.start(context.source, context[:clean])
    end
  end
end

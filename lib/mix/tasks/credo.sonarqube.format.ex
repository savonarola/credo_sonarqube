defmodule Mix.Tasks.Credo.Sonarqube.Format do
  use Mix.Task

  @shortdoc "Formats Credo json output as SonarQube generic issue data"
  @preferred_cli_env :test

  def parse_cli_args(cli_args) do
    optimus = Optimus.new!(
      name: "credo.sonarqube.format",
      allow_unknown_args: false,
      parse_double_dash: true,
      args: [
        infile: [
          value_name: "INPUT_FILE",
          help: "File with Credo json data",
          required: true,
          parser: :string
        ]
      ],
      flags: [
        pretty: [
          short: "-p",
          long: "--pretty",
          help: "Pretty print output json",
          multiple: false,
        ],
      ]
    )

    Optimus.parse!(optimus, cli_args)
  end

  @impl Mix.Task
  def run(cli_args) do
    parsed_cli = parse_cli_args(cli_args)
    case parsed_cli.args.infile |> File.read!() |> CredoSonarqube.reformat_issues(parsed_cli.flags.pretty) do
      {:ok, json} -> IO.puts(json)
      {:error, reason} ->
        IO.puts(:stderr, reason)
        System.halt(-1)
    end
  end

end

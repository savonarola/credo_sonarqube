defmodule CredoSonarqube do
  @moduledoc false

  @engine_id "Credo"

  @issue_type "CODE_SMELL"

  def reformat_issues(credo_issue_json, pretty \\ false) do
    with {:ok, credo_issues} <- parse(credo_issue_json),
        {:ok, sonar_issues} <- convert_issues(credo_issues)
    do
      {:ok, encode(sonar_issues, pretty)}
    else
      {:error, _} = err -> err
    end
  end

  defp parse(credo_issues_json) do
    case Jason.decode(credo_issues_json) do
      {:ok, _} = parsed -> parsed
      {:error, err} -> {:error, Jason.DecodeError.message(err)}
    end
  end

  defp convert_issues(%{"issues" => issues}) when is_list(issues) do
    sonar_issues = for %{} = issue <- issues, do: convert_issue(issue)
    {:ok, %{"issues" => sonar_issues}}
  end

  defp convert_issues(_) do
    {:error, "Expected credo issues in '{\"issues\": [...]}' format"}
  end

  defp encode(sonar_issues, pretty) do
    Jason.encode!(sonar_issues, pretty: pretty)
  end

  defp convert_issue(%{
      "category" => _category, # "refactor",
      "check" => check, # "Credo.Check.Refactor.CyclomaticComplexity",
      "column" => column, # 8,
      "column_end" => column_end, # 23,
      "filename" => filename, # "lib/optimus.ex",
      "line_no" => line_no, # 313,
      "message" => message, # "Function is too complex (CC is 12, max is 9).",
      "priority" => priority, # 5,
      "trigger" => _trigger # "parse_all_kinds"
    }) do
      %{
        "engineId" => @engine_id,
        "ruleId" => check,
        "severity" => severity(priority),
        "type" => @issue_type,
        "primaryLocation" => %{
          "message" => message,
          "filePath" => filename,
          "textRange" => %{
            "startLine" => line_no,
            "endLine" => line_no,
            "startColumn" => column,
            "endColumn" => column_end
          }
        },
      }
  end

  defp severity(priority) when is_integer(priority) and priority >= 20, do: "BLOCKER"
  defp severity(priority) when is_integer(priority) and priority >= 10, do: "CRITICAL"
  defp severity(priority) when is_integer(priority) and priority >= 1, do: "MAJOR"
  defp severity(priority) when is_integer(priority) and priority >= -10, do: "MINOR"
  defp severity(_priority), do: "INFO"



end

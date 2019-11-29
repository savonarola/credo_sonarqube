defmodule CredoSonarqubeTest do
  use ExUnit.Case
  doctest CredoSonarqube

  test "reformat_issues ok" do

    credo_issues = """
      {
        "issues": [
          {
            "category": "refactor",
            "check": "Credo.Check.Refactor.CyclomaticComplexity",
            "column": 8,
            "column_end": 23,
            "filename": "lib/optimus.ex",
            "line_no": 313,
            "message": "Function is too complex (CC is 12, max is 9).",
            "priority": 5,
            "trigger": "parse_all_kinds"
          }
        ]
      }
    """

    sonar_issues = """
    {
      "issues": [
        {
          "engineId": "Credo",
          "primaryLocation": {
            "filePath": "lib/optimus.ex",
            "message": "Function is too complex (CC is 12, max is 9).",
            "textRange": {
              "endColumn": 23,
              "endLine": 313,
              "startColumn": 8,
              "startLine": 313
            }
          },
          "ruleId": "Credo.Check.Refactor.CyclomaticComplexity",
          "severity": "MAJOR",
          "type": "CODE_SMELL"
        }
      ]
    }
    """

    assert {:ok, json} = CredoSonarqube.reformat_issues(credo_issues)
    assert Jason.decode!(json) == Jason.decode!(sonar_issues)

  end

  test "reformat_issues error" do

    credo_issues = """
      {
        "issues": {}
      }
    """

    assert {:error, _} = CredoSonarqube.reformat_issues(credo_issues)

    credo_issues = """
    {
      "issues": }{
    }
    """

    assert {:error, _} = CredoSonarqube.reformat_issues(credo_issues)

  end
end

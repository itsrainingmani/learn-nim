import re
import os
import strutils
import httpclient
import strformat

# Proc that reads a string, extracts the title and processes it into a suitable format for cargo
proc parseHTML(htmlString: string, day: string) : string {.raises: [ValueError].} =
  let pattern = re("--- Day " & day & ": (.+) ---")
  let results = findAll(htmlString, pattern)
  if results == @[]:
    raise newException(ValueError, "No Matches Found")
  else:
    var currentDay = results[0]
    currentDay = currentDay.replace(re"---", "").split(re": ")[1].strip(true, true, Whitespace)

    let challengeName: seq[string] = split(currentDay, re" ")
    var processedName: seq[string] = @["day" & day]

    for v in challengeName.items:
      processedName.add(v.toLower()[0 .. 4])

    result = processedName.join("-")

try:
  let arg: string = commandLineParams()[0]
  echo fmt"Generating Rust Project for Advent of Code 2020, Day {arg}:{'\n'}"

  let aocURL = "http://adventofcode.com/2020/day/" & arg

  let client = newHttpClient()
  let response = client.request(aocURL)

  if response.status == "200 OK":
    let data = response.body()

    let cargoProjName = parseHTML(data, arg)

    if execShellCmd("cargo new --bin " & cargoProjName) != 0:
      echo "Something went wrong. Couldn't generate Rust Project"
except:
  echo "ERROR: " & getCurrentExceptionMsg()

import winim/com
import std/parseopt
import os
from std/strutils import join, toLowerAscii

var args = commandLineParams().join(" ")
var params = initOptParser(args)

var Payload:string
var TargetFile:string
var Output:string
var Type:string

proc showHelp():void =
    echo """Usage: screxec.exe [OPTIONS] (Target File)
Ex: screxec.exe --payload=payload.dll --type=ProcessInjection pict.jpg
Options:
    --payload Payload to embed in the end result, must be either DLL or a shellcode file.
    -p shorthand for --payload

    --output output file name, better leave this empty
    -o shorthand for --output

    --type define how the scr file should execute the payload, can be Either:
        ProcessInjection, ExecuteFromDisk, RemoteProcessInjection
    -t shorthand for --type
    """


while true:
  params.next()
  case params.kind
  of cmdEnd: break
  of cmdShortOption, cmdLongOption:
    if toLowerAscii(params.key) == "p" or toLowerAscii(params.key) == "payload":
        Payload = params.val
    elif toLowerAscii(params.key) == "o" or toLowerAscii(params.key) == "output":
        Output = params.val
    elif toLowerAscii(params.key) == "t" or toLowerAscii(params.key) == "type":
        Type = params.val
    elif toLowerAscii(params.key) == "h" or toLowerAscii(params.key) == "help":
        showHelp()
        quit(0)
  of cmdArgument:
    TargetFile = params.key

if TargetFile == "":
    echo "Error: Please provide a valid target file."
    showHelp()
    quit(0)


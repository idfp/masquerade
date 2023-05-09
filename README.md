# Executable Masquerading
Generate an executable that acts like a normal file (JPG, PDF, DOCX etc) with the file data embedded directly inside PE. Made for spearphishing and personally I think this is effective (kinda). Built with Nim cause why not, I terribly hate C++ anyway.

> Disclaimer: <br>
> This tool is not intended for any illegal phishing attack, I made it specifically for my own usage in red-team demonstration and for other fellow red-teamer.
> Of course, in that way, all actions anyone done with this tool have nothing to do with me. And I highly discourage the very usage of this tool (cause, well, even if u're a legal pentester ur client will most likely despise spearphishing attacks).

![](https://github.com/idfp/masquerade/blob/main/assets/demo.gif)
## TODO:
- Linux environment supports (not linux based payloads.)
- Self Cleaning function (delete executable after execution and replace it with normal files.)
- Document known limitations.
- Write better use cases.
## Usage
```bash
masquerade.exe [OPTIONS] <targetfile>
Options:

    Basic:
    --payload=<path> Payload to embed in the end result, must be either DLL or a shellcode file.
    -p shorthand for --payload

    --output=<path> output file name, do not include the scr extension.
    -o shorthand for --output

    --type define how the scr file should execute the payload, can be Either:
        basic, ReflectivePE, or RunPE (default basic)
    -t shorthand for --type

    Advanced (might be useful for AMSI bypass):
    --naming=<rtl | normal> define how the file should be named, either using Right to left or normal (double extension, actually).
        rtl or normal (default normal)
    -n shorthand for --naming

    --disable-rename do not rename the file and keep it in template/ directory.
    -d shorthand for --disable-rename

    --use-exe rename the output file with .exe extension instead of .scr
    -e shorthand for --use-exe

    --add-random=<length> add random string by certain length to filename (with purpose of preventing users from realizing the double ext)
    -r shorthand for --add-random

```
Example: <br>

Generate an executable that loads pict.jpg when being run, and execute payload `test.exe` through reflective PE injection.
```sh
masquerade.exe --payload=test.exe --type=ReflectivePE pict.jpg
```
Generate the same thing, but write output file into `totally-not-suspicious.jpg.scr`
```sh
masquerade.exe --payload=test.exe --type=ReflectivePE --output=totally-not-suspicious.jpg pict.jpg
```

## Installation / Building
Make sure you have nim compiler loaded into your windows PATH plus its dependencies (mingw for compiling c / c++).
Then install all dependencies with nimble:
```bash
nimble install winim
```
Build `masquerade.nim` with this command:
```bash
nim c -d:release --threads:on masquerade.nim
```
the resulted `masquerade.exe` can be used as I exampled above.
### Payload Compiling
Any exe payload is fine actually (with some pitfalls, I'll explain it in later part). But if you want to compile the payload with Nim, make sure you build it this way:
```cmd
nim c -d:release -d:danger -d:strip --opt:size --threads:on --app:gui payload.nim
```
This will create a very compressed exe payload (around 60KB for basic Msgbox payload, without this it will sized 330KB).

## Pitfalls and Strategies
First thing I want to note, for both myself and the users is that this attack can be easily detected either by victim themselves or by the AMSI. In some cases the whole payload won't even get executed due to smartscreen blockage, forcing you to sign the executable (which is kinda hard, though possible, by signature cloning).

The Right-to-Left Override will most likely trigger smartscreen, so only use this to fool victim that have disabled their smartscreen. This is very disappointing since RTLO is so powerful to deceive even the eyes of experts. 

That doesn't mean RTLO is obsolete tho, with certain payload or algoritm, it's perfectly usable. In my first phase of development RTLO run perfectly, it only started to fail after certain implementation of file embedding.

On the other hand, double extension works finely for most cases. Just use `.exe` + `.jpg ` if u're not sure which one to choose, since `.scr` + `.jpg` failed in some scenario.

This tool perfectly suited for organization spearphishing that targets multiple person with different digital ecosystem. Since some of them might haven't turn on "show file extension" option while the other side might have disabled smartscreen and Av completely. 

### Changing Output Icon
use `rcedit.exe` in `bin` folder to edit ur executable icon. here's the syntax
```bash
rcedit.exe "(your exe file)" --set-icon (your ico file)
```
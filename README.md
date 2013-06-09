# Wizfrk Converter Script

So I made a little script that makes converting files for my phone easier.  I thought I'd share it so others don't have to be as frustrated as I was with the same tasks.

## Features:
Uses HandBrakeCli.exe to convert files to the "Normal" handbrake preset and automatically, burns in the first subtitles if available.
Uses lame.exe to convert files to mp3.
All files are created in the same directory as the original files.
Supports queuing, meaning you don't have multiple instances of the encoder running, eating RAM and cpu.
Instructions:
Download the archive.
Extract it to preferred location.
Drag and drop a (single) file or folder onto converter.bat
The script will run, you can keep adding files the same way without interrupting the encode.
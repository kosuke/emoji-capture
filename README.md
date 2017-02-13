# Emoji Capture

This command line tool is used to generate emoji images for [emojispeak.com](http://emojispeak.com).

# Prerequisites

* macOS 10.12
* Xcode 8.12

# Build

* Open EmojiCapture project in Xcode and build.
* Alternatively, run `make` .

# Usage 

    $ emojicapture [option] -o <output_file> text

## Options:

* --font : Specify path to alternative emoji font
* --size : Font size for emojis/full width characters (default: 48)
* --half : Font size for smaller characters including alphabets (default: 40)

## Examples:

### Basic usage

#### Command: 

    $ emojicapture -o samples/run.png "👾三三"

#### Result: 

![run](samples/run.png)

### With a newline

#### Command: 

    $ emojicapture --size 48 --half 40 -o samples/good-job.png "👮🏽👍🏽  🌚
    👖    👖" 

#### Result: 

![good-job](samples/good-job.png)

### With old emoji font

#### Command: 

    $ emojicapture --size 48 --half 40 -o samples/good-job-old.png "👮🏽👍🏽  🌚
    👖    👖" --font Apple\ Color\ Emoji.ttf

#### Result: 

![good-job-old](samples/good-job-old.png)

## Notes

* `--font` option requires a valid Apple Emoji font file, which should be obtainable from older versions of macOS.


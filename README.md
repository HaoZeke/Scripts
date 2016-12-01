# Scripts
These are some scripts I like to keep executable...
A lot of these, are borrowed, I merged some other things into this, to keep proper histories...

The entire lower README actually is from [https://github.com/nathanchance/scripts/blob/master/kernel.sh](Nathan Chance's scripts)

# Build scripts

These help with building various Android ROMs, kernels, and GApps. I use these on my build server/personal machine so they are tailored specifically to me but you are free to take these and modify them for your own needs.

## Usage
To add all these sub folders to your PATH (allowing you to run them in any folder), add this to your .bashrc:

`export PATH="${PATH}$(find <path_to_main_scripts_directory> -name '.*' -prune -o -type d -printf ':%p')"`

Then you will be able to run commands by calling source like so:
`bash <script_name>.sh <parameters>`
For example:
`bash rom.sh pn angler`

You may need certain packages installed. Feel free to checkout my [Android-Tools repo](https://github.com/nathanchance/Android-Tools) for an easy guide for configuring your build environments. Additionally, checkout the repos of the stuff you are compiling to see if they require any packages.

## Thanks
- @ezio84 and @fusionjack for the initial parameter idea
- @Mazda (and the whole DU team), @BeansTown106, and @xlxfoxxlx for the great ROMs
- @anarkia1976 for the initial kernel script
- @Surge1223 for praising scripts so much I decided to give it a shot
- Google for providing the answers during countless hours of research
- All you people reading this for giving it a look

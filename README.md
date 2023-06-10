# Magic Script
Tracking the energy usage of one of my characters from https://kaerwyn.com

This is a bash script I wrote to help me with bookkeeping of one of my characters over on a Creative Writing Group site I'm a member of.
The basics are that this character has a 'magic' system that utilizes regular old electricity to function.  I made this because I hadn't really seen any mana trackers out there and I wanted to have my own to kind of keep tabs on this character and explore their abilities quickly.  I'm putting this out in public both as a bit of transparency - if I'm utilizing this character in a story/campaign it's fairly simple to check my numbers - and also because, again, I wasn't able to find anything like this.  Hopefully with some modification it can fit someone else's needs.

Effectively this character's power usage is governed by the formula:

Energy=((10*Distance))+Mass^2/Efficiency

With energy in Watts (stored in Watt Hours), Distance in Meters, Mass in Kilograms, and Efficiency determined by his own skill with particular abilities.

## Pre-requisites:  

This makes use of several external programs, most of which should be on a default installation of Ubuntu Linux.  However, you may need the following:

bcmath
tmux
lolcat
figlet

## Usage:

Can be launched with `./marcus.sh` and no arguments.  This will display a short splash screen animation before launching tmux with the script, and a log of the commands you've used.

Alternatively, just the calculation prompt can be launched with `./marcus-calc.sh`.  This can either take no arguments, or the following:

`Max`
`Rested`
`Tired`
`Exhausted`
`Depleted`
`Custom (number)`

These will determine the starting levels of stored power; Max starts at the maximum defined power levels.
Rested starts somewhere between 75% and 100% of maximum power.
Tired starts somewhere between 50% and 75% of maximum power.
Exhausted starts somewhere between 25% and 50% of maximum power.
Depleted starts somewhere between 0% and 25% of maximum power.
Custom allows you to just specify a custom charge level.

When launching without arguments, or when launching the main script, you'll be prompted with the above options; in addition, you may specify whether the character is 'crippled', removing up to the maximum of 4 energy sources from the character.  This is there to help with physical injury/damages.  If crippled limbs are defined, then the maximum available energy will be lowered by 25% for each crippled limb.

Following this, you can specify whether a hologram is on or off; this is a basic illusion thing for the character that brings with it some minor persistent energy drain.

Finally, you'll be dropped to the main prompt.  All options are specified, however, to list them out, you may run an ability, move around, rest, recharge, set a custom energy level, turn the hologram on/off, or quit.

Default abilities are:

Glow
Shock
Grab
Heat
Noise

These can be invoked with their names, followed by three numbers in the format of Duration (in minutes) Mass (in Kilograms) and Distance (in Meters).

The command `holo` with the arguments `on` or `off` will toggle the additional persistent energy drain.

The following commands involve movement; they simply take a duration - in minutes, as an argument:

Rest
Move
Work

Rest will have a minimal average power drain.
Move will have an average amount of power drained.
Work will set the power drain to the maximum level that the character can take from physical movement.

You may also issue the command `reset <number>` in order to reset the energy usage to a particular level.  This script has minimal error catching, so sometimes it's possible to zero out the energy available with a malformed command.  The reset command will let you simply reset to the previous level and start over.

Finally, `quit` will allow you to quit the script; tmux and such will automatically close for you.  Note that there's a very naive way of closing the log file, so if you're accessing it in other programs those may also be killed when you exit.

## Acknowledgements

There's the wonderful people over at the Realm of Kaerwyn who have supported me with my creative endeavors, both with tech and with writing.

Finally, the splash image of this character is art which was created by John Fell as a Patreon reward back when he was doing that sort of stuff.  You can find his patreon - should he choose to resume activity there - over at https://www.patreon.com/Blue_Cheese

The image itself was converted from his work into ascii art by the ascii-to-image program from https://github.com/TheZoraiz/ascii-image-converter

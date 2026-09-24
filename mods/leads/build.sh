#!/usr/bin/env bash


###############################################################################
#                                                                             #
#  Build script for Leads                                                     #
#  Written in 2023 by Silver Sandstone <@SilverSandstone@craftodon.social>    #
#                                                                             #
#  To the extent possible under law, the author has dedicated all copyright   #
#  and related and neighbouring rights to this software to the public         #
#  domain worldwide. This software is distributed without any warranty.       #
#                                                                             #
#  You should have received a copy of the CC0 Public Domain Dedication        #
#  along with this software. If not, see                                      #
#  <https://creativecommons.org/publicdomain/zero/1.0/>.                      #
#                                                                             #
###############################################################################


function status()
{
    printf '\n\e[1m%s\e[m\n' "$*"
}


set -eu
cd "$(dirname "$0")"


status 'Generating documentation...'

ldoc './' -d 'doc/' -t 'Leads API Documentation'


status 'Creating distribution...'

archive='leads.zip'
[[ -e "$archive" ]] && rm "$archive"
zip -r "$archive" -- \
    *.lua            \
    mod.conf         \
    settingtypes.txt \
    README.md        \
    LICENCE.md       \
    CHANGELOG.md     \
    screenshot.png   \
    textures/        \
    models/          \
    sounds/          \
    locale/


status 'Build complete.'

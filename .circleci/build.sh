#!/bin/bash

# build.sh will build a Singularity container. It's not overly complicated.
#
# USAGE: build.sh Singularity

# Copyright (C) 2017-2019 Vanessa Sochat.

# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.

# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public
# License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

set -o errexit
set -o nounset

function usage() {

    echo "USAGE: build [recipe] [options]"
    echo ""
    echo "EXAMPLE:
          build.sh Singularity"
}

# --- Option processing --------------------------------------------------------

while true; do
    case ${1:-} in
        -h|--help|help)
            usage
            exit 0
        ;;
        \?) printf "illegal option: -%s\n" "${1:-}" >&2
            usage
            exit 1
        ;;
        -*)
            printf "illegal option: -%s\n" "${1:-}" >&2
            usage
            exit 1
        ;;
        *)
            break;
        ;;
    esac
done

################################################################################
### Recipe File ################################################################
################################################################################


if [ $# == 0 ] ; then
    recipe="Singularity"
else
    recipe=$1
fi

echo ""
echo "Image Recipe: ${recipe}"


################################################################################
### Build! #####################################################################
################################################################################

# Continue if the image recipe is found

if [ -f "$recipe" ]; then

    imagefile="${recipe}.simg"

    echo "Creating $imagefile using $recipe..."
    sudo singularity build $imagefile $recipe

    # If the image is successfully built, test it and upload (examples)
  
    if [ -f "${imagefile}" ]; then

        # Example testing using run (you could also use test command)

        echo "Testing the image... Marco!"
        singularity exec $imagefile echo "Polo!"
        echo "Image $imagefile is finished!"

    fi

else

    echo "Singularity recipe ${recipe} not found!"
    exit 1

fi

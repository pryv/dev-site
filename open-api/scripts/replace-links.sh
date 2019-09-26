#!/bin/sh



find transpiled \( -type d -name .git -prune \) -o -type f -print0 | xargs -0 sed -i "" -e "s/\.coffee/\.js/g" 

#!/bin/bash

EXIT=0
vagrant up spine-1 --color <<< 'spine-1 boot' || EXIT=$?
vagrant up spine-2 --color <<< 'spine-2 boot' || EXIT=$?
vagrant up leaf-1 --color <<< 'leaf-1 boot' || EXIT=$?
vagrant up leaf-2 --color <<< 'leaf-2 boot' || EXIT=$?
vagrant up leaf-3 --color <<< 'leaf-3 boot' || EXIT=$?
vagrant up leaf-4 --color <<< 'leaf-4 boot' || EXIT=$?
vagrant up og-1 --color <<< 'og-1 boot' || EXIT=$?
vagrant up og-3 --color <<< 'og-3 boot' || EXIT=$?
vagrant up cli-1 --color <<< 'cli-1 boot' || EXIT=$?
echo $EXIT
exit $EXIT

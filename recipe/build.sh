#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Patch package.json to remove unneeded prepare step
mv package.json package.json.bak
jq 'del(.scripts.prepare)' package.json.bak > package.json

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --no-bin-links \
    --global \
    --build-from-source \
    ${SRC_DIR}/${PKG_NAME}-${PKG_VERSION}.tgz

# Create license report for dependencies
pnpm install
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

mkdir ${PREFIX}/bin
tee ${PREFIX}/bin/eslint_d << EOF
exec \${CONDA_PREFIX}/lib/node_modules/eslint_d/bin/eslint_d.js "\$@"
EOF
chmod +x ${PREFIX}/bin/eslint_d

tee ${PREFIX}/bin/eslint_d.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\lib\node_modules\eslint_d\bin\eslint_d.js %*
EOF

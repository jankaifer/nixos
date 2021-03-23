#! /usr/bin/env nix-shell
#! nix-shell -i python3 -p python39 python39Packages.tqdm

import subprocess as sp
from tqdm import tqdm

IN_FILE = './extra-extensions'
OUT_FILE = './extra-extensions.nix'

with open(IN_FILE) as f:
    extra_extensions = f.read().split('\n')

nix_expressions = [
    sp.check_output(['./get-extension-definition.sh'] + extra_extension.split('.')).decode("utf-8")
    for extra_extension in tqdm(extra_extensions) if len(extra_extension) > 0 and extra_extension[0] != '#'
]

with open(OUT_FILE, 'w') as f:
    f.write("[\n")
    f.write("".join(nix_expressions))
    f.write("]\n")


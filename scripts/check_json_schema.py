#!/usr/bin/env python

""" Validate one JSON schema file, reproducing the Makefile's two per-file
checks: check-jsonschema against the metaschema named in the file's "$schema"
key, then scripts/validate_schema.py (propertyOrdering vs properties). The
generator invokes this as check_json_schema.py <input.json> <output.stamp>; the
stamp is written only on success. """

import json
import os
import subprocess
import sys


def main():
    """ main entry point """
    source, stamp = sys.argv[1], sys.argv[2]
    with open(source, encoding="utf-8") as handle:
        schema_url = json.load(handle).get("$schema")
    if schema_url:
        ret = subprocess.call(
            ["check-jsonschema", "--schemafile", schema_url, source])
        if ret != 0:
            sys.exit(ret)
    validator = os.path.join(os.path.dirname(__file__), "validate_schema.py")
    ret = subprocess.call([validator, source])
    if ret != 0:
        sys.exit(ret)
    os.makedirs(os.path.dirname(stamp), exist_ok=True)
    with open(stamp, "w", encoding="utf-8") as handle:
        handle.write("ok\n")


if __name__ == "__main__":
    main()

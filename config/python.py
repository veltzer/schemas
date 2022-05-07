import config.project

package_name = config.project.project_name

dev_requires = [
    "pymakehelper",
    "pydmt",
    "pyclassifiers",
]

install_requires = [
    "pycmdtools",
    "jsonschema",
    "JSON-Spec",
    "yq",
]

python_requires = ">=3.9"
test_os = ["ubuntu-20.04"]
test_python = ["3.9"]

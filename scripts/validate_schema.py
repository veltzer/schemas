#!/usr/bin/env python

"""
Validates that in a given JSON schema, for every object that has a
'propertyOrdering' array, that array is a perfect match for the keys
defined in the 'properties' object.
"""

import sys
import json
import argparse

def validate_schema_object(schema_part, path="root"):
    """
    Recursively traverses a schema and validates the 'propertyOrdering'
    for every object definition found.
    """
    # This list will accumulate any errors found during recursion.
    errors = []

    # --- Base Case: Perform validation on the current schema object ---
    # We only care about objects that define both properties and propertyOrdering.
    if isinstance(schema_part, dict) and schema_part.get("type") == "object":
        if "properties" in schema_part and "propertyOrdering" in schema_part:
            
            properties_keys = set(schema_part["properties"].keys())
            ordering_keys = set(schema_part["propertyOrdering"])

            # Check if the sets of keys are identical.
            if properties_keys != ordering_keys:
                missing_in_ordering = properties_keys - ordering_keys
                extra_in_ordering = ordering_keys - properties_keys
                
                error_message = f"Mismatch found at path: '{path}'"
                if missing_in_ordering:
                    error_message += f"\n  - Keys missing from 'propertyOrdering': {sorted(list(missing_in_ordering))}"
                if extra_in_ordering:
                    error_message += f"\n  - Keys in 'propertyOrdering' but not in 'properties': {sorted(list(extra_in_ordering))}"
                errors.append(error_message)

    # --- Recursive Step: Traverse into nested schema definitions ---
    if isinstance(schema_part, dict):
        # Recurse into properties
        for key, sub_schema in schema_part.get("properties", {}).items():
            errors.extend(validate_schema_object(sub_schema, f"{path}.properties.{key}"))

        # Recurse into array items
        if "items" in schema_part:
            errors.extend(validate_schema_object(schema_part["items"], f"{path}.items"))
            
        # Recurse into combiners (allOf, anyOf, oneOf)
        for combiner in ["allOf", "anyOf", "oneOf"]:
            if combiner in schema_part:
                for i, sub_schema in enumerate(schema_part[combiner]):
                    errors.extend(validate_schema_object(sub_schema, f"{path}.{combiner}[{i}]"))

    return errors

def process_schema_file(file_path):
    """
    Loads a JSON schema file and runs the validation on it.
    """
    print(f"--- Validating Schema: '{file_path}' ---")
    try:
        with open(file_path, encoding='utf8') as f:
            schema = json.load(f)
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON in file '{file_path}'.")
        print(f"  Details: {e}")
        return False
    except FileNotFoundError:
        print(f"Error: File not found at '{file_path}'.")
        return False

    validation_errors = validate_schema_object(schema)
    
    if validation_errors:
        print("Validation FAILED with the following errors:")
        for error in validation_errors:
            print(error)
        return False
    
    print("Validation successful: 'propertyOrdering' matches 'properties' throughout the schema.")
    return True

def main():
    """
    Main function to handle command-line arguments.
    """
    parser = argparse.ArgumentParser(
        description="Validate the 'propertyOrdering' fields within JSON schema files."
    )
    parser.add_argument("schema_files", nargs='+', help="One or more JSON schema files to validate.")
    args = parser.parse_args()

    overall_success = True
    for schema_file in args.schema_files:
        if not process_schema_file(schema_file):
            overall_success = False
        print("-" * (len(schema_file) + 25) + "\n")
    
    if not overall_success:
        print("One or more schemas failed validation.")
        sys.exit(1)

    print("All schemas passed validation successfully!")

if __name__ == "__main__":
    main()

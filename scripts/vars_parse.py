# Michael Johnson - Dec 2023
# Simple Python Script to parse CSV file with headers into python device variables

import csv
import uuid

with open('../../variables/device_variables.csv', 'r') as csv_file:
    reader = csv.reader(csv_file)

    # First pass of reading CSV file, seperate lines
    list_of_csv_lines = []
    for row in reader:
        list_of_csv_lines.append(row)

    # Preparing List for delivery as ansible vars
    ansible_vars = { 'devices': [] }
    itterations = len(list_of_csv_lines)
    # Track first itteration, as headers of CSV should not be added to vars
    itteration_index_value = 0

    for list in list_of_csv_lines:
        if itteration_index_value >= 1:
            value_setting = 0
            unit_dictionary = {}
            # Generate and add a UUID
            unit_dictionary['generated_uuid'] = str(uuid.uuid4())
            # Parse each item and add to value with key of csv header name
            for item in list:
                unit_dictionary[list_of_csv_lines[0][value_setting]] = item
                value_setting += 1
            working_unit = { 'unit': unit_dictionary }
            working_list = ansible_vars['devices']
            working_list.append(working_unit)
        # Catch on first itteration, that would be headers line in CSV
        else:
            itteration_index_value = itteration_index_value + 1

    print(ansible_vars['devices'])
    
    csv_file.close()

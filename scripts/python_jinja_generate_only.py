# Michael Johnson - Nov 2025
# Python Script to parse CSV file with headers and DO and AS3 from Jinja2 Templates

import csv
import uuid
from jinja2 import Environment, FileSystemLoader

ansible_vars_generate = {}

with open('./variables/device_variables.csv', 'r') as csv_file:
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
    
    ansible_vars_generate = ansible_vars

    csv_file.close()



# ansible_vars_generate

# BigIP_DO_template Template Filling
environment = Environment(loader=FileSystemLoader("templates/"))
template = environment.get_template("do_json_template.j2")
for unit in ansible_vars['devices']:

    # Extra layer for now to be compatible with legacy ansible jinja2 templates
    topitem = { 'item': unit }

    if 'bigip' == unit['unit']['role']:
        filename = f"do.bigip.{unit['unit']['hostname'].lower()}.json"
        content = template.render(topitem)
        with open("output/"+filename, mode="w", encoding="utf-8") as rendered_json:
            rendered_json.write(content)
            # print(f"... wrote {filename}")

# BigIQ_based_BigIP_DO_template Template Filling
environment = Environment(loader=FileSystemLoader("templates/"))
template = environment.get_template("do_bigiq_json_template.j2")
for unit in ansible_vars['devices']:

    # Extra layer for now to be compatible with legacy ansible jinja2 templates
    topitem = { 'item': unit }

    if 'bigip' == unit['unit']['role']:
        filename = f"do.bigiq.{unit['unit']['hostname'].lower()}.json"
        content = template.render(topitem)
        with open("output/"+filename, mode="w", encoding="utf-8") as rendered_json:
            rendered_json.write(content)
            # print(f"... wrote {filename}")


# # Future add as3 generate
# # BigIP_AS3_template Template Filling
# environment = Environment(loader=FileSystemLoader("templates/"))
# template = environment.get_template("as3_json_template.j2")
# for unit in ansible_vars['devices']:

#     # Extra layer for now to be compatible with legacy ansible jinja2 templates
#     topitem = { 'item': unit }

#     if 'bigip' == unit['unit']['role']:
#         filename = f"as3.{unit['unit']['hostname'].lower()}.json"
#         content = template.render(topitem)
#         with open("output/"+filename, mode="w", encoding="utf-8") as rendered_json:
#             rendered_json.write(content)
#             # print(f"... wrote {filename}")

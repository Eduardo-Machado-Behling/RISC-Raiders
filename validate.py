import re


def parse_log(log_text):
    pattern = re.compile(r"INFO: contains - (\d+),(\d+)\|0x0 \d+x\d+|"
                         r"Inserting rect: (\d+)\|(\d+)\|(\d+)\|0x[0-9a-f]+\|0x[0-9a-f]+|"
                         r"INFO: added")

    entries = []
    current_entry = None

    for line in log_text.split("\n"):
        contains_match = re.match(r"INFO: contains - (\d+),(\d+)\|0x0", line)
        insert_match = re.match(
            r"Inserting rect: (\d+)\|(\d+)\|(\d+)\|0x[0-9a-f]+\|0x[0-9a-f]+", line)
        added_match = re.match(r"INFO: added", line)

        if contains_match:
            if current_entry:
                entries.append(current_entry)
            current_entry = {"contains": (int(contains_match.group(1)), int(
                contains_match.group(2))), "inserts": []}
        elif insert_match:
            if current_entry:
                insert_data = (int(insert_match.group(1)), int(
                    insert_match.group(2)), int(insert_match.group(3)))
                current_entry["inserts"].append(insert_data)
        elif added_match and current_entry:
            entries.append(current_entry)
            current_entry = None

    return entries


def validate_entries(entries):
    for entry in entries:
        contains_x, contains_y = entry["contains"]
        valid = all(x == contains_x and y == contains_y for x,
                    y, _ in entry["inserts"])

        if not valid:
            print(
                f"Error: Inconsistent insert in contains ({contains_x}, {contains_y})")
        else:
            print(f"Valid entry for ({contains_x}, {contains_y})")


if __name__ == "__main__":
    with open("log.txt", 'r') as f:
        log_data = f.read()
        parsed_entries = parse_log(log_data)
        validate_entries(parsed_entries)

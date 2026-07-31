import json
import os

with open('assets/data/park_1_children.json', 'r') as f:
    data = json.load(f)

parks = data["data"]["parks"]

for park in parks:
    # Prepare park detail file
    # The existing model expects a "park" root for individual detail files
    detail_data = {
        "park": {
            "id": park["id"],
            "type": "Park",
            "name": park["name"],
            "children": park["children"]
        }
    }

    file_path = f'assets/data/park_{park["id"]}_children.json'
    with open(file_path, 'w') as f:
        json.dump(detail_data, f, indent=2)
    print(f"Created {file_path}")

    # Prepare wait times file
    wait_times = []
    # park["children"] is a list of Lands, each has children (Facilities)
    for land in park["children"]:
        for facility in land["children"]:
            wait_times.append({
                "id": facility["id"],
                "name": facility["name"],
                "waitTime": 15, # Dummy wait time
                "status": "Operating"
            })

    wait_data = {"waitTimes": wait_times}
    wait_file = f'assets/data/wait_times_{park["id"]}.json'
    with open(wait_file, 'w') as f:
        json.dump(wait_data, f, indent=2)
    print(f"Created {wait_file}")

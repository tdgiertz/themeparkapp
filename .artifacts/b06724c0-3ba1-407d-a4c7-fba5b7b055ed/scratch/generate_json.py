import json

data = {
  "data": {
    "parks": [
      {
        "id": "p1",
        "type": "Park",
        "name": "Animal Kingdom",
        "children": [
          { "id": "a1", "type": "Attraction", "name": "Avatar Flight of Passage" },
          { "id": "a2", "type": "Attraction", "name": "Bluey's Wild World at Conservation Station" },
          { "id": "a3", "type": "Attraction", "name": "Expedition Everest - Legend of the Forbidden Mountain" },
          { "id": "a4", "type": "Attraction", "name": "Gorilla Falls Exploration Trail" },
          { "id": "a5", "type": "Attraction", "name": "Kali River Rapids" },
          { "id": "a6", "type": "Attraction", "name": "Kilimanjaro Safaris" },
          { "id": "a7", "type": "Attraction", "name": "Maharajah Jungle Trek" },
          { "id": "a8", "type": "Attraction", "name": "Meet Favorite Disney Pals at Adventurers Outpost" },
          { "id": "a9", "type": "Attraction", "name": "Na'vi River Journey" },
          { "id": "a10", "type": "Attraction", "name": "Rainforest Cafe at Disney's Animal Kingdom" },
          { "id": "a11", "type": "Attraction", "name": "Wildlife Express Train" },
          { "id": "a12", "type": "Attraction", "name": "Zootopia: Better Zoogether!" }
        ]
      },
      {
        "id": "p2",
        "type": "Park",
        "name": "Magic Kingdom",
        "children": [
          { "id": "a13", "type": "Attraction", "name": "\"it's a small world\"" },
          { "id": "a14", "type": "Attraction", "name": "Astro Orbiter" },
          { "id": "a15", "type": "Attraction", "name": "Big Thunder Mountain Railroad" },
          { "id": "a16", "type": "Attraction", "name": "Buzz Lightyear's Space Ranger Spin" },
          { "id": "a17", "type": "Attraction", "name": "Cinderella's Royal Table" },
          { "id": "a18", "type": "Attraction", "name": "Country Bear Musical Jamboree" },
          { "id": "a19", "type": "Attraction", "name": "Dumbo the Flying Elephant" },
          { "id": "a20", "type": "Attraction", "name": "Enchanted Tales with Belle" },
          { "id": "a21", "type": "Attraction", "name": "Haunted Mansion" },
          { "id": "a22", "type": "Attraction", "name": "Jungle Cruise" },
          { "id": "a23", "type": "Attraction", "name": "Mad Tea Party" },
          { "id": "a24", "type": "Attraction", "name": "Meet Ariel at Her Grotto" },
          { "id": "a25", "type": "Attraction", "name": "Meet Cinderella and a Visiting Princess at Princess Fairytale Hall" },
          { "id": "a26", "type": "Attraction", "name": "Meet Daring Disney Pals as Circus Stars at Pete's Silly Side Show" },
          { "id": "a27", "type": "Attraction", "name": "Meet Dashing Disney Pals as Circus Stars at Pete’s Silly Side Show" },
          { "id": "a28", "type": "Attraction", "name": "Meet Mickey at Town Square Theater" },
          { "id": "a29", "type": "Attraction", "name": "Meet Princess Tiana and a Visiting Princess at Princess Fairytale Hall" },
          { "id": "a30", "type": "Attraction", "name": "Mickey's PhilharMagic" },
          { "id": "a31", "type": "Attraction", "name": "Monsters Inc. Laugh Floor" },
          { "id": "a32", "type": "Attraction", "name": "Peter Pan's Flight" },
          { "id": "a33", "type": "Attraction", "name": "Pirates of the Caribbean" },
          { "id": "a34", "type": "Attraction", "name": "Prince Charming Regal Carrousel" },
          { "id": "a35", "type": "Attraction", "name": "Seven Dwarfs Mine Train" },
          { "id": "a36", "type": "Attraction", "name": "Space Mountain" },
          { "id": "a37", "type": "Attraction", "name": "Swiss Family Treehouse" },
          { "id": "a38", "type": "Attraction", "name": "TRON Lightcycle / Run" },
          { "id": "a39", "type": "Attraction", "name": "The Barnstormer" },
          { "id": "a40", "type": "Attraction", "name": "The Crystal Palace" },
          { "id": "a41", "type": "Attraction", "name": "The Hall of Presidents" },
          { "id": "a42", "type": "Attraction", "name": "The Magic Carpets of Aladdin" },
          { "id": "a43", "type": "Attraction", "name": "The Many Adventures of Winnie the Pooh" },
          { "id": "a44", "type": "Attraction", "name": "Tiana's Bayou Adventure" },
          { "id": "a45", "type": "Attraction", "name": "Tomorrowland Speedway" },
          { "id": "a46", "type": "Attraction", "name": "Tomorrowland Transit Authority PeopleMover" },
          { "id": "a47", "type": "Attraction", "name": "Under the Sea ~ Journey of The Little Mermaid" },
          { "id": "a48", "type": "Attraction", "name": "Walt Disney World Railroad - Fantasyland" },
          { "id": "a49", "type": "Attraction", "name": "Walt Disney World Railroad - Main Street, U.S.A." },
          { "id": "a50", "type": "Attraction", "name": "Walt Disney's Enchanted Tiki Room" }
        ]
      },
      {
        "id": "p3",
        "type": "Park",
        "name": "Epcot",
        "children": [
          { "id": "a51", "type": "Attraction", "name": "Frozen Ever After" },
          { "id": "a52", "type": "Attraction", "name": "Garden Grill Restaurant" },
          { "id": "a53", "type": "Attraction", "name": "Gran Fiesta Tour Starring The Three Caballeros" },
          { "id": "a54", "type": "Attraction", "name": "Guardians of the Galaxy: Cosmic Rewind" },
          { "id": "a55", "type": "Attraction", "name": "Journey Into Imagination With Figment" },
          { "id": "a56", "type": "Attraction", "name": "Living with the Land" },
          { "id": "a57", "type": "Attraction", "name": "Meet Anna and Elsa at Royal Sommerhus" },
          { "id": "a58", "type": "Attraction", "name": "Meet Beloved Disney Pals at Mickey & Friends" },
          { "id": "a59", "type": "Attraction", "name": "Mission: SPACE" },
          { "id": "a60", "type": "Attraction", "name": "Reflections of China" },
          { "id": "a61", "type": "Attraction", "name": "Remy's Ratatouille Adventure" },
          { "id": "a62", "type": "Attraction", "name": "Soarin' Across America" },
          { "id": "a63", "type": "Attraction", "name": "Spaceship Earth" },
          { "id": "a64", "type": "Attraction", "name": "The Seas with Nemo & Friends" },
          { "id": "a65", "type": "Attraction", "name": "Turtle Talk With Crush" }
        ]
      },
      {
        "id": "p4",
        "type": "Park",
        "name": "Hollywood Studios",
        "children": [
          { "id": "a66", "type": "Attraction", "name": "Alien Swirling Saucers" },
          { "id": "a67", "type": "Attraction", "name": "Hollywood & Vine" },
          { "id": "a68", "type": "Attraction", "name": "Meet Disney Stars at Red Carpet Dreams" },
          { "id": "a69", "type": "Attraction", "name": "Meet Edna Mode at the Edna Mode Experience" },
          { "id": "a70", "type": "Attraction", "name": "Meet Olaf at Celebrity Spotlight" },
          { "id": "a71", "type": "Attraction", "name": "Mickey & Minnie's Runaway Railway" },
          { "id": "a72", "type": "Attraction", "name": "Millennium Falcon: Smugglers Run" },
          { "id": "a73", "type": "Attraction", "name": "Rock \u2019n\u2019 Roller Coaster Starring The Muppets" },
          { "id": "a74", "type": "Attraction", "name": "Slinky Dog Dash" },
          { "id": "a75", "type": "Attraction", "name": "Star Tours \u2013 The Adventures Continue" },
          { "id": "a76", "type": "Attraction", "name": "The Twilight Zone Tower of Terror" },
          { "id": "a77", "type": "Attraction", "name": "Toy Story Mania!" },
          { "id": "a78", "type": "Attraction", "name": "Vacation Fun - An Original Animated Short with Mickey & Minnie" }
        ]
      },
      {
        "id": "p5",
        "type": "Park",
        "name": "Universal Studios",
        "children": [
          { "id": "a79", "type": "Attraction", "name": "Despicable Me Minion Mayhem" },
          { "id": "a80", "type": "Attraction", "name": "Fast & Furious - Supercharged" },
          { "id": "a81", "type": "Attraction", "name": "Harry Potter and the Escape from Gringotts" },
          { "id": "a82", "type": "Attraction", "name": "Hogwarts Express - King's Cross Station" },
          { "id": "a83", "type": "Attraction", "name": "Kang & Kodos' Twirl 'n' Hurl" },
          { "id": "a84", "type": "Attraction", "name": "MEN IN BLACK Alien Attack" },
          { "id": "a85", "type": "Attraction", "name": "Race Through New York Starring Jimmy Fallon" },
          { "id": "a86", "type": "Attraction", "name": "Revenge of the Mummy" },
          { "id": "a87", "type": "Attraction", "name": "TRANSFORMERS: The Ride-3D" },
          { "id": "a88", "type": "Attraction", "name": "The Simpsons Ride" },
          { "id": "a89", "type": "Attraction", "name": "Villain-Con Minion Blast" }
        ]
      },
      {
        "id": "p6",
        "type": "Park",
        "name": "Islands of Adventure",
        "children": [
          { "id": "a90", "type": "Attraction", "name": "Caro-Seuss-el" },
          { "id": "a91", "type": "Attraction", "name": "Doctor Doom's Fearfall" },
          { "id": "a92", "type": "Attraction", "name": "Dudley Do-Right's Ripsaw Falls" },
          { "id": "a93", "type": "Attraction", "name": "Flight of the Hippogriff" },
          { "id": "a94", "type": "Attraction", "name": "Hagrid's Magical Creatures Motorbike Adventure" },
          { "id": "a95", "type": "Attraction", "name": "Harry Potter and the Forbidden Journey" },
          { "id": "a96", "type": "Attraction", "name": "Hogwarts Express - Hogsmeade Station" },
          { "id": "a97", "type": "Attraction", "name": "Jurassic World VelociCoaster" },
          { "id": "a98", "type": "Attraction", "name": "Ollivanders Experience in Hogsmeade" },
          { "id": "a99", "type": "Attraction", "name": "One Fish, Two Fish, Red Fish, Blue Fish" },
          { "id": "a100", "type": "Attraction", "name": "Popeye & Bluto's Bilge-Rat Barges" },
          { "id": "a101", "type": "Attraction", "name": "Pteranodon Flyers" },
          { "id": "a102", "type": "Attraction", "name": "Skull Island: Reign of Kong" },
          { "id": "a103", "type": "Attraction", "name": "Storm Force Accelatron" },
          { "id": "a104", "type": "Attraction", "name": "The Amazing Adventures of Spider-Man" },
          { "id": "a105", "type": "Attraction", "name": "The Cat in The Hat" },
          { "id": "a106", "type": "Attraction", "name": "The High in the Sky Seuss Trolley Train Ride!" },
          { "id": "a107", "type": "Attraction", "name": "The Incredible Hulk Coaster" }
        ]
      },
      {
        "id": "p7",
        "type": "Park",
        "name": "Epic Universe",
        "children": [
          { "id": "a108", "type": "Attraction", "name": "Bowser Jr. Challenge" },
          { "id": "a109", "type": "Attraction", "name": "Constellation Carousel" },
          { "id": "a110", "type": "Attraction", "name": "Curse of the Werewolf" },
          { "id": "a111", "type": "Attraction", "name": "Dragon Racer's Rally" },
          { "id": "a112", "type": "Attraction", "name": "Fyre Drill" },
          { "id": "a113", "type": "Attraction", "name": "Harry Potter and the Battle at the Ministry" },
          { "id": "a114", "type": "Attraction", "name": "Hiccup's Wing Gliders" },
          { "id": "a115", "type": "Attraction", "name": "Mario Kart: Bowser's Challenge" },
          { "id": "a116", "type": "Attraction", "name": "Meet Toothless and Friends" },
          { "id": "a117", "type": "Attraction", "name": "Mine-Cart Madness" },
          { "id": "a118", "type": "Attraction", "name": "Monsters Unchained: The Frankenstein Experiment" },
          { "id": "a119", "type": "Attraction", "name": "Stardust Racers" },
          { "id": "a120", "type": "Attraction", "name": "Yoshi's Adventure" }
        ]
      }
    ]
  }
}

for park in data["data"]["parks"]:
    new_children = []
    # Create a "Main Attractions" Land to keep compatibility with models if they expect a Land layer
    # Actually, I'll just add the missing properties to the Attractions directly.
    # The models expect: Facility(id, type, category, name, thrillLevel, heightRequirementInches)
    # and Land(id, type, name, children: List<Facility>)
    # So I MUST have a Land layer if I want to use the existing ParkDetail model.

    land = {
        "id": f"l-{park['id']}",
        "type": "Land",
        "name": "Main Attractions",
        "children": []
    }

    for att in park["children"]:
        facility = {
            "id": att["id"],
            "type": "Facility", # Existing code uses "Facility" for attractions
            "category": "Ride",
            "name": att["name"],
            "thrillLevel": "Moderate",
            "heightRequirementInches": 0
        }
        # Randomize thrill level a bit
        if "Coaster" in att["name"] or "Mountain" in att["name"] or "Everest" in att["name"] or "Terror" in att["name"]:
            facility["thrillLevel"] = "High"
            facility["heightRequirementInches"] = 40
        elif "Meet" in att["name"] or "Trail" in att["name"] or "Trek" in att["name"] or "Small World" in att["name"].lower():
            facility["thrillLevel"] = "Low"
            facility["heightRequirementInches"] = 0

        land["children"].append(facility)

    park["children"] = [land]

print(json.dumps(data, indent=2))

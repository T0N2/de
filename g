import tkinter as tk
import random

class Encounter:
    """Represents a single encounter with an entity or event."""
    def __init__(self, encounter_type, description):
        self.type = encounter_type
        self.health = self.set_health(encounter_type)
        self.description = description
        self.responses = self.set_responses(encounter_type)
        self.loot = self.set_loot(encounter_type)
        self.attack_power = self.set_attack_power(encounter_type)

    def set_health(self, encounter_type):
        health_dict = {"wolf": 30, "dragon": 150, "bandit": 40, "goblin": 20, "troll": 70}
        return health_dict.get(encounter_type, 0)

    def set_responses(self, encounter_type):
        responses = {
            "wolf": {"attack": "You attack the wolf!", "run": "You flee from the wolf."},
            "merchant": {"buy": "Browse the merchant's wares.", "talk": "Chat with the merchant."},
            "villager": {"accept": "Agree to help the villager.", "decline": "Turn down their plea for help."},
            "quest": {"accept": "Accept the quest.", "decline": "Refuse the quest and move on."},
        }
        return responses.get(encounter_type, {"attack": "You attack!", "run": "You flee!"})

    def set_loot(self, encounter_type):
        loot_dict = {
            "wolf": ["Wolf Pelt"],
            "dragon": ["Dragon Scale", "Pile of Gold"],
            "bandit": ["Gold Coins", "Bandit's Dagger"],
            "goblin": ["Rusty Knife"],
            "troll": ["Troll Club"],
        }
        return loot_dict.get(encounter_type, [])

    def set_attack_power(self, encounter_type):
        attack_dict = {"wolf": 5, "dragon": 25, "bandit": 10, "goblin": 4, "troll": 15}
        return attack_dict.get(encounter_type, 0)

class Player:
    def __init__(self, name, difficulty):
        self.name = name
        self.health = 100 - (difficulty * 20)
        self.inventory = []
        self.weapon = "Fists"
        self.gold = 50
        self.attack_power = 5

    def adjust_health(self, amount):
        self.health += amount
        if self.health > 100:
            self.health = 100
        if self.health <= 0:
            self.health = 0

    def equip_weapon(self, weapon, power):
        self.weapon = weapon
        self.attack_power = power

class Game:
    def __init__(self, root):
        self.root = root
        self.player = None
        self.current_encounter = None
        self.story_prompts = self.load_story_prompts()
        self.setup_gui()

    def load_story_prompts(self):
        """Loads a list of 50 unique story prompts."""
        return [
            "You find a hidden cave.",
            "A wolf howls in the distance.",
            "A dragon soars overhead.",
            "A mysterious fog envelops the area.",
            "A villager seeks your help to find their lost child.",
            "A bandit demands your gold.",
            "You stumble upon a treasure chest.",
            "A goblin ambushes you from the bushes.",
            "A troll blocks your path and demands a toll.",
            "You hear whispers coming from an ancient ruin.",
            "A weary traveler offers to trade items.",
            "You find a map to a hidden treasure.",
            "A merchant sets up shop in the middle of the road.",
            "An injured knight asks for aid.",
            "A glowing orb hovers before you.",
            "A sacred amulet lies on an altar.",
            "A hidden trap springs into action.",
            "A ghostly apparition warns you of danger.",
            "You encounter a talking tree.",
            "A thunderstorm rages around you.",
            "A pack of wolves surrounds you.",
            "A band of thieves plots to attack.",
            "You find a lost puppy.",
            "A mysterious figure offers you a powerful weapon.",
            "A giant spider descends from the ceiling.",
            "You find an old diary with cryptic messages.",
            "A magical spring heals your wounds.",
            "A cursed sword glows with dark energy.",
            "A wizard offers to sell you spells.",
            "A potion seller boasts of their wares.",
            "You hear the roar of a distant dragon.",
            "An earthquake shakes the ground.",
            "A magical portal opens before you.",
            "A wandering bard sings a tale of heroes.",
            "You are ambushed by a swarm of bats.",
            "You discover a hidden village.",
            "A riddle carved in stone blocks your path.",
            "A griffon soars overhead.",
            "You stumble upon a battlefield littered with bones.",
            "A hunter asks for your help tracking a beast.",
            "A thief tries to pickpocket you.",
            "A hermit offers sage advice.",
            "A glowing crystal catches your eye.",
            "A merchant caravan invites you to join them.",
            "A storm threatens to sink your ship.",
            "You find a letter addressed to someone unknown.",
            "A mysterious shadow follows you.",
            "A child gives you a flower for luck.",
            "A strange noise comes from the forest.",
            "You reach the gates of a haunted castle.",
        ]

    def setup_gui(self):
        self.root.title("Text Adventure Game")
        self.story_text = tk.Text(self.root, wrap="word", bg="white", fg="black", font=("Courier", 12), state="disabled")
        self.story_text.pack(fill="both", expand=True, pady=5)

        self.action_buttons_frame = tk.Frame(self.root)
        self.action_buttons_frame.pack(pady=10)

        self.stats_label = tk.Label(self.root, text="", bg="black", fg="white", font=("Courier", 10))
        self.stats_label.pack(fill="x", pady=5)

        self.show_start_screen()

    def show_start_screen(self):
        for widget in self.action_buttons_frame.winfo_children():
            widget.destroy()

        self.update_story("Welcome to the Text Adventure Game!\n\nEnter your name and choose a difficulty level.")

        name_label = tk.Label(self.action_buttons_frame, text="Name:")
        name_label.pack(side="left", padx=5)
        name_entry = tk.Entry(self.action_buttons_frame)
        name_entry.pack(side="left", padx=5)

        difficulty_label = tk.Label(self.action_buttons_frame, text="Difficulty (1-3):")
        difficulty_label.pack(side="left", padx=5)
        difficulty_entry = tk.Entry(self.action_buttons_frame)
        difficulty_entry.pack(side="left", padx=5)

        def start_game():
            name = name_entry.get() or "Adventurer"
            try:
                difficulty = int(difficulty_entry.get())
                if difficulty not in [1, 2, 3]:
                    raise ValueError
            except ValueError:
                self.update_story("Invalid difficulty. Setting to default (1).")
                difficulty = 1
            self.player = Player(name, difficulty)
            self.update_stats()
            self.prepare_next_event()

        start_button = tk.Button(self.action_buttons_frame, text="Start", command=start_game)
        start_button.pack(side="left", padx=5)

    def update_stats(self):
        inventory = ", ".join(self.player.inventory) or "Empty"
        self.stats_label.config(
            text=f"Name: {self.player.name}  |  Health: {self.player.health}  |  Weapon: {self.player.weapon}  |  Inventory: {inventory}  |  Gold: {self.player.gold}"
        )

    def update_story(self, text):
        self.story_text.config(state="normal")
        self.story_text.insert("end", f"\n{text}\n")
        self.story_text.see("end")
        self.story_text.config(state="disabled")

    def prepare_next_event(self):
        description = random.choice(self.story_prompts)
        encounter_type = random.choice(["wolf", "merchant", "villager", "dragon", "bandit", "goblin", "troll"])
        self.current_encounter = Encounter(encounter_type, description)
        self.update_story(self.current_encounter.description)
        self.handle_encounter_options(encounter_type)

    def handle_encounter_options(self, encounter_type):
        """Presents and handles options for the current encounter."""
        for widget in self.action_buttons_frame.winfo_children():
            widget.destroy()

        if encounter_type in ["wolf", "dragon", "bandit", "goblin", "troll"]:
            self.update_story(f"A {encounter_type} appears! What will you do?")
            attack_button = tk.Button(self.action_buttons_frame, text="Attack", command=self.resolve_combat)
            attack_button.pack(side="left", padx=5)
            run_button = tk.Button(self.action_buttons_frame, text="Run", command=self.run_away)
            run_button.pack(side="left", padx=5)

        elif encounter_type == "merchant":
            self.update_story("You meet a merchant. They offer goods for sale.")
            buy_button = tk.Button(self.action_buttons_frame, text="Buy", command=self.browse_merchant)
            buy_button.pack(side="left", padx=5)
            talk_button = tk.Button(self.action_buttons_frame, text="Talk", command=lambda: self.update_story("You have a pleasant chat with the merchant."))
            talk_button.pack(side="left", padx=5)

        elif encounter_type == "villager":
            self.update_story("A frightened villager begs for your help.")
            accept_button = tk.Button(self.action_buttons_frame, text="Help", command=lambda: self.update_story("You accept the villager's plea and embark on their quest!"))
            accept_button.pack(side="left", padx=5)
            decline_button = tk.Button(self.action_buttons_frame, text="Decline", command=self.prepare_next_event)
            decline_button.pack(side="left", padx=5)

        else:
            self.update_story(f"An event unfolds: {self.current_encounter.description}")
            continue_button = tk.Button(self.action_buttons_frame, text="Continue", command=self.prepare_next_event)
            continue_button.pack(side="left", padx=5)

    def resolve_combat(self):
        """Handles combat mechanics for encounters with hostile entities."""
        enemy = self.current_encounter
        self.update_story(f"You attack the {enemy.type} with your {self.player.weapon}!")
        
        # Player attacks first
        damage_to_enemy = random.randint(self.player.attack_power - 2, self.player.attack_power + 2)
        enemy.health -= damage_to_enemy
        self.update_story(f"You deal {damage_to_enemy} damage to the {enemy.type}. It has {enemy.health} health remaining.")

        # Check if enemy is defeated
        if enemy.health <= 0:
            self.update_story(f"You have defeated the {enemy.type}!")
            self.player.inventory.extend(enemy.loot)
            self.player.gold += random.randint(10, 50)
            self.update_story(f"You loot: {', '.join(enemy.loot)}. You now have {self.player.gold} gold.")
            self.update_stats()
            self.prepare_next_event()
            return

        # Enemy attacks back
        damage_to_player = random.randint(enemy.attack_power - 2, enemy.attack_power + 2)
        self.player.adjust_health(-damage_to_player)
        self.update_story(f"The {enemy.type} strikes back and deals {damage_to_player} damage!")
        self.update_stats()

        # Check if the player is defeated
        if self.player.health <= 0:
            self.end_game("defeat")
        else:
            self.handle_encounter_options(enemy.type)

    def run_away(self):
        """Handles the outcome of running away from a hostile encounter."""
        success = random.choice([True, False])
        if success:
            self.update_story("You successfully escaped!")
            self.prepare_next_event()
        else:
            self.update_story("You failed to escape and the enemy attacks!")
            self.resolve_combat()

    def browse_merchant(self):
        """Handles the trading interaction with a merchant."""
        self.update_story("The merchant shows you their wares: Sword (20 gold), Shield (15 gold), Potion (10 gold).")
        for widget in self.action_buttons_frame.winfo_children():
            widget.destroy()

        def buy_item(item, cost, benefit=None):
            if self.player.gold >= cost:
                self.player.gold -= cost
                self.player.inventory.append(item)
                if benefit == "health":
                    self.player.adjust_health(20)
                elif benefit == "weapon":
                    self.player.equip_weapon("Sword", 15)
                self.update_story(f"You purchased a {item}.")
            else:
                self.update_story("You don't have enough gold.")
            self.update_stats()
            self.prepare_next_event()

        sword_button = tk.Button(self.action_buttons_frame, text="Buy Sword (20 gold)", command=lambda: buy_item("Sword", 20, "weapon"))
        sword_button.pack(side="left", padx=5)
        shield_button = tk.Button(self.action_buttons_frame, text="Buy Shield (15 gold)", command=lambda: buy_item("Shield", 15))
        shield_button.pack(side="left", padx=5)
        potion_button = tk.Button(self.action_buttons_frame, text="Buy Potion (10 gold)", command=lambda: buy_item("Potion", 10, "health"))
        potion_button.pack(side="left", padx=5)
        leave_button = tk.Button(self.action_buttons_frame, text="Leave", command=self.prepare_next_event)
        leave_button.pack(side="left", padx=5)

    def end_game(self, outcome):
        """Handles the end of the game."""
        for widget in self.action_buttons_frame.winfo_children():
            widget.destroy()

        if outcome == "defeat":
            self.update_story("You have been defeated. The adventure ends here...")
        elif outcome == "victory":
            self.update_story("Congratulations! You have completed your quest!")
        else:
            self.update_story("Your journey comes to an end. Farewell, adventurer!")

        restart_button = tk.Button(self.action_buttons_frame, text="Restart", command=self.show_start_screen)
        restart_button.pack(side="left", padx=5)
        quit_button = tk.Button(self.action_buttons_frame, text="Quit", command=self.root.destroy)
        quit_button.pack(side="left", padx=5)


# Initialize and run the game
if __name__ == "__main__":
    root = tk.Tk()
    game = Game(root)
    root.mainloop()



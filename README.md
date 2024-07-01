This project is an implementation of the 1975 text-based game Hunt the Wumpus by Gregory Yob, arguably one of the first games in what we now call survival horror. This is my first project created in Godot to learn the software and scripting language. Hunt the Wumpus was chosen because of its limited scope, a simple game loop that is easy to implement, and it has 50 years of documentation and research. In-depth commentary is provided as a reference for more abstract GDScript concepts that were difficult for me to parse as a newcomer. For the sake of learning, I explicitly avoid using the Godot editor for tasks that can be accomplished in code e.g. connecting signals.

How to Play

Hunt the Wumpus is a game of survival horror where your goal is to find and shoot the cave-dwelling Wumpus. You are armed with a shotgun with 5 shells and can move or shoot into adjacent rooms. The cave is composed of 20 rooms with 3 exits each. Five “threats” are randomly placed at the start of the game: two sinkholes, two pitfalls, and the sleeping Wumpus. If an adjacent room contains a threat you are warned a threat is nearby.

Threats trigger when you enter their room. Sinkholes warn you of “shifting earth” and teleport you to a random room. Pitfalls warn you with a “gust of air” and end the game. The Wumpus warns you with its “terrifying presence” and ends the game. The Wumpus is a good climber and is unaffected by the other hazards.

When you shoot into an adjoining room the bullet will ricochet to random rooms until it either hits you, the Wumpus, a pitfall, or travels a maximum of 5 rooms. After firing, the Wumpus wakes up and either remains in its room or moves to an adjoining room. The game ends if the Wumpus moves into your room. If a ricocheting bullet hits you the game is over. If you run out of ammo you resign yourself to your horrible fate. Game over, man. Game over.

Designers Notes

This project was not just intended as a learning project but also as a gameplay component of an in-development game. The final version will be portrayed with an immersive visualizer displaying the cave from a first-person perspective as the player hunts the monster. Follow me on ITCHIO LINK for more of my work.

Ricocheting Bullets

In the original game you had a bow with “crooked arrows” and could input the arrow’s flight path up to 5 rooms. Because the furthest distance between any 2 spots on a dodecahedron is 5, and armed with 5 arrows, this made it trivial to blindly win the game. If you typed an illegal path, the game randomly determines the path possibly hitting you: because this is a game with perfect information of the map, I don’t understand how this was at all possible outside of user error.

I implemented the ricocheting bullets to capture the element of unpredictability the original designed proposed. It’s less likely to win the game by blindly firing and it’s more likely you’ll shoot yourself by accident. I also made the pitfalls barriers to further reduce the likelihood of blindly winning.

Changes to hazards

Sinkholes in the original game were giant bats that dropped you off in a random room. I changed them to sinkholes to fit the theme of the visual novel project I’m creating. Sinkholes are dangerous because they can teleport you into a hazardous room but there may be some strategic value to them.

Starting locations

In the original game the locations of hazards and the player was chosen randomly so long as the room didn’t already contain an element. This meant it was possible for the player to begin the game trapped (three exits occupied by pitfalls and the Wumpus) or even adjacent to the Wumpus. To make the game fairer and more difficult, I add the player to a room at least 3-spaces away from the Wumpus. This means around 7-9 rooms will be safe for the player to spawn in which I feel adds more mystery to the map.  

Credits

Hunt the Wumpus implemented in Godot v: 4.2 by Justen Brown. This project and its source code is released under CC0.
Hunt the Wumpus originally created by Gregory Yob, 1973. Source code published in Creative Computing, October 1975.

Special Thanks
benpa
ivy sly
AndreaJens
And other Godot devs at <dev zone> Discord channel

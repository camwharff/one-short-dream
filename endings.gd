extends Node


func generate_description() -> String:
	return _sat_text() + _perf_text() + _work_text() + _tidy_text() + "and your cat " + _cat_text() + _energy_text()


func _sat_text():
	var satisfaction = GameState.satisfaction
	if satisfaction < 0:
		return "At the end of work you felt really bad about the day you had, and you left feeling completely unfulfilled. "
	elif satisfaction >= 0 and satisfaction <= 10:
		return "At the end of work you felt okay about the day you had. You could have felt a bit more fulfilled, but you also could have felt a lot worse. "
	else:
		return "You felt great about your day today, and were as satisfied with your life as a person could be. "


func _perf_text():
	var performance = GameState.performance
	if performance < 0:
		return "You performed terribly at work. Maybe it's time to start refreshing the resume... "
	elif performance >= 0 and performance <= 20:
		return "You performed solidly at work. You may not be the star of the office, but you won't have to worry about your job anytime soon. "
	else:
		return "Your performance at work was legendary! Everyone in the office admired your work ethic. "


func _work_text():
	var performance = GameState.performance
	var s = ""
	if (
		GameState.completed["pitch-manager"]
		and GameState.completed["present"] and performance >= 20
	):
		s += "At the end of the day your boss called you in and praised the ideas that you pitched to your manager. "
		if GameState.completed["write-proposal"]:
			s += "As a result of your extra work, you are getting a raise! "
			if GameState.completed["call-mom"]:
				s += "You told your mom immediately, and she took you out for dinner to celebrate. "
			elif GameState.completed["respond-groupchat"]:
				s += "After work you went out with your coworkers to celebrate. "
				if GameState.completed["socialize-manager"]:
					s += "Even your manager came!"
			elif GameState.completed["socialize-manager"]:
				s += "After work your manager took you out to dinner to celebrate. "
		else:
			s += "If you keep up the hard work, you might earn a raise soon! "
			if GameState.completed["call-mom"]:
				s += "You told your mom about your ideas over a nice dinner. "
			elif GameState.completed["respond-groupchat"]:
				s += "After work you went out for dinner with your coworkers. "
				if GameState.completed["socialize-manager"]:
					s += "Even your manager came! "
	elif GameState.completed["present"]:
		if GameState.completed["call-mom"]:
			s += "You told your mom about your day over a nice dinner. "
			if GameState.completed["respond-groupchat"]:
				s += "After dinner, you went out with your coworkers. "
				if GameState.completed["socialize-manager"]:
					s += "Even your manager came! "
		elif GameState.completed["respond-groupchat"]:
			s += "After work you went out for dinner with your coworkers. "
			if GameState.completed["socialize-manager"]:
				s += "Even your manager came! "
	else:
		s += "At the end of the day your manager called you over and berated you in front of everyone for skipping the big presentation that she messaged you about. "
		if performance < 10:
			s += "Unfortunately, your performance at work was not enough to save you and she fired you on the spot. "
			if GameState.completed["respond-groupchat"]:
				"You left work and went out with your coworkers to mourn your job. "
			elif GameState.completed["call-mom"]:
				"You left work and went to dinner with your mom to mourn your job. "
		else:
			s += "Luckily for you, your performance at work was enough to save you this time... You might not be as fortunate in the future. "
			if GameState.completed["respond-groupchat"]:
				"You left work and went out with your coworkers to finish up the day. "
			elif GameState.completed["call-mom"]:
				"You left work and went to dinner with your mom. "

	return s


func _tidy_text():
	var tidiness = GameState.tidiness
	if tidiness < -2:
		return "You got home to a filthy apartment, "
	elif tidiness >= -2 and tidiness <= 4:
		return "Your apartment was just clean enough to feel comfortable, "
	else:
		return "Your apartment was immaculate when you got home, "


func _cat_text():
	if (
		GameState.completed["pet-cat"] and GameState.completed["clean-litter"]
		and GameState.completed["feed-cat"]
	):
		return "greeted you ecstatically at the door and settled down with you for a good night sleep. "
	elif GameState.completed["clean-litter"] and GameState.completed["feed-cat"]:
		return "greeted you happily at the door, then meowed at you for attention all night. "
	elif GameState.completed["clean-litter"]:
		return "greeted you at the door, then meowed at you for attention and food all night. "
	elif GameState.completed["feed-cat"]:
		return "greeted you at the door, then meowed at you for attention and sat next to its litter box all night. "
	else:
		return "ignored you all night, hiding under the bed until breakfast. "


func _energy_text():
	var energy = GameState.energy
	if energy < -3:
		return "You fell into bed exhausted, dreading tomorrow."
	elif energy >= -3 and energy <= 3:
		return "You had a long day, and were too tired to do anything fun before getting in bed."
	else:
		return "You felt energized despite the long day, and spent some time enjoying yourself before turning in for the night."

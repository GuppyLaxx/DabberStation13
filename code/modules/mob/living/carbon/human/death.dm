/mob/living/carbon/human/death(gibbed)
	if(src.stat == 2)
		return
	if(src.healths)
		src.healths.icon_state = "health5"
	src.stat = 2
	src.dizziness = 0
	src.jitteriness = 0
	world << "<b><font color='#BF5FFF'>[name] died!"
	world << 'dead.ogg'
	if (gibbed != 1)
		emote("deathgasp") //let the world KNOW WE ARE DEAD

		src.canmove = 0
		if(src.client)
			src.blind.layer = 0
		src.lying = 1
		var/h = src.hand
		src.hand = 0
		drop_item()
		src.hand = 1
		drop_item()
		src.hand = h
		if (istype(src.wear_suit, /obj/item/clothing/suit/armor/a_i_a_ptank))
			var/obj/item/clothing/suit/armor/a_i_a_ptank/A = src.wear_suit
			bombers += "[src.key] has detonated a suicide bomb. Temp = [A.part4.air_contents.temperature-T0C]."
			if(A.status && prob(90))
				A.part4.ignite()
		else
			abandon_mob_proc(1)

	var/tod = time2text(world.realtime,"hh:mm:ss") //weasellos time of death patch
	if(mind)
		mind.store_memory("Time of death: [tod]", 0)
	//src.icon_state = "dead"

	ticker.mode.check_win()

	if (ticker.mode.name == "traitor" && src.mind && src.mind.special_role == "traitor")
		message_admins("\red Traitor [key_name_admin(src)] has died.")

	return ..(gibbed)

/obj/item/weapon/storage/proc/return_inv()

	var/list/L = list(  )

	L += src.contents

	for(var/obj/item/weapon/storage/S in src)
		L += S.return_inv()
	for(var/obj/item/weapon/gift/G in src)
		L += G.gift
		if (istype(G.gift, /obj/item/weapon/storage))
			L += G.gift:return_inv()
	return L

/obj/item/weapon/storage/proc/show_to(mob/user as mob)
	for(var/obj/item/weapon/mousetrap/MT in src)
		if(MT.armed)
			for(var/mob/O in viewers(user, null))
				if(O == user)
					user.show_message(text("\red <B>You reach into the [src.name], but there was a live mousetrap in there!</B>"), 1)
				else
					user.show_message(text("\red <B>[user] reaches into the [src.name] and sets off a hidden mousetrap!</B>"), 1)
			MT.loc = user.loc
			MT.triggered(user, user.hand ? "l_hand" : "r_hand")
			MT.layer = OBJ_LAYER
			return
	user.client.screen -= src.boxes
	user.client.screen -= src.closer
	user.client.screen -= src.contents
	user.client.screen += src.boxes
	user.client.screen += src.closer
	user.client.screen += src.contents
	user.s_active = src
	return

/obj/item/weapon/storage/proc/hide_from(mob/user as mob)

	if(!user.client)
		return
	user.client.screen -= src.boxes
	user.client.screen -= src.closer
	user.client.screen -= src.contents
	return

/obj/item/weapon/storage/proc/close(mob/user as mob)

	src.hide_from(user)
	user.s_active = null
	return



/obj/item/weapon/storage/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if(can_hold.len)
		var/ok = 0
		for(var/A in can_hold)
			if(istype(W, text2path(A) )) ok = 1
		if(!ok)
			user << "\red This container cannot hold [W]."
			return

	if (src.contents.len >= 7)
		return
	if ((W.w_class >= 3 || istype(W, /obj/item/weapon/storage) || src.loc == W))
		return
	user.u_equip(W)
	W.loc = src
	if ((user.client && user.s_active != src))
		user.client.screen -= W
	src.orient2hud(user)
	W.dropped(user)
	W.plane = HUD_PLANE
	add_fingerprint(user)
	for(var/mob/O in viewers(user, null))
		O.show_message(text("\blue [] has added [] to []!", user, W, src), 1)
		//Foreach goto(139)
	return

/obj/item/weapon/storage/dropped(mob/user as mob)

	src.orient_objs(-3,3)
	return

/obj/item/weapon/storage/MouseDrop(over_object, src_location, over_location)
	..()
	if ((over_object == usr && (in_range(src, usr) || usr.contents.Find(src))))
		if (usr.s_active)
			usr.s_active.close(usr)
		src.show_to(usr)
	return

/obj/item/weapon/storage/attack_paw(mob/user as mob)
	playsound(src, "rustle", 50, 1, -5)
	return src.attack_hand(user)
	return

/obj/item/weapon/storage/attack_hand(mob/user as mob)
	playsound(src, "rustle", 50, 1, -5)
	if (src.loc == user)
		if (user.s_active)
			user.s_active.close(user)
		src.show_to(user)
	else
		..()
		for(var/mob/M in range(1))
			if (M.s_active == src)
				src.close(M)
			//Foreach goto(76)
		src.orient2hud(user)
	src.add_fingerprint(user)
	return

/obj/item/weapon/storage/New()

	create_storage()
	spawn( 5 )

		src.orient_objs(-3,3)
		return
	return

/obj/screen/storage/attackby(W, mob/user as mob)
	src.master.attackby(W, user)
	return

/obj/item/weapon/storage/box/New()

	new /obj/item/clothing/mask/breath( src )
	new /obj/item/weapon/tank/emergency_oxygen( src )
	..()
	return

/obj/item/weapon/storage/mousetraps/New()
	new /obj/item/weapon/mousetrap( src )
	new /obj/item/weapon/mousetrap( src )
	new /obj/item/weapon/mousetrap( src )
	new /obj/item/weapon/mousetrap( src )
	new /obj/item/weapon/mousetrap( src )
	new /obj/item/weapon/mousetrap( src )
	..()
	return

////////////////////////////////////////////////////////////////////////////////

/obj/item/weapon/storage/utilitybelt/proc/can_use()
	if(!ismob(loc)) return 0
	var/mob/M = loc
	if(src in M.get_equipped_items())
		return 1
	else
		return 0

/obj/item/weapon/storage/utilitybelt/dropped(mob/user as mob)
	..()

/obj/item/weapon/storage/utilitybelt/MouseDrop(obj/over_object as obj, src_location, over_location)
	var/mob/M = usr
	if (!istype(over_object, /obj/screen))
		if(can_use())
			return ..()
		else
			M << "\red I need to wear the belt for that."
			return
	playsound(src, "rustle", 50, 1, -5)
	if (!M.restrained() && !M.stat && can_use())
		if (over_object.name == "r_hand")
			if (!( M.r_hand ))
				M.u_equip(src)
				M.r_hand = src
		else
			if (over_object.name == "l_hand")
				if (!( M.l_hand ))
					M.u_equip(src)
					M.l_hand = src
		M.update_clothing()
		src.add_fingerprint(usr)
		return

/obj/item/weapon/storage/utilitybelt/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/item/weapon/storage/utilitybelt/attack_hand(mob/user as mob)
	if (src.loc == user)
		if(can_use())
			playsound(src, "rustle", 50, 1, -5)
			if (user.s_active)
				user.s_active.close(user)
			src.show_to(user)
		else
			user << "\red I need to wear the belt for that."
			return
	else
		return ..()

	src.add_fingerprint(user)

/obj/item/weapon/storage/utilitybelt/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(!can_use())
		user << "\red I need to wear the belt for that."
		return
	else
		..()
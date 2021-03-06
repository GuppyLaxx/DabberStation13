/*
Height Processing, Jumping, And all that other fancy stuff.
*/

var/Mobs = list()
//#define GRAVDEBUG  //Only define this if you want spammy shit.
#define FONTCOLOR "<font color='green'>Height Debug : "
#define SPIN_DIVIDER 1.25

datum/controller/game_controller
	proc
		do_gravity_loop() //Gravity loop, Call in a loop that runs at world.fps.
			for(var/mob/M in Mobs)
				//world << M
				M.ParallaxMove()
				M.ProcessHeight() //Process their Y Speed and height.
				if(M)
					if(istype(M,/mob/living/carbon/human))
						M:handle_regular_status_updates()
						M:handle_stomach()
						if(M.client)
							M:handle_regular_hud_updates()
					if(M.ANIMATION_RUNNING)
						M.dir = 2
						if(M.danc)
							M.danc.Update_Y()
		mobs_process()
			for(var/mob/M in Mobs)
				CHECK_TICK()
				M.Life()
mob
	New()
		..()
		Mobs += src
obj
	shadow
		color = list(rgb(0,0,0),rgb(0,0,0),rgb(0,0,0),rgb(0,0,0),rgb(0,0,0))
		anchored = 1
		layer = 3.999
		mouse_opacity = 0
		alpha = 150
		name = "shadow object"
		icon = 'extra images/boring shit.dmi'
		icon_state = "shadow"
		ex_act()
			return
		appearance_flags = PIXEL_SCALE | LONG_GLIDE | KEEP_TOGETHER

/image/lattice
	icon = 'structures.dmi'
	icon_state = "ass"
	appearance_flags = RESET_COLOR
	layer = 1

turf
	var/TurfGravity = 96/256 //Obvious variable names
	var/TurfStepSound = list('footstep1.ogg','footstep2.ogg','footstep3.ogg','footstep4.ogg')
	var/TurfHeight = 0
	var/TurfCeiling = 256
	mouse_opacity = 2 //Fixes RCD shit
	space
		TurfStepSound = null
		TurfGravity = 24/256
		TurfHeight = -416
		TurfCeiling = 0
		water_height = -999
	simulated
		New()
			..()
			spawn(5)
				var/turf/T = locate(x,y-1,z)
				if(T)
					if(T.TurfHeight < -8)
						T.underlays += new /image/lattice
		Del()
			var/turf/T = locate(x,y-1,z)
			if(T)
				if(T.TurfHeight < -8)
					T.underlays = null
			..()
		water_flooded
			water_height =  99999999
			TurfCeiling = 0
			icon = 'floors.dmi'
			icon_state = "sand1"
			name = "sand"
			New()
				..()
				Render_Water_Icon()
				if(prob(25))
					var/image/G = new()
					G.icon = 'seaweed.dmi'
					G.icon_state = "[pick("tallseaweed","grass","tallgrass")]"
					G.plane = MOB_PLANE+1
					if(G.icon_state == "grass")
						G.pixel_y = -32
					overlays += G
		floor
			plating
				level = 1
				icon_state = "plating"
				layer = 1.999
				var/has_cover = 1
				New()
					..()
					update_icon()
				update_icon()
					overlays = null
					if(has_cover)
						overlays += image("icon" = 'floors.dmi', "icon_state" = "plating_cover",layer=TURF_LAYER)
					..()
			level = 2
			New()
				..()
				if(TurfHeight >= 32)
					plane = MOB_PLANE_ALT
					Get_Layer_Y(-1)
/turf/simulated/floor/plating/water
	TurfHeight = 0

	ex_act()
		return
mob
	var/heightZ = 0 //Height.
	var/ySpeed = 0 //Y speed
	var/onFloor = 0 //Am I on floor?
	var/heightSize = 28
	var/pixel_y_2 = 0
	var/obj/shadow/MyShadow = null //Shadow. This is handled in master controller.

	#if defined(GRAVDEBUG)
	var/MessageCurr = ""
	#endif

	Del()
		ghostize(2)
		if(danc)
			del danc
		if(src in Mobs)
			Mobs -= src
		if(MyShadow)
			del MyShadow
		..()

	#if defined(GRAVDEBUG)
	verb/ChangeYSpeed(ass as num)
		ySpeed = ass
	#endif
	proc/Fling(severity)
		ySpeed = 5*severity
		current_angle_speed = 8*severity
	proc/Jump()
		var/turf/T = loc
		if(canmove == 1 && old_lying == 0 && !src.restrained() && !ANIMATION_RUNNING && istype(T,/turf) && round(current_angle_speed) == 0) //If on floor/space and not restrained...
			if(onFloor == 1)
				ySpeed = (1320/256)/(1+(heightZ<round(T.water_height)))
				playsound(src, 'jump.ogg', 100, 0, 12, 0)
			else
				flyPack()
	proc/flyPack()
		if(istype(src.back, /obj/item/weapon/tank/jetpack))
			var/j_pack = 0
			if (istype(src.back, /obj/item/weapon/tank/jetpack))
				var/obj/item/weapon/tank/jetpack/J = src.back
				j_pack = J.allow_thrust(0.01, src)
			if(j_pack)
				if(frm_counter % 5 == 1)
					var/obj/Particle/Spark/Jetpack/S = new()
					if(heightZ < 0)
						S.layer = 1.8
						S.plane = FLOOR_PLANE
					S.y_pos = heightZ+rand(0,2)
					S.x_pos = rand(11,18)
					S.Particle_Process()
					S.loc = loc
				ySpeed = ySpeed + (27/256)
	proc/ProcessHeight()
		if(!istype(src,/mob/living/carbon))
			return
		if(!MyShadow)
			MyShadow = new
			MyShadow.icon = icon
			MyShadow.icon_state = icon_state
			MyShadow.overlays = overlays
			MyShadow.underlays = underlays
		Get_Layer_Y((src.resting || src.lying/-10)) //People laying down are below you.
		pixel_collision_size_x = heightSize
		onFloor = 0
		var/turf/T = locate(x,y,z) //Gets turf player is stepping on.
		if(!loc || !istype(T,/turf) || veh)
			MyShadow.alpha = 0
			return //We cannot process height, either player is on a vehicle, or player is deleted (null) or what we are stepping on doesn't even have a turf.

		if(T.TurfCeiling != 0)
			if(heightZ > T.TurfCeiling)
				//world << "Set Height Z Ceiling"
				heightZ = T.TurfCeiling //god why does this limit exist
				ySpeed = 0

		ySpeed -= ( ( (heightZ > -8-heightSize) ? T.TurfGravity : 24/256)/(1+(client ? client.j : 0)+((heightZ > -8-heightSize)*(heightZ<T.water_height)) ) ) //Adds gravity.
		heightZ = heightZ + ySpeed //Changes height by speed.
		for(var/mob/i in loc)
			if(i != src)
				if(i.density)
					if(heightZ > i.heightZ-heightSize && heightZ < i.heightZ+(round(i.heightSize/2))) //if below
						heightZ = i.heightZ-heightSize
						ySpeed = 0
					if(heightZ < i.heightZ+i.heightSize && heightZ > i.heightZ+(round(i.heightSize/2))-1) //only stack if ontop or some bullshit
						onFloor = 1
						ySpeed = 0
						heightZ = i.heightZ+i.heightSize
						if(istype(src,/mob/living/carbon/human) && istype(src:shoes,/obj/item/clothing/shoes/brown/goomba_stomp))
							i.specialloss += 15
							playsound(src, 'hitJump.ogg', 100, 0, 12, 0)
							ySpeed = 3
		var/obj/lattice/LAT = locate(/obj/lattice) in loc
		if(LAT)
			if(ySpeed < 0)
				if(heightZ < 0 && heightZ > -8)
					if(ySpeed < -3)
						playsound(LAT, 'bang.ogg', 100, 0, 5, 0)
						del LAT
					else
						if(round(current_angle_speed) > 1)
							ySpeed = current_angle_speed / SPIN_DIVIDER
						else
							onFloor = 1
							ySpeed = 0
						heightZ = 0


		if(heightZ > -8-heightSize && heightZ < -1 && T.TurfHeight >= 0 && ySpeed > 0)
			heightZ = -8-heightSize
			//world << "set height (UNDER)"
			ySpeed = 0

		if(heightZ < T.TurfHeight && heightZ > -8-heightSize) //Don't make players go under the floor. todo fix this bullshit because turfs aren't being picked up correctly
			heightZ = T.TurfHeight
			//world << "set height (FLOOR)"
			if(round(current_angle_speed) > 1)
				ySpeed = current_angle_speed / SPIN_DIVIDER
			else
				onFloor = 1
				ySpeed = 0

		if(heightZ > T.TurfHeight)
			plane = MOB_PLANE_ALT
		else
			if(heightZ > 0)
				plane = MOB_PLANE_ALT
			else
				plane = MOB_PLANE //this is to fix the "lol airlocks are above me even tho im jumping"
		if(heightZ < 0)
			plane = FLOOR_PLANE
			layer = 1.9
		if(heightZ < -415 && !istype(src,/mob/dead))
			src << "<b><font color='red'>You were never seen again.."
			death(2)
			del src
		else
			if(heightZ < 0 && istype(src,/mob/dead))
				ySpeed = 0
				heightZ = 0

		if(MyShadow) //Handle shadow transparency.
			if(T.TurfHeight < -96)
				MyShadow.alpha = 0
			else
				MyShadow.alpha = max(70-((heightZ-T.TurfHeight)/4),30)
				MyShadow.pixel_z = T.TurfHeight+pixel_y_2
				if(T.TurfHeight < 0)
					MyShadow.layer = TURF_LAYER-0.05
				else
					MyShadow.layer = layer-0.05
				MyShadow.pixel_x = pixel_x+pixel_w
				MyShadow.glide_size = glide_size
				MyShadow.loc = loc
				MyShadow.dir = dir
				if(heightZ > 99998)
					MyShadow.alpha = 0

		if(world.fps < FPS_ANIMATE)
			animate(src,pixel_z = round(heightZ)+round(pixel_y_2),time = world.tick_lag) //smooth
		else
			pixel_z = round(heightZ)+round(pixel_y_2) //Set pixel_z.
		if(buckled)
			buckled.pixel_z = round(heightZ)
		if(c3)
			c3.alpha = T.water_height > 0 ? 255 : 0
			c3.screen_loc = "EAST:-4, CENTER-1:[-4+max(1,min(round((min(T.water_height,416)/416)*32)+1,30))]"
		if(c2)
			if(T.TurfHeight < -32)
				c2.icon_state = "heightNOFL"
			else
				c2.icon_state = "height"
		if(c1)
			c1.screen_loc = "EAST:-4, CENTER-1:[-4+max(1,min(round((min(heightZ,416)/416)*32)+1,30))]"
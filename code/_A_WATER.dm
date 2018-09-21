turf
	var/obj/water_overlay/gW1
	var/obj/water_overlay/gW2
	var/water_height = 0
	var/old_water_height = 0
	var/fully_cover = 0

	proc/Render_Water_Icon()
		if(!gW1)
			gW1 = new(locate(x,y,z))
			gW1.Get_Layer_Y(0.1)
			gW1.plane = MOB_PLANE_ALT
		if(!gW2)
			gW2 = new(locate(x,y,z))
			gW2.plane = LIGHT_PLANE
			gW2.layer = TURF_LAYER+0.5
		if(round(water_height) == round(old_water_height))
			return //We shouldn't update.
		var/rounded_height = round(water_height)
		if(fully_cover == 1 && round(water_height) < TurfHeight)
			return
		var/ass = (max(0,min(32,rounded_height))/32)*0.5
		var/ColorWater = rgb(35*(1-ass),137*(1-ass),218*(1-ass))
		gW1.color = ColorWater
		gW2.color = ColorWater
		gW1.icon_state = "[max(0,min(32,rounded_height))]"
		if(round(water_height) >= TurfHeight)
			if(rounded_height > 0)
				gW2.icon_state = "[max(0,min(32,32-rounded_height ))]"
				gW2.pixel_y = max(0,min(32,rounded_height))
			else
				gW2.icon_state = "0"
		if(round(max(0,min(32,water_height)))==32)
			gW1.plane = TOP_PLANE
		else
			gW1.plane = MOB_PLANE_ALT

		old_water_height = water_height

	Del()
		if(gW1)
			del gW1
		if(gW2)
			del gW2
		..()

#define DIR2PIXEL list("1" = list(0,1),"2" = list(0,-1),"4" = list(1,0),"8" = list(-1,0))
#define DIAGONALS list(SOUTHWEST,SOUTHEAST,NORTHWEST,NORTHEAST)
#define REVERSEDIRS list("1" = SOUTH,"2" = NORTH,"4" = WEST,"8" = EAST)
#define CARDINALS list(SOUTH,NORTH,EAST,WEST)
obj
	water_overlay
		icon = 'water sprites.dmi'
		anchored = 1
		mouse_opacity = 0
		color = rgb(35,137,218)
		alpha = 75
		ex_act()
			return
	water
		plane = CABLE_PLANE
		icon = 'water_pipes.dmi'
		pipes
			icon_state = "water_pipe"
			New()
				..()
				hide()
			hide()
				var/turf/T = locate(x,y,z)
				if(istype(T,/turf))
					if(level == 1)
						alpha = level < T.level ? 0 : 255
			Process_Water()
				if(water_pressure > 0)
					if(water_pressure_direction != 0)
						var/obj/water/pipes/G = locate(/obj/water/pipes) in get_step(src,water_pressure_direction)
						var/obj/water/device/D = locate() in get_step(src,water_pressure_direction)
						if(D)
							//world << "Filling a [D]"
							D.water_pressure += water_pressure
							water_pressure = 0
							return
						if(G)
							G.water_pressure += water_pressure
							if(G.dir in DIAGONALS)
								G.water_pressure_direction = G.dir - REVERSEDIRS["[water_pressure_direction]"]
							else
								G.water_pressure_direction = water_pressure_direction
							water_pressure = 0
						else
							for(var/i in 1 to round(water_pressure/5))
								var/obj/Particle/Water/A = new(locate(x,y,z))
								A.x_pos = 16+(DIR2PIXEL["[water_pressure_direction]"][1]*16)
								A.y_pos = 16+(DIR2PIXEL["[water_pressure_direction]"][2]*16)
								A.x_spd = DIR2PIXEL["[water_pressure_direction]"][1]==0 ? rand(-20,20)/10 : DIR2PIXEL["[water_pressure_direction]"][1]*(rand(1,30)/10)
								A.y_spd = DIR2PIXEL["[water_pressure_direction]"][2]==0 ? rand(-20,20)/10 : DIR2PIXEL["[water_pressure_direction]"][2]*(rand(1,30)/10)
							var/turf/simulated/T = get_step(src,water_pressure_direction)
							if(istype(T,/turf/simulated))
								T.water_height += water_pressure
								if(!(T in water_changed))
									water_changed += T
							water_pressure = 0
							//Fuck it's leaking
		device
			connector
				icon_state = "filler"
		tank
			icon_state = "water_pump"
			desc = "Due to it's technology, it holds infinite water."
			water_pressure_direction = SOUTH
			density = 1
			water_pressure = 1 //now infinite
			Process_Water()
				if(water_pressure > 0)
					var/obj/water/pipes/G = locate(/obj/water/pipes) in get_step(src,water_pressure_direction)
					if(G)
						G.water_pressure_direction = SOUTH
						G.water_pressure += 20
						//water_pressure -= 20
		meter
			name = "meter"
			icon = 'meter.dmi'
			icon_state = "water"
			anchored = 1
			Click()
				var/t = null
				var/obj/water/pipes/G = locate(/obj/water/pipes) in loc
				if(G)
					t = text("<B>Pressure:</B> [G.water_pressure] water.")
				else
					usr << "\blue <B>You are too far away.</B>"

				usr << t
				return

		var/damaged = 0
		var/water_pressure = 0
		var/water_pressure_direction = 0
		anchored = 1

		New()
			..()
			water_objects += src
		Del()
			water_objects -= src
			..()
		ex_act(severity)
			switch(severity)
				if(1)
					del src
				if(2)
					damaged = prob(75)
				if(3)
					damaged = prob(35)
		proc
			Process_Water() //Called every time we want a process.

/turf/proc/Water_Can_Pass()
	for(var/obj/obstacle in src)
		if(istype(obstacle,/obj/window) || istype(obstacle,/obj/machinery/door))
			if(obstacle.density)
				return 0
	return !density

/turf/simulated
	var/list/listofconnections = list()
	proc/Get_Connections()
		listofconnections = list()
		for(var/DIRE in cardinal)
			CHECK_TICK_WATER()
			var/tmp/turf/simulated/to_add = get_step(src,DIRE)
			if(istype(to_add,/turf/simulated))
				if(to_add.Water_Can_Pass())
					listofconnections += to_add

/turf/simulated/proc/Process_Water()
	if(listofconnections.len == 0)
		Get_Connections()
	for(var/turf/simulated/pe in listofconnections)
		CHECK_TICK_WATER()
		/*if(water_height < pe.water_height)
			var/tmp/calc = pe.water_height/listofturfs.len

			pe.water_height = pe.water_height - calc
			water_height = water_height + calc*/

		if(pe.water_height < water_height)
			var/tmp/calc = water_height/(1+listofturfs.len)
			pe.water_height = pe.water_height + calc
			water_height = water_height - calc
		if(!(pe in water_changed))
			water_changed += pe
		pe.Render_Water_Icon()
	Render_Water_Icon()

var/global/datum/controller/water_system/water_master
datum
	controller
		water_system
			proc
				process()
					water_processed = 0
					for(var/obj/water/W in water_objects)
						CHECK_TICK_WATER()
						W.Process_Water()
					for(var/turf/simulated/T in water_changed)
						CHECK_TICK_WATER()
						T.Process_Water()
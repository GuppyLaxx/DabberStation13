
/obj/item/weapon/pickaxe
	icon = 'pickaxes.dmi'
	icon_state = "pick"
	name = "Iron pickaxe"
	desc = "It's strong enough to take down some rocks."

/obj/item/weapon/pickaxe/afterattack(atom/A, mob/user as mob)
	if (istype(A, /turf/unsimulated/mineral))
		new /turf/unsimulated/asteroid_sand(locate(A.x,A.y,A.z))

/turf/unsimulated/mineral
	name = "rock"
	icon = 'walls.dmi'
	icon_state = "rock"
	opacity = 1
	density = 1
	plane = WALL_PLANE
	iron
		icon_state = "rockiron"

/turf/unsimulated/asteroid_sand
	icon = 'floors.dmi'
	icon_state = "sand1"
	name = "sand"
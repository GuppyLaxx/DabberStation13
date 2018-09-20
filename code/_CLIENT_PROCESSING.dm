var/current_radio_song = null

client/proc/ProcessClient()
	shake *= -0.9
	if(shake < 0.5 && shake > -0.5)
		shake = 0
	pixel_y4 = shake
	pixel_y = round(pixel_y1 + pixel_y2 + pixel_y3 + pixel_y4 + pixel_y5)
	GetDirection()
	if(mob)
		if(istype(mob,/mob/living))
			create_health()
		//Get_Number_Time()

		if(mouse_position)
			if(!(mouse_position.MouseCatcher in screen))
				screen += mouse_position.MouseCatcher
		else
			mouse_position =  new(src)
		var/A_S = 0
		for(var/sound/i in list(amb_sound,amb_sound_ext,amb_sound_area,radio_sound))
			if(i.status != SOUND_UPDATE)
				i.status = SOUND_UPDATE
				i.channel = SOUND_CHANNEL_1+A_S
				i.repeat = 1
				A_S = A_S + 1
		var/turf/T = mob.loc
		if(T)
			var/area/A = T.loc
			if(istype(A,/area))
				if(A.name != "Space" && !A.song && A.ambi == 1 && !istype(T,/turf/space))
					inc_volume()
				else
					if(A.song)
						if(A.song != old_song)
							old_song = A.song
							src << sound(null,channel=SOUND_CHANNEL_1+2)
							amb_sound_area.file = A.song
					dec_volume(A.song != null)
		else
			var/area/A = T.loc
			if(istype(A,/area))
				if(A.song)
					if(A.song != old_song)
						old_song = A.song
						src << sound(null,channel=SOUND_CHANNEL_1+2)
						amb_sound_area.file = A.song
				dec_volume(A.song != null)
		if(music_pitch < music_pitch_new)
			music_pitch += 0.0025
			if(music_pitch > music_pitch_new)
				music_pitch = music_pitch_new
		if(music_pitch > music_pitch_new)
			music_pitch -= 0.0025
			if(music_pitch < music_pitch_new)
				music_pitch = music_pitch_new
		amb_sound.volume = vol
		amb_sound_ext.volume = vol_ext
		amb_sound_ext.frequency = music_pitch
		amb_sound.frequency = music_pitch
		radio_sound.frequency = music_pitch
		if(amb_sound_area.file)
			amb_sound_area.frequency = music_pitch
			amb_sound_area.volume = vol_area*music_vol_mult
			src << amb_sound_area
		src << amb_sound
		src << amb_sound_ext
		if(current_radio_song != old_radio_sound)
			old_radio_sound = current_radio_song
			src << sound(null,channel=SOUND_CHANNEL_1+3)
			radio_sound.file = current_radio_song
		if(radio_sound && istype(mob,/mob/living/carbon/human))
			if(istype(mob:ears,/obj/item/device/radio/headset) && radio_sound.file)
				radio_sound.volume = 100
			else
				radio_sound.volume = 0
		else
			radio_sound.volume = 0
		src << radio_sound


/client/proc/create_health()
	if(health.len == 0)
		var/obj/screen_num/numbG2 = new()
		numbG2.icon = 'screen1.dmi'
		numbG2.screen_loc = "WEST,NORTH"
		numbG2.icon_state = "%"
		health += numbG2
		for(var/i in 1 to 3)
			var/obj/screen_num/numbG = new()
			numbG.icon = 'screen1.dmi'
			numbG.screen_loc = "WEST:[((i-1)*4)],NORTH"
			//screen += numbG
			health += numbG
	if(!(health in screen))
		screen += health
	var/plrText = "[round(max(0,(mob.health/mob.maxhealth)*100))]"
	if(length(plrText) == 2) //Can't be 50, must be something like _50
		plrText = " [plrText]"
	if(length(plrText) == 1)
		plrText = "  [plrText]"
	for(var/i in 1 to 3)
		var/obj/screen_num/numbG = health[i+1]
		if(numbG)
			numbG.icon_state = "healthnum[copytext(plrText,i,i+1)]" //Get every digit

client/proc/dec_volume(var/am_i)

	vol = vol - 5
	if(vol < 0)
		vol = 0
	if(am_i)
		vol_ext = vol_ext - 5
		vol_area = vol_area + 5
		if(vol_area > 100)
			vol_area = 100
		if(vol_ext < 0)
			vol_ext = 0
	else
		vol_area = vol_area - 5
		if(vol_area < 0)
			vol_area = 0
		vol_ext = vol_ext + 5
		if(vol_ext > 100)
			vol_ext = 100

client/proc/inc_volume()
	vol = vol + 5
	vol_area = vol_area - 5
	vol_ext = vol_ext - 5
	if(vol_area < 0)
		vol_area = 0
	if(vol_ext < 0)
		vol_ext = 0
	if(vol > 100)
		vol = 100
area
	var/ambi = 1

client
	control_freak = CONTROL_FREAK_ALL | CONTROL_FREAK_MACROS
	var/pixel_y1 = 0 //normal shit
	var/pixel_y2 = 0 //kart shit
	var/pixel_y3 = 0 //effects
	var/pixel_y4 = 0 //misc shit i think
	var/pixel_y5 = 0 //height system
	var/shake = 0
	var/music_vol_mult = 1

	var/list/health = list() //Health hud stuff
	var/sound/amb_sound = sound('music/interior.ogg')
	var/vol = 0 //Ambient sound vol
	var/sound/amb_sound_ext = sound('music/exterior.ogg')
	var/vol_ext = 0 //Ambient sound vol
	var/sound/amb_sound_area = sound('music/silence.ogg')
	var/old_song = 'music/silence.ogg'
	var/vol_area = 0 //Ambient sound vol
	var/sound/radio_sound = sound('music/silence.ogg')
	var/old_radio_sound = null
	var/music_pitch = 1
	var/music_pitch_new = 1
	verb
		Mute_Music()
			music_vol_mult = !music_vol_mult
			if(music_vol_mult)
				src << "<b>Music enabled."
			else
				src << "<b>Music disabled."
/obj/screen
	appearance_flags = PIXEL_SCALE | TILE_BOUND | NO_CLIENT_COLOR
/obj/screen_num
	plane = 10
	appearance_flags = PIXEL_SCALE | TILE_BOUND | NO_CLIENT_COLOR
/obj/screen_alt
	appearance_flags = PIXEL_SCALE | TILE_BOUND | NO_CLIENT_COLOR

/obj/screen_alt/heightCalc
	plane = 10
	icon = 'screen1.dmi'
	icon_state = "plr"
	screen_loc = "WEST+3, NORTH:0"
	heightG
		icon_state = "height"

/mob
	var/obj/screen_alt/heightCalc/c1 = null
	var/obj/screen_alt/heightCalc/heightG/c2 = null

/obj/hud/proc/instantiate_height_calculator()
	if(!mymob.c1)
		mymob.c1 = new
	if(!mymob.c2)
		mymob.c2 = new

	mymob.client.screen += mymob.c1
	mymob.client.screen += mymob.c2


/var/create_mob_html = null
/obj/admins/proc/create_mob(var/mob/user)
	if (!create_mob_html)
		var/mobjs = null
		mobjs = dd_list2text(typesof(/mob), ";")
		create_mob_html = file2text('create_object.html')
		create_mob_html = dd_replacetext(create_mob_html, "null /* object types */", "\"[mobjs]\"")

	user << browse(cssStyleSheetDab13 + dd_replacetext(create_mob_html, "/* ref src */", "\ref[src]"), "window=create_mob;size=425x475")

/*

deez nuts ha got em hahahah!!!!!!!!!!!!!!

OR 8 MONTHS THIS STUPID PIECE OF SHIT KEK MEME HAS BEEN POSTED 24/7,
ONLY THIS BOARD CAN BE THIS AUTISTIC. I HOPE THE FUCKING MODS PERMABAN ALL OF YOU FAGGOTS,
GO MAKE YOUR OWN STUPID BOARD AND CALL IT 'LE EPIC KEK CHAN'. IT'S PROBABLY THE MOST RETARDED THING IVE EVER SEEN ON THE INTERNET,
I ACTUALLY FEEL SAD FOR YOU PEOPLE THAT ARE SO AUTISTIC THAT YOU POST THIS THINKING THAT YOU'RE FUNNY,
'HAHAHAHA LOOOK AT ME IM LE GOD KEK SO EPIC EPIC FOR THE WIN EPIC MAYMAY' /POL/ IS A FUCKING SHITHOLE IM SICK OF YOU FUCKING FAGGOTS POSTING THIS STUPID ASS MEME 24/7 FUCK OFF U FUCKING FAGGOTS STOP POSTING THAT STUPID GREEN FROG AND THE OTHER SHIT MEMES,
8 MONTHS,
8 FUCKING MONTHS POSTING THE SAME SHIT,
NOT EVERY WEEK BUT EVERY HOUR,
EVERY HOUR THERE'S A KEK THREAD,
ON EVERY BOARD OF 4CHAN,
U FUCKING AUTISTS,
IVE NEVER SUCH SUCH HIGH LEVELS OF AUTISM,
THIS BOARD IS MORE AUTISTIC THAN ALL THE OTHER BOARDS COMBINED,
KEK SUCKS DICK AND SO DOES YOUR WORTHLESS LITTLE BOARD,
I BET YOUR DICKLETS START TINGLING WHEN YOU POST SOMETHING ABOUT KEK,
ISN'T THAT RIGHT FAGGOTS? I BET THAT YOU GET SOME SEXUAL STIMULATION FROM UPLOADING A PICTURE OF A FROG TO YOUR BOARD HUH? I BET THAT YOU MASTURBATE TO THE THOUGHT OF GETTING FUCKED IN THE ASS BY FROG DICK. IT'S PROBABLY TRUE,
YOU'RE ALL FAGGOTS AND WANT KEK DICK. OH LOOK ITS TIME TO REPOST UR STUPID KEK THREAD,
GO AHEAD AND CLICK THE BUTTON WITH YOUR GREASY NECKBEARD FINGERS. I BET YOU WEAR FEDORAS AND TRENCHCOATS TOO. STUPID ASS FAGGOTS,
THIS FORCED MEME IS NOTHING MORE THAN SHIT,
TRYHARD FEDORA NECKBEARDS ATTEMPT AT BEING FUNNY. YOUR "OC" IS PATHETIC,
JUST SOME SHITTY PAINT EDITS OF THE SAME PIC OVER AND OVER. WHAT A BUNCH OF TALENTLESS FAGGOTS,
GO CHEW ON YOUR MOUNTAIN DEW AND YOUR DORITOS. IM DONE ARGUING WITH YOU FAGGOTS,
GO CHECK YOUR STUPID MEMES AND RE-POST YOUR PEPE FACES FOR THE 50TH TIME WHILE YOU MANCHILDREN KEEP REPOSTING THIS UNFUNNY CRAP EVERY SINGLE HOUR

FUCK OFF FUCKING FAGGOTS!!

LOOOOOL!!!!!!!!!!!!!!!!! THAT WAS AN EPIC LE FUNNY JOKE I II II I_ HAHHAHHAHHAA I GET IT L0L0L0L0L0L0L0L0LGET FUCKED KID LOL THIS IS MY JOKE NOW IM SCREENSHOTING IT AND PUTTING ON MY INSTAGRAM MEME PAGE HAHAHAHHAAHAWHH LOSER


HE!1!!!!!!11!!!!!!!!!!!!!!!!!!1111111111!!11 KEK!! KEK!! KEK!! WHATA FUCK MAN xD i just fa
ll of my chair cuz i couldnt and i CANT stop laugh xDXDXDXDXDDDDDXXXXXXDDDDDD OMGOSH DDDDD
XXXXXDDDDD DDDDDD LOOOOOOOLLLLL FUCKIN HOLY SHITTTT I CANT JUST STOP LAUGHING CAUSE HE HE
HE HE HE JUST TO FUNNY MAN!!!1!11! HOOOOOOOOLLLLLLYYYYY SHIT i just fall of chair!!!! simp
ly le epic so ebin dae le epin win xD pwn�d ftw le bacon narwhale xP upboated good sir i t
ip my fedora to you! tips fedora, le any1 athiest? LOL GOOD MEME SORRY I MEAN GREAT MEME G
R88888 FUCKING MEME BRO I WISH I COULD STOP LAUGHING BUT I CANT MAN!!!! NICE MEME IMMA REP
OST TO REDDIT LELELELELE TY FOR LE KARMA XDDDDDDDDDDDDDDDD XD LE UPBOAT XD WAIT TIL LE DER
PINA HEARS ABOUT THIS XDDDDDDDDDDDDDDDDDDDDDD EPIC MEMEING /b/ro BAZINGA BAZINGA BAZINGAAA
AAAAAAAAAAAAAA ZIMBABWE is this a le new epic meme? screen kapped for dat sweet karma xD.
FUS ROH DAH!!!!!1 i used to be a christmas but then i took an arrow 2 da knee : BAZINGA BA
ZINGA ZIMBABWE. top kek, toppest of keks. le nyan cat? hahahaha le mayonaise. fucking epic
 ass meme i love that fucking meme so much man wait let me just gets crack pipe out smoke
some of that good 420 shit : rips a bong AHHHHHHHHH YES!!!!!!!!!!!!!!! that sure hit the s
pot ok now repeat that fucking epic ass M E M E

these LIBERALS????out here building??their own HOUSES?? with 4 WALLS????when they won't even support ONE1??WALL around the
BORDER????????????????????????????the DemoCRAPS????have ALWAYS been the party????of HATE??????????I wonder????if they're TRIGGERED????????because there's
TWO2??GENDERS????????????what can you expect from ??????????OBUNGA??????????and the LEFT??!!????Send this to all your
???????????LIBTARD???????????friends to totally ??TRIGGER??them and spread the WORD????????of CONSERVATISM????????????????????????????????????????????????????????????????????????????????

*/

/obj/item/weapon/grab/attack(mob/M as mob, mob/user as mob)
	if (M == src.affecting)
		s_click(src.hud1)
		return
	if(M == src.assailant && src.state >= 2)
		if( iscarbon(src.affecting) )
			var/mob/living/carbon/attacker = user
			for(var/mob/N in viewers(user, null))
				if(N.client)
					N.show_message(text("\red <B>[user] is attempting to devour [src.affecting]!</B>"), 1)
			if(!do_mob(user, src.affecting)) return
			for(var/mob/N in viewers(user, null))
				if(N.client)
					N.show_message(text("\red <B>[user] devours [src.affecting]!</B>"), 1)
			src.affecting.loc = user
			attacker.stomach_contents.Add(src.affecting)
			del(src)
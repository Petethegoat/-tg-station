#define UPGRADE_COOLDOWN	30
#define UPGRADE_KILL_TIMER	80

#define FIREMAN 1

/obj/item/weapon/grab
	name = "grab"
	flags = NOBLUDGEON | ABSTRACT
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "reinforce"
	flags = NOBLUDGEON
	var/mob/affecting = null
	var/mob/assailant = null
	var/state = GRAB_PASSIVE
	var/grab_flags = 0
	var/allow_upgrade = 1
	var/last_upgrade = 0

	layer = 21
	item_state = "nothing"
	w_class = 5.0


/obj/item/weapon/grab/New(mob/user, mob/victim)
	..()
	loc = user
	assailant = user
	affecting = victim


/obj/item/weapon/grab/process()
	confirm()

	if(assailant.pulling == affecting)
		assailant.stop_pulling()

	assailant.face_atom(affecting)
	affecting.face_atom(assailant)
/*
	if(state <= GRAB_AGGRESSIVE)
		allow_upgrade = 1
		if((assailant.l_hand && assailant.l_hand != src && istype(assailant.l_hand, /obj/item/weapon/grab)))
			var/obj/item/weapon/grab/G = assailant.l_hand
			if(G.affecting != affecting)
				allow_upgrade = 0
		if((assailant.r_hand && assailant.r_hand != src && istype(assailant.r_hand, /obj/item/weapon/grab)))
			var/obj/item/weapon/grab/G = assailant.r_hand
			if(G.affecting != affecting)
				allow_upgrade = 0
		if(state == GRAB_AGGRESSIVE)
			for(var/obj/item/weapon/grab/G in affecting.grabbed_by)
				if(G == src)
					continue
				if(G.state == GRAB_AGGRESSIVE)
					allow_upgrade = 0
		if(allow_upgrade)
			icon_state = "reinforce"
		else
			icon_state = "!reinforce"
	else if(!affecting.buckled)
		affecting.loc = assailant.loc

	if(state >= GRAB_NECK)
		affecting.Stun(5)	//It will hamper your voice, being choked and all.
		if(isliving(affecting))
			var/mob/living/L = affecting
			L.adjustOxyLoss(1)

	if(state >= GRAB_KILL)
		affecting.Weaken(5)	//Should keep you down unless you get help.
		affecting.losebreath = min(affecting.losebreath + 2, 3)
*/

/obj/item/weapon/grab/attack_self()
	if(!affecting)
		return
	if(state == GRAB_UPGRADING)
		return
	if(world.time < last_upgrade + UPGRADE_COOLDOWN)
		return
	if(!assailant.canmove || assailant.lying)
		del(src)
		return

	last_upgrade = world.time
/*
	if(state < GRAB_AGGRESSIVE)
		if(!allow_upgrade)
			return
		assailant.visible_message("<span class='warning'>[assailant] has grabbed [affecting] aggressively (now hands)!</span>")
		state = GRAB_AGGRESSIVE
	else if(state < GRAB_NECK)
		if(isslime(affecting))
			assailant << "<span class='notice'>You squeeze [affecting], but nothing interesting happens.</span>"
			return

		assailant.visible_message("<span class='warning'>[assailant] has reinforced \his grip on [affecting] (now neck)!</span>")
		state = GRAB_NECK
		if(!affecting.buckled)
			affecting.loc = assailant.loc
		affecting.attack_log += "\[[time_stamp()]\] <font color='orange'>Has had their neck grabbed by [assailant.name] ([assailant.ckey])</font>"
		assailant.attack_log += "\[[time_stamp()]\] <font color='red'>Grabbed the neck of [affecting.name] ([affecting.ckey])</font>"
		log_attack("<font color='red'>[assailant.name] ([assailant.ckey]) grabbed the neck of [affecting.name] ([affecting.ckey])</font>")
		icon_state = "choke"
		name = "choke"
	else if(state < GRAB_UPGRADING)
		assailant.visible_message("<span class='danger'>[assailant] starts to tighten \his grip on [affecting]'s neck!</span>")
		icon_state = "choke"
		state = GRAB_UPGRADING
		if(do_after(assailant, UPGRADE_KILL_TIMER))
			if(state == GRAB_KILL)
				return
			if(!affecting)
				del(src)
				return
			if(!assailant.canmove || assailant.lying)
				del(src)
				return
			state = GRAB_KILL
			assailant.visible_message("<span class='danger'>[assailant] has tightened \his grip on [affecting]'s neck!</span>")
			affecting.attack_log += "\[[time_stamp()]\] <font color='orange'>Has been strangled (kill intent) by [assailant.name] ([assailant.ckey])</font>"
			assailant.attack_log += "\[[time_stamp()]\] <font color='red'>Strangled (kill intent) [affecting.name] ([affecting.ckey])</font>"
			log_attack("<font color='red'>[assailant.name] ([assailant.ckey]) Strangled (kill intent) [affecting.name] ([affecting.ckey])</font>")

			assailant.next_move = world.time + 10
			affecting.losebreath += 1
		else
			assailant.visible_message("<span class='warning'>[assailant] was unable to tighten \his grip on [affecting]'s neck!</span>")
			icon_state = "choke"
			state = GRAB_NECK
*/


//This is used to make sure the victim hasn't managed to yackety sax away before using the grab.
/obj/item/weapon/grab/proc/confirm()
	if(!assailant || !affecting)
		del(src)
		return 0

	if(affecting.buckled)
		del(src)
		return 0

	if(affecting)
		if(!isturf(assailant.loc) || (!isturf(affecting.loc) || assailant.loc != affecting.loc && get_dist(assailant, affecting) > 1) )
			del(src)
			return 0

	return 1


/obj/item/weapon/grab/attack(mob/M, mob/user)
	if(!affecting)
		return

	if(M == affecting)
		attack_self()
		return

	if(M == assailant && state >= GRAB_AGGRESSIVE)
		if((ishuman(user) && (FAT in user.mutations) && ismonkey(affecting)) || (isalien(user) && iscarbon(affecting)))
			var/mob/living/carbon/attacker = user
			user.visible_message("<span class='danger'>[user] is attempting to devour [affecting]!</span>")
			if(istype(user, /mob/living/carbon/alien/humanoid/hunter))
				if(!do_mob(user, affecting) || !do_after(user, 30))
					return
			else if(!do_mob(user, affecting) || !do_after(user, 100))
				return
			user.visible_message("<span class='danger'>[user] devours [affecting]!</span>")
			affecting.loc = user
			attacker.stomach_contents.Add(affecting)
			del(src)


//Used by throw code to hand over the mob, instead of throwing the grab. The grab is then deleted by the throw code.
/obj/item/weapon/grab/proc/throw()
	if(state >= GRAB_AGGRESSIVE && !affecting.buckled)
		return affecting

	return null


/obj/item/weapon/grab/MouseDrop(mob/M)
	if(ishuman(M) && assailant == M)
		if(state >= GRAB_AGGRESSIVE)
			if(do_after(M, 40))
				affecting.visible_message("<span class='danger'>[M] has pulled [affecting] into a fireman's carry!</span>", \
										  "<span class='userdanger'>[M] has pulled [affecting] into a fireman's carry!</span>")
				grab_flags |= FIREMAN
				affecting.pixel_y = 10
				affecting.resting = 1
		else
			M << "<span class='notice'>You'll need a better grip to do that.</span>"


/obj/item/weapon/grab/proc/move(turf/T)
	if(grab_flags & FIREMAN)
		affecting.Move(T)


/obj/item/weapon/grab/dropped()
	del(src)

/obj/item/weapon/grab/Del()
	if(grab_flags & FIREMAN)
		affecting.pixel_y = 0
	..()


/mob/proc/grab(mob/user)
	if(anchored)
		return
	if(user == src)
		return
	if(!(status_flags & CANPUSH))
		return
	if(buckled)
		user << "<span class='notice'>You cannot grab [src], \he is buckled in!</span>"
		return

	var/obj/item/weapon/grab/G = new /obj/item/weapon/grab(user, src)
	var/how = "passively"

	if(user.a_intent == "harm")
		how = "aggressively"
		G.state = GRAB_AGGRESSIVE
		G.icon_state = "choke"

	add_logs(user, src, "grabbed", addition = how)

	user.put_in_active_hand(G)
	grabbed_by += G
	LAssailant = user

	playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
	visible_message("<span class='warning'>[user] has grabbed [src] [how]!</span>")
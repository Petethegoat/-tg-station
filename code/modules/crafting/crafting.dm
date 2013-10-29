/datum/craft
	var/name					= "craft"
	var/list/results			= list()	//must be type /obj/item
	var/list/components			= list()	//must be type /obj/item, are used up in construction
	var/list/tools				= list()	//must be type /obj/item, not used up in construction
	var/learn_by_disassembly	= TRUE

/datum/craft/proc/check_component(obj/item/i)
	return TRUE

/datum/craft/proc/check_tool(obj/item/i)
	return TRUE


/datum/craft/cattleprod
	name		= "stunprod"
	results		= list(/obj/item/weapon/melee/baton/cattleprod)
	components	= list(/obj/item/stack/rods, /obj/item/weapon/wirecutters)
	tools		= list(/obj/item/weapon/screwdriver)

/datum/craft/bikehorn
	name		= "bike horn"
	results		= list(/obj/item/weapon/bikehorn)
	components	= list(/obj/item/stack/rods, /obj/item/weapon/corncob)
	tools		= list(/obj/item/weapon/wrench)

/datum/craft/chickenhat
	name		= "chicken suit head"
	results		= list(/obj/item/clothing/head/chicken)
	components	= list(/obj/item/clothing/head/soft, /obj/item/clothing/gloves)
	tools		= list(/obj/item/weapon/hemostat, /obj/item/weapon/cable_coil)

/datum/craft/chickenhat/check_component(obj/item/i)
	if(istype(i, /obj/item/clothing/head/soft))
		if(i.item_color != "yellow")
			return "The cap must be yellow."
	if(istype(i, /obj/item/clothing/gloves))
		if(i.item_color != "red")
			return "The gloves must be red."
	return null


/mob/verb/lamo()
	set src = usr
	set name = "Crafting"

	get_crafts_list(usr)


/proc/get_crafts_list(mob/user)
	var/list/all_crafts = init_subtypes(/datum/craft)
	var/list/possible_crafts = list()
	var/list/user_contents = user.GetAllContents()

	for(var/datum/craft/c in all_crafts)
		var/can_craft = TRUE

		for(var/tool in c.tools)
			var/possible = FALSE
			for(var/o in user_contents)
				if(istype(o, tool))
					possible = TRUE
					break
			if(!possible)
				can_craft = FALSE
				break

		if(can_craft)
			for(var/comp in c.components)
				var/possible = FALSE
				for(var/o in user_contents)
					if(istype(o, comp))
						possible = TRUE
						break
				if(!possible)
					can_craft = FALSE
					break

		if(can_craft)
			possible_crafts[c.name] = c

	if(possible_crafts.len)
		var/pick = input("Please, pick a craft!", "Crafting") in possible_crafts
		var/datum/craft/c = possible_crafts[pick]

		//yikes
		for(var/comp in c.components)
			var/succeed = FALSE
			var/list/which_component = list()
			var/count = 1
			for(var/obj/item/i in user_contents)
				if(istype(i, comp))
					var/check = c.check_component(i)
					if(check)
						user << check
					else
						succeed = TRUE
						which_component["[count]. [i.name][i.loc == user ? "" : " (in [i.loc.name])"]"] = i
						count++
			if(succeed)
				var/use = input("Which component would you like to use?", "Crafting") in which_component
				var/obj/item/i = which_component[use]
				i.handle_removal()
				del(i)
			else
				return

		var/result_text = ""
		world << c.results.len
		for(var/obj/item/r in c.results)
			new r(user.loc)
			result_text += " \a [r.name],"
		user << "<span class='notice'>You craft [result_text]</span>"


/obj/item/proc/handle_removal()
	if(ismob(loc))
		var/mob/m = loc
		m.drop_from_inventory(src)
	else if(istype(loc, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/s = loc
		s.remove_from_storage(src)
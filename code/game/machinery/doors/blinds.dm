/obj/machinery/door/poddoor/shutters/blinds
	name = "blinds"
	desc = "Motorised plastic window blinds. They look pretty fragile."
	icon = 'icons/obj/doors/windowblinds.dmi'
	var/health = 15

/obj/machinery/door/poddoor/shutters/blinds/preopen
	icon_state = "open"
	density = 0
	opacity = 0


/obj/machinery/door/poddoor/shutters/blinds/wooden
	desc = "Wood effect motorised window blinds. Now you can pretend to be Bogart!"
	icon = 'icons/obj/doors/woodenblinds.dmi'
	health = 25

/obj/machinery/door/poddoor/shutters/blinds/wooden/preopen
	icon_state = "open"
	density = 0
	opacity = 0


/obj/machinery/door/poddoor/shutters/blinds/proc/check_health()
	if(health <= 0)
		del(src)


/obj/machinery/door/poddoor/shutters/blinds/attack_hand(mob/user)
	health -= 5
	visible_message("<span class='danger'>[user] tears at [src]!</span>")
	check_health()

/obj/machinery/door/poddoor/shutters/blinds/attackby(obj/item/I, mob/user)
	if(I.force > 0)
		health -= I.force
		visible_message("<span class='danger'>[user] bashes [src] with [I]!</span>")
		check_health()
	else
		user << "<span class='notice'>[I] can't damage [src]!</span>"
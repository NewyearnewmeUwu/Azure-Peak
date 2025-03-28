
///////////////////////////////////////////////Condiments
//Notes by Darem: The condiments food-subtype is for stuff you don't actually eat but you use to modify existing food. They all
//	leave empty containers when used up and can be filled/re-filled with other items. Formatting for first section is identical
//	to mixed-drinks code. If you want an object that starts pre-loaded, you need to make it in addition to the other code.

//Food items that aren't eaten normally and leave an empty container behind.
/obj/item/reagent_containers/food/condiment
	name = "condiment bottle"
	desc = ""
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "emptycondiment"
	reagent_flags = OPENCONTAINER
	obj_flags = UNIQUE_RENAME
	possible_transfer_amounts = list(1, 5, 10, 15, 20, 25, 30, 50)
	volume = 50
	//Possible_states has the reagent type as key and a list of, in order, the icon_state, the name and the desc as values. Used in the on_reagent_change(changetype) to change names, descs and sprites.
	var/list/possible_states = list(
	 /datum/reagent/consumable/enzyme = list("icon_state" = "enzyme", "item_state" = "", "icon_empty" = "", "name" = "universal enzyme bottle", "desc" = "Used in cooking various dishes."),
	 /datum/reagent/consumable/flour = list("icon_state" = "flour", "item_state" = "flour", "icon_empty" = "", "name" = "flour sack", "desc" = "A big bag of flour. Good for baking!"),
	 /datum/reagent/consumable/mayonnaise = list("icon_state" = "mayonnaise", "item_state" = "", "icon_empty" = "", "name" = "mayonnaise jar", "desc" = "An oily condiment made from egg yolks."),
	 /datum/reagent/consumable/milk = list("icon_state" = "milk", "carton", "item_state" = "", "icon_empty" = "", "name" = "space milk", "desc" = "It's milk. White and nutritious goodness!"),
	 /datum/reagent/consumable/blackpepper = list("icon_state" = "peppermillsmall", "item_state" = "", "icon_empty" = "emptyshaker", "name" = "pepper mill", "desc" = "Often used to flavor food or make people sneeze."),
	 /datum/reagent/consumable/rice = list("icon_state" = "rice", "item_state" = "flour", "icon_empty" = "", "name" = "rice sack", "desc" = "A big bag of rice. Good for cooking!"),
	 /datum/reagent/consumable/sodiumchloride = list("icon_state" = "saltshakersmall", "item_state" = "", "icon_empty" = "emptyshaker", "name" = "salt shaker", "desc" = "Salt. From dead crew, presumably."),
	 /datum/reagent/consumable/soymilk = list("icon_state" = "soymilk", "item_state" = "carton", "icon_empty" = "", "name" = "soy milk", "desc" = "It's soy milk. White and nutritious goodness!"),
	 /datum/reagent/consumable/soysauce = list("icon_state" = "soysauce", "item_state" = "", "icon_empty" = "", "name" = "soy sauce bottle", "desc" = "A salty soy-based flavoring."),
	 /datum/reagent/consumable/sugar = list("icon_state" = "rice", "item_state" = "flour", "icon_empty" = "", "name" = "sugar sack", "desc" = "Tasty spacey sugar!"),
	 /datum/reagent/consumable/ketchup = list("icon_state" = "ketchup", "item_state" = "", "icon_empty" = "", "name" = "ketchup bottle", "desc" = "You feel more American already."),
	 /datum/reagent/consumable/capsaicin = list("icon_state" = "hotsauce", "item_state" = "", "icon_empty" = "", "name" = "hotsauce bottle", "desc" = "You can almost TASTE the stomach ulcers!"),
	 /datum/reagent/consumable/frostoil = list("icon_state" = "coldsauce", "item_state" = "", "icon_empty" = "", "name" = "coldsauce bottle", "desc" = "Leaves the tongue numb from its passage."),
	 /datum/reagent/consumable/cornoil = list("icon_state" = "oliveoil", "item_state" = "", "icon_empty" = "", "name" = "corn oil bottle", "desc" = "A delicious oil used in cooking. Made from corn."),
	 /datum/reagent/consumable/bbqsauce = list("icon_state" = "bbqsauce", "item_state" = "", "icon_empty" = "", "name" = "bbq sauce bottle", "desc" = "Hand wipes not included."),
	 )
	var/originalname = "condiment" //Can't use initial(name) for this. This stores the name set by condimasters.
	var/icon_empty = ""
	fill_icon_thresholds = list(0, 10, 25, 50, 75, 100)

/obj/item/reagent_containers/food/condiment/Initialize()
	. = ..()
	possible_states = typelist("possible_states", possible_states)

	update_icon()

/obj/item/reagent_containers/food/condiment/update_icon()
	cut_overlays()

	if(reagents.reagent_list.len > 0 && possible_states.len)
		var/main_reagent = reagents.get_master_reagent_id()
		if(main_reagent in possible_states)
			icon_state = possible_states[main_reagent]["icon_state"]
			item_state = possible_states[main_reagent]["item_state"]
			icon_empty = possible_states[main_reagent]["icon_empty"]
			name = possible_states[main_reagent]["name"]
			desc = possible_states[main_reagent]["desc"]
			return ..(TRUE) // Don't fill normally
		else
			name = "condiment bottle"
			desc = ""
			icon_state = "emptycondiment"

	else if(icon_empty)
		icon_state = icon_empty

	. = ..()

/obj/item/reagent_containers/food/condiment/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] is trying to eat the entire [src]! It looks like [user.p_they()] forgot how food works!"))
	return OXYLOSS

/obj/item/reagent_containers/food/condiment/attack(mob/M, mob/user, def_zone)

	if(!reagents || !reagents.total_volume)
		to_chat(user, span_warning("None of [src] left, oh no!"))
		return 0

	if(!canconsume(M, user))
		return 0

	if(M == user)
		user.visible_message(span_notice("[user] swallows some of the contents of \the [src]."), \
			span_notice("I swallow some of the contents of \the [src]."))
	else
		M.visible_message(span_warning("[user] attempts to feed [M] from [src]."), \
			span_warning("[user] attempts to feed you from [src]."))
		if(!do_mob(user, M))
			return
		if(!reagents || !reagents.total_volume)
			return // The condiment might be empty after the delay.
		M.visible_message(span_warning("[user] fed [M] from [src]."), \
			span_warning("[user] fed you from [src]."))
		log_combat(user, M, "fed", reagents.log_list())

	var/fraction = min(10/reagents.total_volume, 1)
	reagents.reaction(M, INGEST, fraction)
	reagents.trans_to(M, 10, transfered_by = user)
	playsound(M.loc,'sound/blank.ogg', rand(10,50), TRUE)
	return 1

/obj/item/reagent_containers/food/condiment/afterattack(obj/target, mob/user , proximity)
	. = ..()
	if(!proximity)
		return
	if(target.is_drainable() || istype(target, /obj/item/reagent_containers/food/snacks))
		if(!reagents.total_volume)
			to_chat(user, "<span class='warning'>[src] is empty!</span>")
			return
		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			to_chat(user, "<span class='warning'>you can't add anymore to [target]!</span>")
			return
		var/trans = src.reagents.trans_to(target, amount_per_transfer_from_this, transfered_by = user)
		to_chat(user, "<span class='notice'>I transfer [trans] units of the condiment to [target].</span>")

/obj/item/reagent_containers/food/condiment/on_reagent_change(changetype)
	update_icon()

/obj/item/reagent_containers/food/condiment/enzyme
	name = "universal enzyme"
	desc = ""
	icon_state = "enzyme"
	list_reagents = list(/datum/reagent/consumable/enzyme = 50)

/obj/item/reagent_containers/food/condiment/sugar
	name = "sugar sack"
	desc = ""
	icon_state = "rice"
	item_state = "flour"
	list_reagents = list(/datum/reagent/consumable/sugar = 50)

/obj/item/reagent_containers/food/condiment/saltshaker		//Separate from above since it's a small shaker rather then
	name = "salt shaker"											//	a large one.
	desc = ""
	icon_state = "saltshakersmall"
	icon_empty = "emptyshaker"
	possible_transfer_amounts = list(1,20) //for clown turning the lid off
	amount_per_transfer_from_this = 1
	volume = 20
	list_reagents = list(/datum/reagent/consumable/sodiumchloride = 20)
/*

/obj/item/reagent_containers/food/condiment/saltshaker/afterattack(obj/target, mob/living/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(isturf(target))
		if(!reagents.has_reagent(/datum/reagent/consumable/sodiumchloride, 2))
			to_chat(user, span_warning("I don't have enough salt to make a pile!"))
			return
		user.visible_message(span_notice("[user] shakes some salt onto [target]."), span_notice("I shake some salt onto [target]."))
		reagents.remove_reagent(/datum/reagent/consumable/sodiumchloride, 2)
		new/obj/effect/decal/cleanable/food/salt(target)
		return*/

/obj/item/reagent_containers/food/condiment/peppermill
	name = "pepper mill"
	desc = ""
	icon_state = "peppermillsmall"
	icon_empty = "emptyshaker"
	possible_transfer_amounts = list(1,20) //for clown turning the lid off
	amount_per_transfer_from_this = 1
	volume = 20
	list_reagents = list(/datum/reagent/consumable/blackpepper = 20)

/obj/item/reagent_containers/food/condiment/milk
	name = "space milk"
	desc = ""
	icon_state = "milk"
	item_state = "carton"
	list_reagents = list(/datum/reagent/consumable/milk = 50)

/obj/item/reagent_containers/food/condiment/flour
	name = "flour sack"
	desc = ""
	icon_state = "flour"
	item_state = "flour"
	list_reagents = list(/datum/reagent/consumable/flour = 30)

/obj/item/reagent_containers/food/condiment/soymilk
	name = "soy milk"
	desc = ""
	icon_state = "soymilk"
	item_state = "carton"
	list_reagents = list(/datum/reagent/consumable/soymilk = 50)

/obj/item/reagent_containers/food/condiment/rice
	name = "rice sack"
	desc = ""
	icon_state = "rice"
	item_state = "flour"
	list_reagents = list(/datum/reagent/consumable/rice = 30)

/obj/item/reagent_containers/food/condiment/soysauce
	name = "soy sauce"
	desc = ""
	icon_state = "soysauce"
	list_reagents = list(/datum/reagent/consumable/soysauce = 50)

/obj/item/reagent_containers/food/condiment/mayonnaise
	name = "mayonnaise"
	desc = ""
	icon_state = "mayonnaise"
	list_reagents = list(/datum/reagent/consumable/mayonnaise = 50)



//Food packs. To easily apply deadly toxi... delicious sauces to your food!

/obj/item/reagent_containers/food/condiment/pack
	name = "condiment pack"
	desc = ""
	icon_state = "condi_empty"
	volume = 10
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list()
	possible_states = list(
		/datum/reagent/consumable/ketchup = list("condi_ketchup", "Ketchup", "You feel more American already."),
		/datum/reagent/consumable/capsaicin = list("condi_hotsauce", "Hotsauce", "You can almost TASTE the stomach ulcers now!"),
		/datum/reagent/consumable/soysauce = list("condi_soysauce", "Soy Sauce", "A salty soy-based flavoring"),
		/datum/reagent/consumable/frostoil = list("condi_frostoil", "Coldsauce", "Leaves the tongue numb in it's passage"),
		/datum/reagent/consumable/sodiumchloride = list("condi_salt", "Salt Shaker", "Salt. From space oceans, presumably"),
		/datum/reagent/consumable/blackpepper = list("condi_pepper", "Pepper Mill", "Often used to flavor food or make people sneeze"),
		/datum/reagent/consumable/cornoil = list("condi_cornoil", "Corn Oil", "A delicious oil used in cooking. Made from corn"),
		/datum/reagent/consumable/sugar = list("condi_sugar", "Sugar", "Tasty spacey sugar!"),
		/datum/reagent/consumable/astrotame = list("condi_astrotame", "Astrotame", "The sweetness of a thousand sugars but none of the calories."),
		/datum/reagent/consumable/bbqsauce = list("condi_bbq", "BBQ sauce", "Hand wipes not included."),
		)

/obj/item/reagent_containers/food/condiment/pack/update_icon()
	return

/obj/item/reagent_containers/food/condiment/pack/attack(mob/M, mob/user, def_zone) //Can't feed these to people directly.
	return

/obj/item/reagent_containers/food/condiment/pack/afterattack(obj/target, mob/user , proximity)
	. = ..()
	if(!proximity)
		return

	//You can tear the bag open above food to put the condiments on it, obviously.
	if(istype(target, /obj/item/reagent_containers/food/snacks))
		if(!reagents.total_volume)
			to_chat(user, span_warning("I tear open [src], but there's nothing in it."))
			qdel(src)
			return
		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			to_chat(user, span_warning("I tear open [src], but [target] is stacked so high that it just drips off!") )
			qdel(src)
			return
		else
			to_chat(user, span_notice("I tear open [src] above [target] and the condiments drip onto it."))
			src.reagents.trans_to(target, amount_per_transfer_from_this, transfered_by = user)
			qdel(src)

/obj/item/reagent_containers/food/condiment/pack/on_reagent_change(changetype)
	if(reagents.reagent_list.len > 0)
		var/main_reagent = reagents.get_master_reagent_id()
		if(main_reagent in possible_states)
			var/list/temp_list = possible_states[main_reagent]
			icon_state = temp_list[1]
			desc = temp_list[3]
		else
			icon_state = "condi_mixed"
			desc = ""
	else
		icon_state = "condi_empty"
		desc = ""

//Ketchup
/obj/item/reagent_containers/food/condiment/pack/ketchup
	name = "ketchup pack"
	originalname = "ketchup"
	list_reagents = list(/datum/reagent/consumable/ketchup = 10)

//Hot sauce
/obj/item/reagent_containers/food/condiment/pack/hotsauce
	name = "hotsauce pack"
	originalname = "hotsauce"
	list_reagents = list(/datum/reagent/consumable/capsaicin = 10)

/obj/item/reagent_containers/food/condiment/pack/astrotame
	name = "astrotame pack"
	originalname = "astrotame"
	list_reagents = list(/datum/reagent/consumable/astrotame = 5)

/obj/item/reagent_containers/food/condiment/pack/bbqsauce
	name = "bbq sauce pack"
	originalname = "bbq sauce"
	list_reagents = list(/datum/reagent/consumable/bbqsauce = 10)

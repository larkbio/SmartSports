@diet_loaded = () ->
  console.log("diet loaded2")

  $("div.app2Menu a.menulink").removeClass("selected")
  $("#diet-link").css
    background: "rgba(87, 200, 138, 0.3)"

  popup_messages = JSON.parse($("#popup-messages").val())
  amount_values = $("#amount_values").val().split(",")

  document.body.style.cursor = 'wait'
  loadFoodTypes( () ->
    console.log("foodtypes loaded")
    document.body.style.cursor = 'auto'
    initDiet()
    loadDiets()
  )

  $("#smoke-create-form button").click ->
    if(!smokeSelected)
      val = $(".diet_smoke_type").val()
      if !val
        val = "empty item"
      popup_error(popup_messages.failed_to_add_data)
      smokeSelected = null
      return false
    smokeSelected = null
    return true

  $("#drink-create-form button").click ->
    if(!drinkSelected)
      val = $("#dinkname").val()
      if !val
        val = "empty item"
      popup_error(popup_messages.failed_to_add_data)
      drinkSelected = null
      return false
    drinkSelected = null
    return true

  $("#recentResourcesTable").on("click", "td.dietItem", (e) ->
    data = JSON.parse(e.currentTarget.querySelector("input").value)
    diet = data['diet']
    if diet.diet_type=='Food'
      load_diet_food("#diet_forms .diet_food", data)
    else if diet.diet_type=='Drink'
      load_diet_drink("#diet_forms .diet_drink", data)
    else if diet.diet_type=='Smoke'
      load_diet_smoke("#diet_forms .diet_smoke", data)
    else if diet.diet_type=='Calory'
      load_diet_quick_calories("#diet_forms .diet_quick_calories", data)
  )

  $("form.resource-create-form.diet-form").on("ajax:success", (e, data, status, xhr) ->
    console.log "success diet-form"
    console.log data
    resetDiet()
    loadDietHistory()
    popup_success(data['diet_name']+popup_messages.saved_successfully)
  ).on("ajax:error", (e, xhr, status, error) ->
    $('#diet_type_id').val(null)
    $('#diet_drink_type_id').val(null)
    $('.diet_smoke_type').val(null)
    console.log xhr.responseText
    color = $("#addFoodButton").css("background")
#    popup_error(popup_messages.failed_to_add_data)
    resp = JSON.parse(xhr.responseText)
    popup_error(resp.msg)
  )

  $("#recentResourcesTable").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "update/delete success "+form_id
    loadDietHistory()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    popup_error(popup_messages.failed_to_delete_data)
  )

  $('.hisTitle').click ->
    loadDietHistory()

  $(".favTitle").click ->
    load_favs()
    $(".hisTitle").removeClass("selected")
    $(".favTitle").addClass("selected")

  $(".diet_food-create-form button").click ->
    validate_diet_food("#diet_forms .diet_food_elem")

@resetDiet = () ->
  amount_values = $("#amount_values").val().split(",")
  $("div.diet > input.dataFormField").val("")
  $(".diet_food_scale").slider({ value: 1 })
  fval = $(".diet_food_scale").slider("value")
  $(".diet_food_unit").html(amount_values[fval])
  $(".diet_drink_scale").slider({ value: 2 })
  dval = $(".diet_drink_scale").slider("value")
  $(".diet_drink_unit").html(dval+" dl")

  $(".diet_food_datepicker").val(moment().format(moment_fmt))
  $(".diet_calories_datepicker").val(moment().format(moment_fmt))
  $(".diet_drink_datepicker").val(moment().format(moment_fmt))
  $(".diet_smoking_datepicker").val(moment().format(moment_fmt))

  $("#diet_type_id").val(null)
  $("#diet_drink_type_id").val(null)
  $(".diet_smoke_type").val(null)

@initDiet = () ->
  self = this
  amount_values = $("#amount_values").val().split(",")
  console.log "initdiet called"
  $(".diet_food_datepicker").datetimepicker(timepicker_defaults)
  $(".diet_food_amount").val(1)
  $(".diet_drink_datepicker").datetimepicker(timepicker_defaults)
  $(".diet_drink_amount").val(2)
  $(".diet_calories_datepicker").datetimepicker(timepicker_defaults)
  $(".diet_smoking_datepicker").datetimepicker(timepicker_defaults)

  $(".diet_food_scale").slider({
    min: 0,
    max: 2,
    step: 1,
    value: 1
  }).slider({
    slide: (event, ui) ->
      event.target.parentElement.parentElement.querySelector("div.diet_food_unit").innerHTML = " "+amount_values[ui.value]
    change: (event, ui) ->
      event.target.parentElement.parentElement.querySelector("input.diet_food_amount").value = ui.value
  })

  $(".diet_drink_scale").slider({
    min: 0.25,
    max: 5,
    step: 0.25,
    value: 2
  }).slider({
    slide: (event, ui) ->
      event.target.parentElement.parentElement.querySelector("div.diet_drink_unit").innerHTML = " "+ui.value+"dl"
    change: (event, ui) ->
      event.target.parentElement.parentElement.querySelector("input.diet_drink_amount").value = ui.value
  })

  foodSelected = null
  $(".diet_food_name").autocomplete({
    minLength: 0,
    source: (request, response) ->
      matcher = new RegExp($.ui.autocomplete.escapeRegex(remove_accents(request.term), ""), "i")
      result = []
      cnt = 0
      user_lang = $("#user-lang")[0].value
      if user_lang
        foodkey = 'sd_foods_'+user_lang
      else
        foodkey = 'sd_foods_hu'

      for element in getStored(foodkey)
        if matcher.test(remove_accents(element.label))
          result.push(element)
          cnt += 1
      response(result)
    select: (event, ui) ->
      $(".diet_type_id").val(ui.item.id)
    create: (event, ui) ->
      $(".diet_food_name").removeAttr("disabled")
    change: (event, ui) ->
      foodSelected = ui['item']
  }).focus ->
    $(this).autocomplete("search")

  drinkSelected = null
  $(".diet_drink_name").autocomplete({
    minLength: 0,
    source: (request, response) ->
      matcher = new RegExp($.ui.autocomplete.escapeRegex(remove_accents(request.term), ""), "i")
      result = []
      cnt = 0
      user_lang = $("#user-lang")[0].value
      if user_lang
        drinkkey = 'sd_drinks_'+user_lang
      else
        drinkkey = 'sd_drinks_hu'

      for element in getStored(drinkkey)
        if matcher.test(remove_accents(element.label))
          result.push(element)
          cnt += 1
      response(result)
    select: (event, ui) ->
      $(".diet_drink_type_id").val(ui.item.id)
    create: (event, ui) ->
      $(".diet_drink_name").removeAttr("disabled")
    change: (event, ui) ->
      drinkSelected = ui['item']
  }).focus ->
    $(this).autocomplete("search")

  smokeList_hu = [
    {label: "1 Cigaretta"             ,value: "1 Cigaretta"            },
    {label: "1 Szivar"                ,value: "1 Szivar"               },
    {label: "1 Szivarka"              ,value: "1 Szivarka"             },
    {label: "1 Pipa"                  ,value: "1 Pipa"                 },
    {label: "1 Elektromos cigaretta"  ,value: "1 Elektromos cigaretta" },
    {label: "1 Nikotinos orrspray"    ,value: "1 Nikotinos orrspray"   },
    {label: "1 Nikotinos rágó"        ,value: "1 Nikotinos rágó"       },
    {label: "1 Nikotinos tapasz"      ,value: "1 Nikotinos tapasz"     }]

  smokeList_en = [
    {label: "1 Cigarette"             ,value: "1 Cigaretta"            },
    {label: "1 Cigar"                 ,value: "1 Szivar"               },
    {label: "1 Cigarillo"             ,value: "1 Szivarka"             },
    {label: "1 Pipe"                  ,value: "1 Pipa"                 },
    {label: "1 Electric cigarette"    ,value: "1 Elektromos cigaretta" },
    {label: "1 Nicotine nose-spray"   ,value: "1 Nikotinos orrspray"   },
    {label: "1 Nicotine chewing gum"  ,value: "1 Nikotinos rágó"       },
    {label: "1 Nicotine patch"        ,value: "1 Nikotinos tapasz"     }]

  user_lang = $("#user-lang")[0].value
  if user_lang
    if user_lang == 'en'
      smokeList = smokeList_en
    else if user_lang == 'hu'
      smokeList = smokeList_hu
  else
    smokeList = smokeList_hu
  smokeSelected = null
  $(".diet_smoke_type").autocomplete({
    minLength: 0,
    source: smokeList,
    change: (event, ui) ->
      console.log "change "+ui['item']
      smokeSelected = ui['item']
  }).focus ->
    $(this).autocomplete("search")

@loadDietHistory = () ->
  loadDiets()
  $(".hisTitle").addClass("selected")
  $(".favTitle").removeClass("selected")

@loadDiets = () ->
  self = this
  current_user = $("#current-user-id")[0].value
  lang = $("#data-lang-diet")[0].value
  console.log "calling load recent diets"
  url = '/users/' + current_user + '/diets.js?source='+window.default_source+'&order=desc&limit=10&lang='+lang
  $.ajax urlPrefix()+url,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent diets AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      $(".deleteDiet").removeClass("hidden")
      console.log "load recent diets  Successful AJAX call"
      console.log textStatus

@load_favs = () ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load recent diets"
  url = '/users/' + current_user + '/diets.js?source='+window.default_source+'&favourites=true&order=desc&limit=10'
  $.ajax urlPrefix()+url,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent diets AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      $(".deleteDiet").addClass("hidden")
      console.log "load recent diets  Successful AJAX call"
      console.log textStatus


@loadFoodTypes = (cb) ->
  self = this
  current_user = $("#current-user-id")[0].value
  popup_messages = JSON.parse($("#popup-messages").val())
  user_lang = $("#user-lang")[0].value
  db_version = $("#db-version")[0].value

  if user_lang
    foodkey = 'sd_foods_'+user_lang
  else
    foodkey = 'sd_foods_hu'

  if !getStored(foodkey) || testDbVer(db_version)
    console.log "loading food types"
    ret = $.ajax urlPrefix()+'/food_types.json',
      type: 'GET',
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "load recent food_types AJAX Error: #{textStatus}"
      success: (data, textStatus, jqXHR) ->
        console.log "load food_types  Successful AJAX call"

        setStored('sd_foods_hu', data.filter( (d) ->
          d['category'] == "Food" && d['lang'] == 'hu'
        ).map( window.food_map_fn ))

        setStored('sd_drinks_hu', data.filter( (d) ->
          d['category'] == "Drink" && d['lang'] == 'hu'
        ).map( window.food_map_fn ))

        setStored('sd_foods_en', data.filter( (d) ->
          d['category'] == "Food" && d['lang'] == 'en'
        ).map( window.food_map_fn ))

        setStored('sd_drinks_en', data.filter( (d) ->
          d['category'] == "Drink" && d['lang'] == 'en'
        ).map( window.food_map_fn ))

        setStored('db_version', db_version)

        cb()
  else
    console.log "food types already loaded"
    ret = new Promise( (resolve, reject) ->
      console.log("food promise fn called")
      cb()
      resolve("food cbs called")
    )
  return ret

@validate_diet_food = (sel) ->
  val = $(sel+" .diet_food_name").val()
  if !val
    val = "empty item"
    popup_error(popup_messages.failed_to_add_data)
    return false
  return true

@load_diet_food =  (sel, data) ->
  amount_values = $("#amount_values").val().split(",")
  diet = data['diet']
  console.log "load diet food to:"+sel+" diet: "+diet.name
  console.log diet
  $(sel+" input[name='diet[name]']").val(diet.name)
  $(sel+" input[name='diet[food_type_id]']").val(diet.food_type_id)
  $(sel+" .diet_food_unit").html(amount_values[diet.amount])
  $(sel+" .diet_food_scale").slider({value: diet.amount})
  $(sel+" input[name='diet[date]']").val(moment().format(moment_fmt))

@load_diet_drink =  (sel, data) ->
  diet = data['diet']
  $(sel+" input[name='diet[name]']").val(diet.name)
  $(sel+" input[name='diet[food_type_id]']").val(diet.food_type_id)
  $(sel+" .diet_drink_unit").html(diet.amount+" dl")
  $(sel+" .diet_drink_scale").slider({value: diet.amount})
  $(sel+" input[name='diet[date]']").val(moment().format(moment_fmt))

@load_diet_smoke = (sel, data) ->
  diet = data['diet']
  $(sel+" input[name='diet[name]']").val(diet.name)
  $(sel+" input[name='diet[date]']").val(moment().format(moment_fmt))

@load_diet_quick_calories = (sel, data) ->
  diet = data['diet']
  $(sel+" input[name='diet[calories]']").val(diet.calories)
  $(sel+" input[name='diet[carbs]']").val(diet.carbs)
  $(sel+" input[name='diet[date]']").val(moment().format(moment_fmt))

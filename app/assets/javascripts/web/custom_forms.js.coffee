# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@custom_loaded = () ->
  console.log "custom_loaded called, start initializing"

  @popup_messages = JSON.parse($("#popup-messages").val())
  customPreload()

  initCustomForms()
  registerCustomFormHandlers()

@registerCustomFormHandlers = () ->
  $("form#custom-create-form").on("ajax:success", (e, data, status, xhr) ->
    console.log data
    if data['ok'] == true
      location.href = "customforms"
    else
      $("#input-form_name").addClass("formFail")
      $("i.formFailSign").removeClass("hidden")
  ).on("ajax:error", (e, xhr, status, error) ->
    $("#input-form_name").addClass("formFail")
    $("i.formFailSign").removeClass("hidden")
  )

  $(".delete-form-form").on("ajax:success", (e, data, status, xhr) ->
    console.log e.target
    location.href = 'customforms'
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log "delete failed"
    console.log e.target
  )

  $(document).unbind("click.addCFB")
  $(document).on("click.addCFB", ".addCustomFormElementButton", (evt) ->
    evt.preventDefault()
    addForm = evt.target.closest("form")
    console.log "add cfe clicked, #"+addForm.id
    params = decodeURIComponent($("#"+addForm.id).serialize())
    formid = $("#openModalAddCustomFormElement input[name=customFormId]").val()
    url = "/custom_forms/"+formid+"/custom_form_elements"
    reqParams = generateDefaults(params)
    console.log "push "+url
    console.log "data="
    console.log reqParams
    $.ajax({
      method: "POST",
      data: reqParams,
      url: url
    })
    .done( (data, textStatus, jqXHR) ->
      console.log "create form element Successful AJAX call"
      location.href = "customforms"
    ).fail((data, textStatus, jqXHR) ->
      console.log "create form element fail AJAX call: "
      console.log data
      console.log jqXHR
    )
  )

@customPreload = () ->
  document.body.style.cursor = 'wait'
  p1 = loadFoodTypes( () ->
    console.log("foodtypes loaded")
    initDiet()
  )
  p2 = loadActivityTypes( () ->
    console.log("activitytypes loaded")
    initActivity()
  )
  p3 = loadMedicationTypes( () ->
    console.log("medication types loaded")
    initMedication()
  )
  p4 = loadIllnessTypes( () ->
    console.log("illness types loaded")
    initLifestyle()
  )
  p5 = loadIllnessTypes( () ->
    console.log("illness types loaded")
    initLabresult()
  )
  Promise.all([p1, p2, p3, p4, p5]).then( (results) ->
    console.log "All promises fullfilled"
    initMeasurement()
    if typeof window.load_custom_form_element_defaults =='function'
      load_custom_form_element_defaults()
    document.body.style.cursor = 'auto'
  )

@paramsToHash = (formParams) ->
  params = formParams.replace(/authenticity_token.*?&/, '')
  params = params.replace(/utf8.*?&/, '')
  jparams = JSON.parse('{"' + decodeURI(params).replace(/"/g, '\\"').replace(/\+/g, ' ').replace(/&/g, '","').replace(/\=/g,'":"') + '"}')
  return(jparams)

@generateDefaults = (formParams) ->
  jparams = paramsToHash(formParams)

  key = jparams['elementName'].split('_')[0]
  values = {}
  Object.keys(jparams).forEach( (k) ->
    if k.startsWith(key+"[")
      arr = k.split(/[\[\]]/)
      values[arr[1]] = jparams[k]
  )

  propKey = "custom_form_element[property_code]"
  defaultsKey = "custom_form_element[defaults]"
  resourceKey = key
  resource = {}
  resource[key] = values

  ret = {}
  ret[propKey] =  jparams['elementName']
  ret[defaultsKey] = JSON.stringify(resource)
  return ret

@initFormElements = (targetSelector, formButton) ->
  @formList = ["activity_exercise",
               "activity_regular",
               "diet_drink",
               "diet_food",
               "diet_quick_calories",
               "diet_smoke",
               "measurement_blood_glucose",
               "measurement_blood_pressure",
               "measurement_waist",
               "measurement_weight",
               "labresult_egfrepi",
               "labresult_hba1c",
               "labresult_ketone",
               "labresult_ldlchol",
               "medication_drugs",
               "medication_insulin",
               "notification_visit",
               "lifestyle_illness",
               "lifestyle_pain",
               "lifestyle_period",
               "lifestyle_sleep",
               "lifestyle_stress"]

  $("#elementName").autocomplete({
    minLength: 0,
    source: formList,
    select: (event, ui) ->
      formSelected = ui['item']['label']
      console.log formSelected
      $(targetSelector).empty()

      getFormElement(formSelected, targetSelector, formButton)
  }).focus ->
    $(this).autocomplete("search")

@getFormElement = (formName, targetSelector, formButton) ->
  url = 'form_element.js'
  $(targetSelector).removeClass("hidden")
  req = $.ajax urlPrefix()+url,
    method: "GET",
    data: {form_name: formName, target_element_selector: targetSelector, form_button: formButton},
    dataType: "script"
  req.done( (data, textStatus, jqXHR) ->
    console.log "load form_element Successful AJAX call"
  )
  req.fail((data, textStatus, err) ->
    console.log "load form_element fail AJAX call: "
    console.log data
    console.log textStatus
    console.log err

  )
@initCustomForms = () ->
  console.log "init custom form editor"
  initFormElements("#openModalAddCustomFormElement div.formContents")
  $(document).unbind("click.addForm")
  $(document).on("click.addForm", ".add-custom-form", (evt) ->
    console.log "add custom clicked"
    $("#dataform").removeClass("hidden")
    $("#iconform").addClass("hidden")
    $("#input-form_name").removeClass("formFail")
    $("i.formFailSign").addClass("hidden")
    $("#input-form_name").val("")

    for cl in $("#iconselect")[0].classList
      $("#iconselect").removeClass(cl)
    $("#iconselect").addClass('dataFormField')
    $("#iconselect").addClass('left')
    $("#iconselect").addClass('iconselect_img_myForms')
    $("#formicon").val("img_myForms")

    location.href = "#openModalAddCustomForm"
  )

  $(document).unbind("click.addFormElement")
  $(document).on("click.addFormElement", ".add-form-element", (evt) ->
    formid = evt.target.getAttribute('data-formid')
    userid = $("#current-user-id").val()
    console.log("setting "+"/users/"+userid+"/custom_forms/"+formid+"/custom_form_elements")
    $("#openModalAddCustomFormElement input[name=customFormId]").val(formid)
#    $("#openModalAddCustomFormElement div.dataFormContainer>form").attr("action", "/users/"+userid+"/custom_forms/"+formid+"/custom_form_elements")
    location.href = "#openModalAddCustomFormElement"
  )

  $(document).on("click.closeAddForm")
  $(document).on("click.closeAddForm", "#closeModalAddCustomForm", (evt) ->
    location.href = "#close"
  )

  $("#iconselect").on("click",  (evt) ->
    console.log "iconselect clicked"
    $("#dataform").addClass("hidden")
    $("#iconform").removeClass("hidden")
  )

  $("#backToForm").on("click",  (evt) ->
    $("#dataform").removeClass("hidden")
    $("#iconform").addClass("hidden")
  )

  $("span.iconsel").on("click", (evt)->
    iconid = evt.target.id
    console.log iconid

    for cl in $("#iconselect")[0].classList
      $("#iconselect").removeClass(cl)

    $("#iconselect").addClass('dataFormField')
    $("#iconselect").addClass('left')
    $("#iconselect").addClass('iconselect_'+iconid)
    $("#formicon").val(iconid)

    $("#dataform").removeClass("hidden")
    $("#iconform").addClass("hidden")
  )

  registerAddCustomForm()

@registerAddCustomForm = (cb_succ, cb_err) ->
  self = this
  succ_fn = (d, st, jq) ->
    console.log "AJAX done: "
    console.log d
    console.log st
    console.log jq
    console.log "^^^^^^^^^^^^^^^^^^^^^"
  err_fn =  (d, st, jq) ->
    console.log "AJAX fail"
    console.log d
    console.log st
    console.log jq
    console.log "^^^^^^^^^^^^^^^^^^^^^"

  $(document).unbind("click.addCustomFormButton")
  $(document).on("click.addCustomFormButton", "button.addCustomButton", (e) ->
    btn = e.target
    popup_messages = JSON.parse($("#popup-messages").val())
    console.log btn.dataset.cform
    form_ids =btn.dataset.elements.split(',')
    console.log form_ids
    reqs = []
    for i in form_ids
      f = $("form.cfe-"+i)
      reqs.push($.ajax({
        url: f[0].action,
        type: 'POST',
        data: f.serialize()
      }).done(succ_fn).fail(err_fn))
    $.when.apply(undefined, reqs).done( () ->
      console.log "ALL COMPLETE"
      #      location.href = "customforms"
      popup_success(popup_messages.save_success)
      console.log cb_succ
      if cb_succ
        cb_succ()
    ).fail( () ->
      console.log "SOME FAILED"
      popup_error(popup_messages.failed_custom_form)
      if cb_err!= undefined
        cb_err()
    )
  )

@fixdate = (strdate) ->
  curr = moment()
  m = moment(strdate, "YYYY-MM-DD HH:mm")
  m.date(curr.date())
  m.month(curr.month())
  m.year(curr.year())
  return m.format(moment_fmt)


@testDbVer = (actualDbVersion) ->
  if typeof(Storage) != "undefined"
    try
      storedDbVersion = JSON.parse(localStorage.getItem("db_version"))
      if !storedDbVersion || storedDbVersion !=  actualDbVersion
        localStorage.clear
        return true
    catch
      return false
  else
    return false

@getStored = (key) ->
  if typeof(Storage) != "undefined"
    try
      store = JSON.parse(localStorage.getItem(key))
      if store.length == 0
         return undefined
      return store
    catch
      return undefined
  else
    return window[key]

@setStored = (key, value) ->
  if typeof(Storage) != "undefined"
   localStorage.setItem(key, JSON.stringify(value))
  else
    window[key] = value
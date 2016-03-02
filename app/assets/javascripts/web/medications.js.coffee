@medications_loaded = () ->
  console.log("medications loaded")
  $("div.app2Menu a.menulink").removeClass("selected")
  $("#medication-link").css
    background: "rgba(112, 197, 203, 0.3)"

  @popup_messages = JSON.parse($("#popup-messages").val())

  document.body.style.cursor = 'wait'
  loadMedicationTypes( () ->
    initMedication()
    loadMedicationHistory()
    document.body.style.cursor = 'auto'
  )

  $("form.resource-create-form.medication-form").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    $("#"+form_id+" input.dataFormField").val("")

    loadMedicationHistory()
    resetMedications()
    popup_success(data['medication_name']+popup_messages.saved_successfully, "medicationStyle")
  ).on("ajax:error", (e, xhr, status, error) ->
    $('#medname').val(null)
    $('#insname').val(null)
    console.log xhr.responseText
    popup_error(popup_messages.failed_to_add_data, "medicationStyle")
  )

  $("#recentResourcesTable").on("ajax:success", (e, data, status, xhr) ->
    form_item = e.currentTarget
    console.log "delete success "+form_item
    loadMedicationHistory()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    popup_error(popup_messages.failed_to_delete_data, "medicationStyle")
  )

  $("#recentResourcesTable").on("click", "td.medicationItem", (e) ->
    data = JSON.parse(e.currentTarget.querySelector("input").value)
    if(data.medication_type=="insulin")
      load_medication_insulin("#insulin_form", data)
    if(data.medication_type=="oral")
      load_medication_drugs("#drugs_form", data)
  )

  $("#drugs_form button").click ->
    validate_medication_drugs("#drugs_form")

  $("#insulin_form button").click ->
    validate_medication_insulin("#insulin_form")

  $('.hisTitle').click ->
    loadMedicationHistory()

  $(".favTitle").click ->
    load_medications(true)
    $(".hisTitle").removeClass("selected")
    $(".favTitle").addClass("selected")

@initMedication = (selector) ->
  console.log "initMedication, sel= "+selector
  self = this
  if selector==null||selector==undefined
    selector = " "
  else
    selector = selector+" "

  $(selector+"input[name='medication[date]']").datetimepicker(timepicker_defaults)

  $(selector+".oral_medication_name").autocomplete({
    minLength: 3,
    source: (request, response) ->
      matcher = new RegExp("^" + $.ui.autocomplete.escapeRegex(request.term, ""), "i")
      result = []
      cnt = 0
      for element in getStored("sd_pills")
        if matcher.test(element.label)
          result.push(element)
          cnt += 1
      response(result)
    select: (event, ui) ->
      $(selector+".oral_medication_id").val(ui.item.id)
    create: (event, ui) ->
      $(selector+".oral_medication_name").removeAttr("disabled")
    change: (event, ui) ->
      console.log ui['item']
  })

  $(selector+".medication_insulin_name").autocomplete({
    minLength: 0,
    source: (request, response) ->
      matcher = new RegExp("^" + $.ui.autocomplete.escapeRegex(request.term, ""), "i")
      result = []
      cnt = 0
      for element in getStored("sd_insulin")
        if matcher.test(element.label)
          result.push(element)
          cnt += 1
      response(result)
    select: (event, ui) ->
      console.log ui
      $(selector+".medication_insulin_id").val(ui.item.id)
    create: (event, ui) ->
      $(selector+".medication_insulin_name").removeAttr("disabled")
    change: (event, ui) ->
      insulinSelected = ui['item']
  }).focus ->
    console.log "insulin focus called"
    $(this).autocomplete("search")

@resetMedications = () ->
  $('.medication_drugs_datepicker').val(moment().format(moment_fmt))
  $('.medication_insulin_datepicker').val(moment().format(moment_fmt))

@loadMedicationHistory = () ->
  load_medications()
  $(".hisTitle").addClass("selected")
  $(".favTitle").removeClass("selected")

@load_medications = (fav=false) ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load recent medications"
  lang = $("#data-lang-medication")[0].value
  url = '/users/' + current_user + '/medications.js?source='+window.default_source+'&order=desc&limit=10&lang='+lang
  if fav
    console.log "loading favorites"
    url = url+"&favourites=true"
  $.ajax urlPrefix()+url,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent medications AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      if fav
        $(".deleteMedication").addClass("hidden")
      else
        $(".deleteMedication").removeClass("hidden")
      console.log "load recent medications  Successful AJAX call"
      console.log textStatus


@loadMedicationTypes = (cb) ->
  self = this
  current_user = $("#current-user-id")[0].value

  if !getStored("sd_pills")
    console.log "calling load medication types"
    ret = $.ajax urlPrefix()+'/medication_types.json',
      type: 'GET',
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "load recent medication_types AJAX Error: #{textStatus}"
      success: (data, textStatus, jqXHR) ->
        console.log "load medication_types  Successful AJAX call"
        popup_messages = JSON.parse($("#popup-messages").val())
        setStored("sd_pills", data.filter( (d) ->
          d['group'] == 'oral'
        ).map( (d) ->
          {
            label: d['name'],
            id: d['id']
        }))
        setStored("sd_insulin", data.filter( (d) ->
          d['group'] == 'insulin'
        ).map( (d) ->
          {
          label: d['name'],
          id: d['id']
          }))
        cb()
  else
    console.log "medication types already loaded"
    ret = new Promise( (resolve, reject) ->
      console.log("medication promise fn called")
      cb()
      resolve("medication cbs called")
    )
    return ret

validate_medication_common = (sel) ->
  if !$(sel+" input[name='medication[medication_type_id]']").val()
    popup_error(popup_messages.failed_to_add_data, "medicationStyle")
    return false
  if( !$(sel+" input[name='medication[amount]']").val() || notpositive(sel+" input[name='medication[amount]']"))
    popup_error(popup_messages.invalid_med_amount, "medicationStyle")
    return false
  return true

@validate_medication_drugs = (sel) ->
  console.log "validating drugs "+sel
  validate_medication_common(sel)

@validate_medication_insulin = (sel) ->
  console.log "validating insulin "+sel
  validate_medication_common(sel)

@load_medication_drugs = (sel, data) ->
  console.log "loading medication "+sel
  console.log data
  medication = data['medication']

  $(sel+" input[name='medication[name]']").val(data.medication_name)
  $(sel+" input[name='medication[medication_type_id]']").val(medication.medication_type_id)
  $(sel+" input[name='medication[amount]']").val(medication.amount)
  $(sel+" input[name='medication[date]']").val(moment().format(moment_fmt))

@load_medication_insulin = (sel, data) ->
  console.log "loading insulin"
  medication = data['medication']

  $(sel+" input[name='medication[name]']").val(data.medication_name)
  $(sel+" input[name='medication[medication_type_id]']").val(medication.medication_type_id)
  $(sel+" input[name='medication[amount]']").val(medication.amount)
  $(sel+" input[name='medication[date]']").val(moment().format(moment_fmt))
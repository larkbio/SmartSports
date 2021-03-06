@labresults_loaded = () ->
  self = this
  console.log "labresults loaded"
  uid = $("#current-user-id")[0].value

  $("div.app2Menu a.menulink").removeClass("selected")
  $("#labresults-link").css
    background: "rgba(237, 170, 171, 0.3)"

  document.body.style.cursor = 'wait'
  load_labresult_types( () ->
    console.log("labresulttypes loaded")
    document.body.style.cursor = 'auto'
    initLabresult()
    loadLabresult()
    loadVisits()
  )

  $("#control-create-form button").click ->
    if(!controlSelected)
      val = $("#control_txt").val()
      if !val
        val = "empty item"
      popup_error(popup_messages.failed_to_add_data, "labresultStyle")
      controlSelected = null
      return false
    controlSelected = null
    return true

  $("#ketone-create-form button").click = (evt) ->
    btnItem = evt.target
    valueItem = btnItem.parentNode.querySelector("input[name='labresult[ketone]']")
    if(!valueItem.value)
      popup_error(popup_messages.failed_to_add_data, "labresultStyle")
      return false
    return true

  $("#hba1c-create-form button").click ->
    if( isempty(".hba1c") || notpositive(".hba1c"))
      popup_error(popup_messages.failed_to_create_HBA1C, "labresultStyle")
      return false
    return true
  $("#ldlchol-create-form button").click ->
    if( isempty(".ldl_chol") || notpositive(".ldl_chol"))
      popup_error(popup_messages.failed_to_create_LDL, "labresultStyle")
      return false
    return true
  $("#egfrepi-create-form button").click ->
    if( isempty(".egfr_epi") || notpositive(".egfr_epi"))
      popup_error(popup_messages.failed_to_create_EGFR, "labresultStyle")
      return false
    return true

  $("form.resource-create-form.notification-form").on("ajax:success", (e, data, status, xhr) ->
    console.log "notification created, ret = "
    console.log data
    if data.ok
      $("#nType").val(null)
      $(".notification_details").val(null)
      loadVisits()
    else
      popup_error(popup_messages.failed_to_add_data, "labresultStyle")
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    popup_error(popup_messages.failed_to_add_data, "labresultStyle")
  )

  $("form.resource-create-form.lab_results-form").on("ajax:success", (e, data, status, xhr) ->
    category = data['category']
    user_lang = $("#user-lang")[0].value
    if user_lang == "hu" && category && category == "ketone"
      category = "keton"

    console.log "labresult form ajax success with data:"
    console.log data
    if category
      loadLabresult()

    $(".hba1c").val(null)
    $(".ldl_chol").val(null)
    $(".egfr_epi").val(null)
    $(".notification_details").val(null)


    if !category
      category = 'control'
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    popup_error(popup_messages.failed_to_add_data, "labresultStyle")
  )

  $("#recentResourcesTable").on("ajax:success", (e, data, status, xhr) ->
    form_item = e.currentTarget
    loadLabresult()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    popup_error(popup_messages.failed_to_delete_data, "labresultStyle")
  )

  $(".notificationTable").on("ajax:success", (e, data, status, xhr) ->
    form_item = e.currentTarget
    loadVisits()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    popup_error(popup_messages.failed_to_delete_data, "labresultStyle")
  )

  $(document).unbind("click.labresultShow")
  $(document).on("click.labresultShow", "#labresult-show-table", (evt) ->
    current_user = $("#current-user-id")[0].value
    lang = $("#user-lang")[0].value
    labresult_header = $("#labresult_header_values").val().split(",")
    url = 'users/' + current_user + '/labresults.json'+'?table=true&lang='+lang
    show_table(url, lang, labresult_header, 'get_labresult_table_row', 'show_labresult_table')
  )

  $(document).unbind("click.downloadLabresult")
  $(document).on("click.downloadLabresult", "#download-labresult-data", (evt) ->
    current_user = $("#current-user-id")[0].value
    lang = $("#user-lang")[0].value
    url = '/users/' + current_user + '/labresults.csv?order=desc&lang='+lang
    location.href = url
  )

  $(document).unbind("click.closeLabresult")
  $(document).on("click.closeLabresult", "#close-labresult-data", (evt) ->
    $("#labresult-data-container").html("")
    location.href = "#close"
  )

@initLabresult = () ->
  console.log "init labres"
  self = this

  doctorList = $("#doctorList").val().split(";")
  controlList = [{ label: doctorList[0], value: doctorList[0], intValue: 1},
    { label: doctorList[1], value: doctorList[1], intValue: 2}
  ]

  user_lang = $("#user-lang")[0].value
  if !user_lang
    user_lang='hu'

  labresult_control_select = $("#control_txt")
  labresult_ketone_select = $(".ketone_name")

  if user_lang
    labkey = 'sd_labresult_'+user_lang
  else
    labkey = 'sd_labresult_hu'

  for element in controlList
    labresult_control_select.append($("<option />").val(element.value).text(element.label))
  for element in getStored(labkey)
    labresult_ketone_select.append($("<option />").val(element.label).text(element.label))

  notif_types = ['doctors_visit_general', 'doctors_visit_specialist']
  $("#nType").val(notif_types[0])
  $(".ketone_type_id").val(get_ketone_value('Negative'))
  $("#control_txt").on("change", (e) ->
    $("#nType").val(notif_types[e.currentTarget.selectedIndex])
  )

  $(".ketone_name").on("change", (e) ->
    val = get_ketone_value(e.currentTarget.options[e.currentTarget.selectedIndex].value)
    $(".ketone_type_id").val(val)
  )

  $('.hba1c_datepicker').datetimepicker({
    format: 'Y-m-d',
    timepicker: false,
    lang: user_lang
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
    todayButton: true
  })
  $('.ldl_chol_datepicker').datetimepicker({
    format: 'Y-m-d',
    timepicker: false,
    lang: user_lang
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
    todayButton: true
  })
  $('.egfr_epi_datepicker').datetimepicker({
    format: 'Y-m-d',
    timepicker: false,
    lang: user_lang
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
    todayButton: true
  })
  $('.ketone_datepicker').datetimepicker({
    format: 'Y-m-d',
    timepicker: false,
    lang: user_lang
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
    todayButton: true
  })

  $('#controll_datepicker').datetimepicker(timepicker_defaults)

  @popup_messages = JSON.parse($("#popup-messages").val())

@validate_labresult_form = (formSel) ->
  formValue = $(formSel+" input[type=number]").val()
  if isempty(formSel+" input[type=number]") || notpositive(formSel+" input[type=number]")
    popup_error(popup_messages.failed_to_create_labresult, "labresultStyle")
    return false
  return true

@load_labresult_types = (cb) ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load labresult types"
  user_lang = $("#user-lang")[0].value
  db_version = $("#db-version")[0].value
  if user_lang
    labresultkey = 'sd_labresult_'+user_lang
  else
    labresultkey = 'sd_labresult_hu'
  if getStored(labresultkey)==undefined || getStored(labresultkey).length==0 || testDbVer(db_version,['sd_labresult_hu','sd_labresult_en'])
    ret = $.ajax '/labresult_types.json',
      type: 'GET',
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "load labresult_types AJAX Error: "+errorThrown
      success: (data, textStatus, jqXHR) ->
        console.log "load labresult_types  Successful AJAX call"

        setStored('sd_labresult_hu', data.filter( (d) ->
          d['category'] == "ketone"
        ).map( (d) ->
          {
          label: d['hu'],
          id: d['name']
          }))

        setStored('sd_labresult_en', data.filter( (d) ->
          d['category'] == "ketone"
        ).map( (d) ->
          {
          label: d['en'],
          id: d['name']
          }))

        setStored('db_version', db_version)

        cb()
  else
    ret = new Promise( (resolve, reject) ->
      console.log "labresults already downloaded"
      cb()
      resolve("labresults cbs called")
    )
  return ret

@loadLabresult = () ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load recent lab_results"
  lang = $("#data-lang-labresult")[0].value
  url = 'users/' + current_user + '/labresults.js?source='+window.default_source+'&order=desc&limit=10&lang='+lang
  console.log url
  $.ajax urlPrefix()+url,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent lab_results AJAX Error: "+errorThrown
    success: (data, textStatus, jqXHR) ->
      console.log "load recent lab_results  Successful AJAX call"
      console.log textStatus

@loadVisits = () ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load recent visits"
  lang = $("#data-lang-labresult")[0].value
  url = 'users/' + current_user + '/notifications.js?upcoming=true&order=desc&limit=10&ntype=visits&patient=true&lang='+lang
  console.log url
  $.ajax urlPrefix()+url,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent visits AJAX Error: "+errorThrown
    success: (data, textStatus, jqXHR) ->
      console.log "load recent visits  Successful AJAX call"
      console.log textStatus


@get_ketone_value = (label) ->
  user_lang = $("#user-lang")[0].value
  if !user_lang
    user_lang='hu'

  if user_lang
    labkey = 'sd_labresult_'+user_lang
  else
    labkey = 'sd_labresult_hu'

  tmp = getStored(labkey).filter((d) ->
    return d.label==label
  )
  if tmp.length!=0
    value = tmp[0].id

  if value==null
    value = 'Unknown'
  return value

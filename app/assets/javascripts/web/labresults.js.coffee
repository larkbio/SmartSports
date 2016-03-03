@labresults_loaded = () ->
  self = this
  console.log "labresults loaded"
  uid = $("#current-user-id")[0].value

  initLabresult()
  loadLabresult()
  loadVisits()

  $("div.app2Menu a.menulink").removeClass("selected")
  $("#labresults-link").css
    background: "rgba(237, 170, 171, 0.3)"

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
      popup_error(opup_messages.failed_to_create_LDL, "labresultStyle")
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
      $("#control_txt").val(null)
      $(".notification_details").val(null)
      loadVisits()
      popup_success("Notification "+popup_messages.saved_successfully, "labresultStyle")
    else
      popup_error(popup_messages.failed_to_add_data, "labresultStyle")
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    popup_error(popup_messages.failed_to_add_data, "labresultStyle")
  )

  $("form.resource-create-form.lab_results-form").on("ajax:success", (e, data, status, xhr) ->
    category = data['category']
    console.log "labresult form ajax success with data:"
    console.log data
    if category
      loadLabresult()

    $("#control_txt").val(null)
    $(".hba1c").val(null)
    $(".ldl_chol").val(null)
    $(".egfr_epi").val(null)
    $(".ketone").val(null)
    $(".notification_details").val(null)

    if !category
      category = 'control'
    popup_success(capitalize(category)+popup_messages.saved_successfully, "labresultStyle")
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

  $("#recentVisitsTable").on("ajax:success", (e, data, status, xhr) ->
    form_item = e.currentTarget
    load_visits()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    popup_error(popup_messages.failed_to_delete_data, "labresultStyle")
  )

@initLabresult = () ->
  console.log "init labres"
  self = this

  doctorList = $("#doctorList").val().split(";")
  controlList = [{ label: doctorList[0], value: doctorList[0], intValue: 1},
    { label: doctorList[1], value: doctorList[1], intValue: 2}
  ]

  controlSelected = null
  notif_types = ['doctors_visit_general', 'doctors_visit_specialist']
  $("#control_txt").autocomplete({
    minLength: 0,
    source: controlList,
    change: (event, ui) ->
      console.log ui.item
      controlSelected = ui.item
      $("#control").val(ui.item.intValue)
      $("#nType").val(notif_types[ui.item.intValue-1])
  }).focus ->
    $(this).autocomplete("search")

  ketoneList = [ { label: "Negative", value: "Negative" },
    { label: "+", value: "1" },
    { label: "++", value: "2" },
    { label: "+++", value: "3" },
    { label: "++++", value: "4" },
    { label: "+++++", value: "5" }
  ]
  @ketoneHash = {
    "Negative": "Negative",
    "1": "+",
    "2": "++",
    "3": "+++",
    "4": "++++",
    "5": "+++++"
  }

  setKetone = (event, ui) ->
    labelItem = event.target
    labelItem.value = ui['item']['label']
    valueItem = labelItem.parentNode.querySelector("input[name='labresult[ketone]']")
    valueItem.value = ui['item']['value']

  $(".ketone").autocomplete({
    minLength: 0,
    source: ketoneList,
    change: (event, ui) ->
      console.log "change: "
      console.log ui['item']
      console.log event.target
      setKetone(event, ui)
    select: (event, ui) ->
      console.log "select: "
      console.log ui['item']
      console.log event.target
      setKetone(event, ui)
      return false
  }).focus ->
    $(this).autocomplete("search")


  $('.hba1c_datepicker').datetimepicker({
    format: 'Y-m-d',
    timepicker: false
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
    todayButton: true
  })
  $('.ldl_chol_datepicker').datetimepicker({
    format: 'Y-m-d',
    timepicker: false
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
    todayButton: true
  })
  $('.egfr_epi_datepicker').datetimepicker({
    format: 'Y-m-d',
    timepicker: false
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
    todayButton: true
  })
  $('.ketone_datepicker').datetimepicker({
    format: 'Y-m-d',
    timepicker: false
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
    todayButton: true
  })

  $('#controll_datepicker').datetimepicker(timepicker_defaults)

  @popup_messages = JSON.parse($("#popup-messages").val())

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
      console.log "load recent lab_results AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load recent lab_results  Successful AJAX call"
      console.log textStatus

@loadVisits = () ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load recent lab_results"
  lang = $("#data-lang-labresult")[0].value
  url = 'users/' + current_user + '/notifications.js?upcoming=true&order=desc&limit=10&ntype=visits&lang='+lang
  console.log url
  $.ajax urlPrefix()+url,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent lab_results AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load recent lab_results  Successful AJAX call"
      console.log textStatus

@load_labresult_ketone = (sel, data) ->
  console.log("load ketone: "+sel+" data:")
  labres = data['labresult']
  console.log(labres)
  console.log(labres.ketone)

  $(sel+" input[name='labresult[ketone]']").val(labres['ketone'])
  $(sel+" .ketone").val(@ketoneHash[labres['ketone']])
  $(sel+" input[name='labresult[date]']").val(labres['date'])
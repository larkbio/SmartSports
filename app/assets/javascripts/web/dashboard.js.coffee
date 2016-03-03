@dashboard_loaded = () ->
  console.log("dashboard loaded")

  $("div.app2Menu a.menulink").removeClass("selected")
  $("#dashboard-link").addClass("selected")
  uid = $("#current-user-id")[0].value
  loadPatientNotifications(uid)

  $(document).unbind("click.patientNotif")
  $(document).on("click.patientNotif", "#notificationContainer .showNotifClickArea", (evt) ->
    if "hidden" in $("#currentForm")[0].classList
      loadForm(evt)
    else
      $("#currentForm").addClass("hidden")
      $("#currentForm").html("")
  )

  $(document).unbind("ajax:success.deleteNotif")
  $(document).on("ajax:success.deleteNotif", "#notificationContainer", (e, data, status, xhr) ->
    console.log "notification dismissed"
    console.log data
    $("#currentForm").addClass("hidden")
    $("#currentForm").html("")
    loadPatientNotifications(uid)
  )

  $(document).unbind("ajax:success.notifform")
  $(document)
  .on("ajax:success.notifform", "#currentForm .resource-create-form", (e, data, status, xhr) ->
    console.log("form created succ")
    $("#currentForm").addClass("hidden")
    $("#currentForm").html("")
    notifId = $("#currentForm")[0].dataset.notifid
    url = "notifications/"+notifId
    $.ajax urlPrefix()+url,
      type: 'PUT',
      data: {dismiss: true}
      success: (data, textStatus, jqXHR) ->
        console.log "dismissed notif "+notifId
        loadPatientNotifications(uid)
        popup_messages = JSON.parse($("#popup-messages").val())
        popup_success(popup_messages.save_success)
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "failed to dismis notif "+notifId
  )
  .on("ajax:error.notifform", "#currentForm .resource-create-form", (e, xhr, status, error) ->
    popup_messages = JSON.parse($("#popup-messages").val())
    popup_error(popup_messages.failed_to_add_data)
  )

  lang = $("#user-lang")[0].value
  url = 'users/' + uid + '/analysis_data.json?date='+moment().format(moment_datefmt)+'&weekly=true&dashboard=true&lang='+lang
  $.ajax urlPrefix()+url,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load analysis_data AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load analysis_data AJAX success"
      histData = convertToHistory(data)
      addPoints("#canv", histData)

@loadPatientNotifications = (userId) ->
  lang = $("#user-lang")[0].value
  url = 'users/' + userId + '/notifications.js?order=desc&limit=5&patient=true&active=true&lang='+lang
  console.log "calling load notifications for: "+userId+" "+url
  $.ajax urlPrefix()+url,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent notifications AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load recent notifications Successful AJAX call"

@loadForm = (evt) ->
  @popup_messages = JSON.parse($("#popup-messages").val())
  formNameInput = evt.currentTarget.querySelector("input.formName")
  formName = null
  if formNameInput
    formName = formNameInput.value
  notif = evt.currentTarget.querySelector("input.notificationId")
  notifId = null
  if notif
    notifId = notif.value
  console.log "loadform called: id="+formName
  if formName
    $.ajax({
      url: urlPrefix()+"form_element.js",
      type: 'GET',
      data: {form_name: formName, target_element_selector: "#currentForm"},
      dataType: "script",
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "load custom form AJAX Error: #{textStatus}"
      success: (data, textStatus, jqXHR) ->
        console.log "load custom form Successful AJAX call"
        $("#currentForm").attr("data-notifid", notifId)
        $("#currentForm").removeClass("hidden")
        customPreload()
        if $(".notification_"+notifId+" .defaultData")
          fillElementDefaults(JSON.parse($(".notification_"+notifId+" .defaultData").val()))
#        registerAddCustomForm( () ->
#          console.log "dismiss: "+notifId
#          $("#dismiss_notif_"+notifId).submit()
#        )

    })
  else
    $("#currentForm").addClass("hidden")
    $("#currentForm").html("")

@fillElementDefaults = (data) ->
  console.log(data)
  mainKey = Object.keys(data)[0]
  for k in Object.keys(data[mainKey])
    console.log(k+"->"+data[mainKey][k])
    $("#currentForm input[name='"+mainKey+"["+k+"]"+"']").val(data[mainKey][k])

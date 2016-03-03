@genetics_loaded = () ->
  console.log("genetics loaded")

  $("div.app2Menu a.menulink").removeClass("selected")
  $("#genetics-link").css
    background: "rgba(56, 199, 234, 0.3)"

  load_family_histories()
#  if $("#popup-messages").val() != null
#    popup_messages = JSON.parse($("#popup-messages").val())
  popup_messages = JSON.parse($("#popup-messages").val())
  relativeList = JSON.parse($("#relativeList").val())
  diseaseList = JSON.parse($("#diseaseList").val())

  relativeSelected = null
  $("#gen_hist_relative").autocomplete({
    minLength: 0,
    source: relativeList,
    change: (event, ui) ->
      relativeSelected = ui['item']
  }).focus ->
    $(this).autocomplete("search")

  diseaseSelected = null
  $("#gen_hist_disease").autocomplete({
    minLength: 0,
    source: diseaseList,
    change: (event, ui) ->
      diseaseSelected = ui['item']
  }).focus ->
    $(this).autocomplete("search")

  $("#familyhist-create-form button").click ->
    if(relativeSelected==null || diseaseSelected==null)
      popup_error(popup_messages.failed_to_add_data, "geneticsStyle")

      return false
    relativeSelected = null
    diseaseSelected = null
    return true

  $("form.resource-create-form.family-history-form").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id
    console.log data
    $("#"+form_id+" input.dataFormField").val("")
    $("#gen_hist_note").val("")
    load_family_histories()
    popup_success(data['disease']+popup_messages.saved_successfully, "geneticsStyle")
  ).on("ajax:error", (e, xhr, status, error) ->
    popup_error(popup_messages.failed_to_add_data, "geneticsStyle")
  )

  $("#recentResourcesTable").on("ajax:success", (e, data, status, xhr) ->
    form_item = e.currentTarget
    console.log "delete success "+form_item

    load_family_histories()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    popup_error(popup_messages.failed_to_delete_data, "geneticsStyle")
  )

@load_family_histories = () ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load recent family histories"
  url = 'users/' + current_user + '/family_histories.js?source='+window.default_source+'&order=desc&limit=10'
  $.ajax urlPrefix()+url,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent family hist AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load recent family hist  Successful AJAX call"
      console.log textStatus

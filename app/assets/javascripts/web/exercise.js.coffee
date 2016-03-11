@exercise_loaded = () ->
  uid = $("#current-user-id")[0].value

  $("div.app2Menu a.menulink").removeClass("selected")
  $("#exercise-link").css
    background: "rgba(238, 152, 67, 0.3)"

  popup_messages = JSON.parse($("#popup-messages").val())

  document.body.style.cursor = 'wait'
  loadActivityTypes( () ->
    document.body.style.cursor = 'auto'
    initActivity()
    loadExerciseHistory()
  )

  $("#exercise-create-form").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id

    $("#"+form_id+" input.dataFormField").val("")

    $('.activity_exercise_start_datepicker').val(moment().subtract(30,'minutes').format(moment_fmt))
    $('.activity_exercise_end_datepicker').val(moment().format(moment_fmt))
    $('#activity_type_id').val(null)

    loadExerciseHistory()
    console.log data
    popup_success(data['activity_name']+popup_messages.saved_successfully+' '+data['cal_message'], "exerciseStyle")
  ).on("ajax:error", (e, xhr, status, error) ->
    popup_error(popup_messages.failed_to_add+$(".activity_exercise_name").val()+' '+xhr.responseJSON.msg, "exerciseStyle")
  )

  $("#regular-activity-create-form").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id

    $("#"+form_id+" input.dataFormField").val("")
    $('.activity_regular_start_datepicker').val(moment().subtract(30,'minutes').format(moment_fmt))
    $('.activity_regular_end_datepicker').val(moment().format(moment_fmt))
    $('#activity_other_type_id').val(null)

    loadExerciseHistory()
    console.log data
    popup_success(data['activity_name']+popup_messages.saved_successfully+' '+data['cal_message'], "exerciseStyle")
  ).on("ajax:error", (e, xhr, status, error) ->
    popup_error(popup_messages.failed_to_add+$("#otheractivityname").val()+' '+xhr.responseJSON.msg, "exerciseStyle")
  )

  $("#recentResourcesTable").on("ajax:success", (e, data, status, xhr) ->
    form_item = e.currentTarget
    console.log "delete success "+form_item
    loadExerciseHistory()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    popup_error(popup_messages.failed_to_delete_data, "exerciseStyle")
  )

  $('.hisTitle').click ->
    loadExerciseHistory()

  $(".favTitle").click ->
    load_exercise(true)
    $(".hisTitle").removeClass("selected")
    $(".favTitle").addClass("selected")

  $("#recentResourcesTable").on("click", "td.activityItem", (e) ->
    data = JSON.parse(e.currentTarget.querySelector("input").value)
    if data.activity_category=="sport"
      load_activity_exercise(".formElement.activity_exercise_elem", data)
    else
      load_activity_regular(".formElement.activity_regular_elem", data)
  )

  $(document).unbind("click.exerciseShow")
  $(document).on("click.exerciseShow", "#exercise-show-table", (evt) ->
    console.log "datatable clicked"
    current_user = $("#current-user-id")[0].value
    url = 'users/' + current_user + '/activities.json'
    $.ajax urlPrefix()+url,
      type: 'GET',
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "datatable activity AJAX Error: #{textStatus}"
      success: (data, textStatus, jqXHR) ->
        tblData = $.map(data,(item,i) ->
          return([get_exercise_table_row(item)])
        ).filter( (v) ->
          return(v!=null)
        )
        $("#exercise-data-container").html("<table id=\"exercise-data\" class=\"display\" cellspacing=\"0\" width=\"100%\"></table>")
        $("#exercise-data").dataTable({
          "data": tblData,
          "columns": [
            {"title": "id"},
            {"title": "date"},
            {"title": "name"},
            {"title": "intensity"},
            {"title": "duration"}
          ],
          "order": [[1, "desc"]],
          "lengthMenu": [10]
        })
        location.href = "#openModalEx"
  )

  $(document).unbind("click.downloadExercise")
  $(document).on("click.downloadExercise", "#download-exercise-data", (evt) ->
    current_user = $("#current-user-id")[0].value
    url = '/users/' + current_user + '/activities.csv?order=desc'
    location.href = url
  )

  $(document).unbind("click.closeExercise")
  $(document).on("click.closeExercise", "#close-exercise-data", (evt) ->
    $("#exercise-data-container").html("")
    location.href = "#close"
  )

@get_exercise_table_row = (item ) ->
  if item.activity==null || !item.intensity || !item.duration
    return null
  return ([item.id, moment(item.start_time).format("YYYY-MM-DD HH:MM"), item.activity, item.intensity, item.duration])

@initActivity = (selector) ->
  console.log "initActivity called, selector="+selector
  self = this
  if selector==null||selector==undefined
    selector = ""
  else
    selector = selector+" "

  $(selector+".activity_exercise_scale").slider({
    min: 0,
    max: 2,
    value: 1
  }).slider({
    slide: (event, ui) ->
      event.target.parentElement.parentElement.querySelector("div.activity_exercise_percent").innerHTML = intensities[ui.value]
#      $(".activity_exercise_percent").html(intensities[ui.value])
    change: (event, ui) ->
      event.target.parentElement.parentElement.querySelector("input.activity_exercise_intensity").value = ui.value
#      $(".activity_exercise_intensity").val(ui.value)
  })

  $(selector+".activity_regular_scale").slider({
    min: 0,
    max: 2,
    value: 1
  }).slider({
    slide: (event, ui) ->
      console.log event.target
      event.target.parentElement.parentElement.querySelector("div.activity_regular_percent").innerHTML = intensities[ui.value]
    change: (event, ui) ->
      event.target.parentElement.parentElement.querySelector("input.activity_regular_intensity").value = ui.value
  })

  $(selector+'.activity_exercise_start_datepicker').datetimepicker(timepicker_defaults)
  $(selector+'.activity_exercise_end_datepicker').datetimepicker(timepicker_defaults)

  $(selector+'.activity_regular_start_datepicker').datetimepicker(timepicker_defaults)
  $(selector+'.activity_regular_end_datepicker').datetimepicker(timepicker_defaults)

  popup_messages = JSON.parse($("#popup-messages").val())
  activitySelected = null
  $(".activity_exercise_name").autocomplete({
    minLength: 0,
    source: (request, response) ->
      matcher = new RegExp($.ui.autocomplete.escapeRegex(remove_accents(request.term), ""), "i")
      result = []
      cnt = 0
      user_lang = $("#user-lang")[0].value
      if user_lang
        activity_key = 'sd_activities_'+user_lang
      else
        activity_key = 'sd_activities_hu'

      for element in getStored(activity_key)
        if matcher.test(remove_accents(element.label))
          result.push(element)
          cnt += 1
      response(result)
    select: (event, ui) ->
      $(".activity_exercise_type_id").val(ui.item.id)
      $(".activity_exercise_scale" ).slider({
        value: "1"
      })
      $(".activity_exercise_percent").text(intensities[1])
    create: (event, ui) ->
      $(".activity_exercise_name").removeAttr("disabled")
    change: (event, ui) ->
      activitySelected = ui['item']
      console.log "activity change"
      console.log ui['item']
  }).focus ->
    $(this).autocomplete("search")

  otherActivitySelected = null
  $(".activity_regular_name").autocomplete({
    minLength: 0,
    source: (request, response) ->
      matcher = new RegExp($.ui.autocomplete.escapeRegex(remove_accents(request.term), ""), "i")
      result = []
      cnt = 0
      for element in getStored("sd_other_activities")
        if matcher.test(remove_accents(element.label))
          result.push(element)
          cnt += 1
      response(result)
    select: (event, ui) ->
      $(".activity_regular_type_id").val(ui.item.id)
      $(".activity_regular_scale" ).slider({
        value: "1"
      })
      $(".activity_regular_percent").text(intensities[1])
    create: (event, ui) ->
      $(".activity_regular_name").removeAttr("disabled")
    change: (event, ui) ->
      otherActivitySelected = ui['item']
  }).focus ->
    $(this).autocomplete("search")


@loadExerciseHistory = () ->
  load_exercise()
  $(".hisTitle").addClass("selected")
  $(".favTitle").removeClass("selected")

@load_exercise = (fav=false) ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load recent exercises"
  lang = $("#data-lang-training")[0].value
  url = 'users/' + current_user + '/activities.js?source='+window.default_source+'&order=desc&limit=10&lang='+lang
  if fav
    console.log "loading favorites"
    url = url+"&favourites=true"
  $.ajax urlPrefix()+url,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent activities AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      if fav
        $(".deleteExercise").addClass("hidden")
      else
        $(".deleteExercise").removeClass("hidden")
      console.log "load recent activities  Successful AJAX call"

@loadActivityTypes = (cb) ->
  self = this
  @intensities = $("#intensity_values").val().split(" ")
  user_lang = $("#user-lang")[0].value
  db_version = $("#db-version")[0].value
  console.log db_version
  console.log "calling load activity types"

  if user_lang
    activity_key = 'sd_activities_'+user_lang
  else
    activity_key = 'sd_activities_hu'

  if !getStored(activity_key) || testDbVer(db_version,['sd_activities_hu','sd_activities_en'])
    ret = $.ajax urlPrefix()+'activity_types.json',
      type: 'GET',
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "load activity_types AJAX Error: #{textStatus}"
      success: (data, textStatus, jqXHR) ->
        console.log "load activity_types  Successful AJAX call"

        setStored('sd_activities_hu', data.filter( (d) ->
          d['category'] == 'sport' && d['lang'] == 'hu'
        ).map( (d) ->
          {
          label: d['name'],
          id: d['id']
          }))

        setStored('sd_activities_en', data.filter( (d) ->
          d['category'] == 'sport' && d['lang'] == 'en'
        ).map( (d) ->
          {
          label: d['name'],
          id: d['id']
          }))

        setStored('db_version', db_version)
        cb()
  else
    ret = new Promise( (resolve, reject) ->
      console.log "activities already downloaded"
      cb()
      resolve("cbs called")
    )
  return ret

@load_activity_exercise = (sel, data) ->
  console.log "load activity, sel="+sel
  console.log(data)
  activity = data['activity']
  $(sel+" input[name='activity[activity]']").val(activity.activity)
  $(sel+" input[name='activity[activity_type_id]']").val(activity.activity_type_id)
  $(sel+" input[name='activity[intensity]']").val(activity.intensity)
  $(sel+" .activity_exercise_percent").html(@intensities[activity.intensity])
  $(sel+" .activity_exercise_scale").slider({value: activity.intensity})
  diff = moment(activity.start_time).diff(moment(activity.end_time))
  curr = moment()
  f = curr.format(moment_fmt)
  t = curr.add(diff).format(moment_fmt)
  $(sel+" input[name='activity[start_time]']").val(f)
  $(sel+" input[name='activity[end_time]']").val(t)

@load_activity_regular= (sel, data) ->
  if !sel
    sel=""
  console.log('load regular, sel='+sel)
  activity = data['activity']
  console.log(data)
  console.log(activity)
  $(sel+" input[name='activity[activity]']").val(activity.activity)
  $(sel+" input[name='activity[activity_type_id]']").val(activity.activity_type_id)
  $(sel+" input[name='activity[intensity]']").val(activity.intensity)
  $(sel+" .activity_regular_percent").html(@intensities[activity.intensity])
  $(sel+" .activity_regular_scale").slider({value: activity.intensity})
  diff = moment(activity.start_time).diff(moment(activity.end_time))
  curr = moment()
  f = curr.format(moment_fmt)
  t = curr.add(diff).format(moment_fmt)
  $(sel+" input[name='activity[start_time]']").val(f)
  $(sel+" input[name='activity[end_time]']").val(t)

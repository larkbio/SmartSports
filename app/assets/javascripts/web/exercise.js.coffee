#= require common/ActivityChart
#= require common/OverviewChart
#= require common/TrainingTrendChart

@exercise_loaded = () ->
  uid = $("#current-user-id")[0].value
#  register_events()
  init_exercise()
  load_activity_types()
  load_other_activity_types()
  loadExerciseHistory()
  $("div.appMenu button").removeClass("selected")
  $("#exercise-button").addClass("selected")

#  d3.json("/users/"+uid+"/summaries.json", data_received)

init_exercise = () ->
  console.log "init exercise"

  $('#walking_steps').watermark('Steps, eg: 8120')
  $('#walking_duration').watermark('Duration, eg: 90')
  $('#walking_distance').watermark('Distance, eg: 1200')
  $('#running_steps').watermark('Steps, eg: 8120')
  $('#running_duration').watermark('Duration, eg: 90')
  $('#running_distance').watermark('Distance, eg: 1200')
  $('#cycling_duration').watermark('Duration, eg: 120')
  $('#cycling_distance').watermark('Distance, eg: 9200')
  $('#swimming_duration').watermark('Duration, eg: 60')
  $('#swimming_distance').watermark('Distance, eg: 1200')
  $('#walking_steps').focus()

  $('#activity_group').selectmenu()
  $("#activity_intensity").val(2)
  $("#activity_other_intensity").val(2)

  $("#activity_scale").slider({
    min: 1,
    max: 3,
    value: 2
  }).slider({
    slide: (event, ui) ->
      $("#activity_percent").html(ui.value)
    change: (event, ui) ->
      $("#activity_intensity").val(ui.value)
  })

  $("#activity_other_scale").slider({
    min: 1,
    max: 3,
    value: 2
  }).slider({
    slide: (event, ui) ->
      $("#activity_other_percent").html(ui.value)
    change: (event, ui) ->
      $("#activity_other_intensity").val(ui.value)
  })

  $('#activity_start_datepicker').datetimepicker(timepicker_defaults)
  $('#activity_end_datepicker').datetimepicker(timepicker_defaults)

  $('#activity_other_start_datepicker').datetimepicker(timepicker_defaults)
  $('#activity_other_end_datepicker').datetimepicker(timepicker_defaults)
#  $('#running_datepicker').datetimepicker(timepicker_defaults)

  $("form.resource-create-form.exercise-form").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id
    console.log e
    console.log xhr.responseText
    $("#"+form_id+" input.dataFormField").val("")
    $('#activity_start_datepicker').val(moment().format(moment_fmt))
    $('#activity_end_datepicker').val(moment().format(moment_fmt))
    $('#activity_other_start_datepicker').val(moment().format(moment_fmt))
    $('#activity_other_end_datepicker').val(moment().format(moment_fmt))

    loadExerciseHistory()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    alert("Failed to create measurement.")
  )

  $("#recentResourcesTable").on("ajax:success", (e, data, status, xhr) ->
    form_item = e.currentTarget
    console.log "delete success "+form_item

    loadExerciseHistory()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    alert("Failed to delete measurement.")
  )

  $('.hisTitle').click ->
    loadExerciseHistory()

  $(".favTitle").click ->
    load_exercise(true)
    $(".hisTitle").removeClass("selected")
    $(".favTitle").addClass("selected")

  $("#recentResourcesTable").on("click", "td.activityItem", (e) ->
    console.log "loading activity"
    data = JSON.parse(e.currentTarget.querySelector("input").value)
    console.log data
    if data.activity_category=="sport"
      $("#activityname").val(data.activity_name)
      $("#activity_type_id").val(data.activity_type_id)
      $("#activity_intensity").val(data.intensity)
      $("#activity_percent").html(data.intensity)
      $("#activity_scale").slider({value: data.intensity})
    else if data.activity_category!="sport"
      $("#otheractivityname").val(data.activity_name)
      $("#activity_other_type_id").val(data.activity_type_id)
      $("#activity_other_intensity").val(data.intensity)
      $("#activity_other_percent").html(data.intensity)
      $("#activity_other_scale").slider({value: data.intensity})
  )

@loadExerciseHistory = () ->
  load_exercise()
  $(".hisTitle").addClass("selected")
  $(".favTitle").removeClass("selected")

@load_exercise = (fav=false) ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load recent exercises"
  url = '/users/' + current_user + '/activities.js?source='+window.default_source+'&order=desc&limit=10'
  if fav
    console.log "loading favorites"
    url = url+"&favourites=true"
  $.ajax url,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent activities AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load recent activities  Successful AJAX call"
      console.log textStatus

data_received = (jsondata) ->
  draw_trends(jsondata)
  draw_conn(jsondata)

draw_trends = (jsondata) ->
  act_trend_chart = new TrainingTrendChart("activity-trend", jsondata,
    ["steps", "running_duration", "cycling_duration"],
    ["Steps"," Running", "Cycling", ],
    ["right", "left", "left"],
    ["colset7_5", "colset2_0", "colset2_2"],
    ["minutes", "steps"]
    true
  )
  act_trend_chart.preproc_cb = (data) ->
    keys = ["walking_duration", "running_duration", "cycling_duration"]
    for d in data
      for k in keys
        d[k] = d[k]/60.0
  act_trend_chart.margin = {top: 20, right: 50, bottom: 20, left: 35}
  act_trend_chart.draw()


@trend_charts = []
@activity_charts = []
self = this


draw_conn = (jsondata) ->
  for elem in $("#training-container div.connection-block")
    conn =  $("#"+elem.id+" input.connection-name")[0].value
    conndata = get_conn_data(jsondata, conn)
    delete conndata['sleep']
    draw_conn_data(conndata, conn)

get_conn_data = (data, sourcename) ->
  keys = Object.keys(data)
  result = {}
  for k in keys
    result[k] = []
  for k in keys
    for d in data[k]
      if d.source == sourcename
        result[k].push( d )
  return(result)

get_data_size = (data)->
    h = {}
    walking = if data.walking then data.walking else []
    running = if data.running then data.running else []
    cycling = if data.cycling then data.cycling else []
    for d in walking.concat(running.concat(cycling))
      curr = fmt(new Date(Date.parse(d.date)))
      h[curr] = true
    datanum = Object.keys(h).length
    return datanum


draw_conn_data = (jsondata, source) ->
  console.log "DOING "+source

  datanum = get_data_size(jsondata)
  if datanum==0
    console.log "No data"
    return

  conv_to_km = (data) ->
    for d in data
      d.distance = d.distance/1000

  if jsondata.walking
    conv_to_km(jsondata.walking)
  if jsondata.running
    conv_to_km(jsondata.running)
  if jsondata.cycling
    conv_to_km(jsondata.cycling)


  d = new Date(Date.now())

  activity_chart = new ActivityChart(source, source+"-container", jsondata)
  @activity_charts.push(activity_chart)
  activity_chart.update_daily(fmt(d))
  activity_chart.draw(d, "walking")
  activity_chart.set_callback(selection_callback)

  trend_chart = new OverviewChart(source, source+"-container", jsondata)
  trend_chart.draw(d, "walking")
  @trend_charts.push(trend_chart)

  activity_chart.show_selection()
  trend_chart.show_curr_week(d)

selection_callback = (d) ->
  trend_chart = get_chart(self.trend_charts, d.source)
  trend_chart.show_curr_week(new Date(Date.parse(d.date)))

is_weekly = (par) ->
  return ($(par).find("input.is-weekly")[0].value == "yes")

get_curr_date = (par) ->
  return (new Date(Date.parse($(par).find("input.curr-date")[0].value)))

get_current_meas = (par) ->
  return ($(par).find("input.curr-meas")[0].value)

set_current_meas = (par, meas) ->
  $(par).find("input.curr-meas")[0].value = meas

get_chart = (charts, sel) ->
  for c in charts
    if c.connection == sel
      return c

register_events = () ->
  $("i.activities-left-arrow").click (evt) ->
    par = evt.currentTarget.parentNode.parentNode.parentNode.parentNode
    activity_conn =  $(par).find("input.connection-name")[0].value
    chart = get_chart(self.activity_charts, activity_conn)
    if is_weekly(par)
      curr = get_curr_date(par)
      date = curr.getDate()
      curr.setDate(date-7)
      chart.update_weekly(fmt(curr))
      $("#"+activity_conn+"-container svg.activity-chart-svg").empty()
      chart.draw(curr, get_current_meas(par))
    else
      curr = get_curr_date(par)
      curr.setDate(curr.getDate()-1)
      chart.update_daily(fmt(curr))
      $("#"+activity_conn+"-container svg.activity-chart-svg").empty()
      chart.draw(curr, get_current_meas(par))
    chart.show_selection()
    trend_chart = get_chart(self.trend_charts, activity_conn)
    trend_chart.show_curr_week(curr)

  $("i.activities-right-arrow").click (evt) ->
    par = evt.currentTarget.parentNode.parentNode.parentNode.parentNode
    activity_conn =  $(par).find("input.connection-name")[0].value
    chart = get_chart(self.activity_charts, activity_conn)
    if is_weekly(par)
      curr = get_curr_date(par)
      date = curr.getDate()
      curr.setDate(date+7)
      chart.update_weekly(fmt(curr))
      $("#"+activity_conn+"-container svg.activity-chart-svg").empty()
      chart.draw(curr, get_current_meas(par))
    else
      curr = get_curr_date(par)
      curr.setDate(curr.getDate()+1)
      chart.update_daily(fmt(curr))
      $("#"+activity_conn+"-container svg.activity-chart-svg").empty()
      chart.draw(curr, get_current_meas(par))
    chart.show_selection()
    trend_chart = get_chart(self.trend_charts, activity_conn)
    trend_chart.show_curr_week(curr)

  $("span.today-button").click (evt) ->
    par = evt.currentTarget.parentNode.parentNode.parentNode
    activity_conn =  $(par).find("input.connection-name")[0].value
    chart = get_chart(self.activity_charts, activity_conn)
    $("#"+activity_conn+"-container svg.activity-chart-svg").empty()
    today = new Date(Date.now())
    chart.update_daily(fmt(today))
    chart.draw(today, get_current_meas(par))
    chart.show_selection()
    trend_chart = get_chart(self.trend_charts, activity_conn)
    currdate = get_curr_date(par)
    trend_chart.show_curr_week(currdate)

  $("span.week-button").click (evt) ->
    par = evt.currentTarget.parentNode.parentNode.parentNode
    activity_conn =  $(par).find("input.connection-name")[0].value
    chart = get_chart(self.activity_charts, activity_conn)
    currdate = get_curr_date(par)
    chart.update_weekly(currdate)

  $("div.steps").click (evt) ->
    par = evt.currentTarget.parentNode.parentNode.parentNode.parentNode
    activity_conn =  $(par).find("input.connection-name")[0].value
    set_selected(evt)
    set_current_meas(par, "walking")
    curr = get_curr_date(par)
    $("#"+activity_conn+"-container svg.activity-chart-svg").empty()
    $("#"+activity_conn+"-container svg.activity-trend-svg").empty()
    chart = get_chart(self.activity_charts, activity_conn)
    chart.draw(curr, get_current_meas(par))
    trend_chart = get_chart(self.trend_charts, activity_conn)
    trend_chart.draw(curr, get_current_meas(par))

  $("div.km-running").click (evt) ->
    par = evt.currentTarget.parentNode.parentNode.parentNode.parentNode
    activity_conn =  $(par).find("input.connection-name")[0].value
    set_selected(evt)
    set_current_meas(par, "running")
    curr = get_curr_date(par)
    $("#"+activity_conn+"-container svg.activity-chart-svg").empty()
    $("#"+activity_conn+"-container svg.activity-trend-svg").empty()
    chart = get_chart(self.activity_charts, activity_conn)
    chart.draw(curr, get_current_meas(par))
    trend_chart = get_chart(self.trend_charts, activity_conn)
    trend_chart.draw(curr, get_current_meas(par))

  $("div.km-cycling").click (evt) ->
    par = evt.currentTarget.parentNode.parentNode.parentNode.parentNode
    activity_conn =  $(par).find("input.connection-name")[0].value
    set_selected(evt)
    set_current_meas(par, "cycling")
    curr = get_curr_date(par)
    $("#"+activity_conn+"-container svg.activity-chart-svg").empty()
    $("#"+activity_conn+"-container svg.activity-trend-svg").empty()
    chart = get_chart(self.activity_charts, activity_conn)
    chart.draw(curr, get_current_meas(par))
    trend_chart = get_chart(self.trend_charts, activity_conn)
    trend_chart.draw(curr, get_current_meas(par))

set_selected = (evt) ->
  clicked_block = evt.toElement.parentNode
  $("div.meas-block").removeClass("selected")
  clicked_block.classList.add("selected")

@load_activity_types = () ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load activity types"
  $.ajax '/activity_types.json?category=sport',
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load activity_types AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load activity_types  Successful AJAX call"

      activities = data.map( window.activity_map_fn )

      $("#activityname").autocomplete({
        minLength: 0
        source: (request, response) ->
          matcher = new RegExp($.ui.autocomplete.escapeRegex(remove_accents(request.term), ""), "i")
          result = []
          cnt = 0
          for element in activities
            if matcher.test(remove_accents(element.label))
              result.push(element)
              cnt += 1
            if cnt >= 20
              break
          response(result)
        select: (event, ui) ->
          $("#activity_type_id").val(ui.item.id)
          $("#activity_scale" ).slider({
            value: "2"
          })
          $("#activity_percent").text("2")
      }).focus ->
        $(this).autocomplete("search")

@load_other_activity_types = () ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load other activity types"
  $.ajax '/activity_types.json?category=other',
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load other activity_types AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load other activity_types  Successful AJAX call"

      activities = data.map( window.activity_map_fn )

      $("#otheractivityname").autocomplete({
        minLength: 0
        source: (request, response) ->
          matcher = new RegExp($.ui.autocomplete.escapeRegex(remove_accents(request.term), ""), "i")
          result = []
          cnt = 0
          for element in activities
            if matcher.test(remove_accents(element.label))
              result.push(element)
              cnt += 1
            if cnt >= 20
              break
          response(result)
        select: (event, ui) ->
          $("#activity_other_type_id").val(ui.item.id)
          $("#activity_other_scale" ).slider({
            value: "2"
          })
          $("#activity_other_percent").text("2")
      }).focus ->
        $(this).autocomplete("search")

@analytics_loaded = () ->
  self = this
  uid = $("#current-user-id")[0].value

  if $("#selected-user-id").length >0
    suid = $("#selected-user-id")[0].value
    if suid && suid != ''
      uid = suid

  $("div.appMenu button").removeClass("selected")
  $("#analytics-link").css
    background: "rgba(240, 108, 66, 0.3)"

  dateToShow = moment().format(moment_datefmt)
  self.timeline = new TimelinePlot(uid, "analysis_data", dateToShow, "Daily timeline", {period: "daily"})
  self.timeline.draw("div.timelineChart")

  user_lang = $("#user-lang")[0].value
  if !user_lang
    user_lang='hu'
  $('#timeline_datepicker').datetimepicker({
    format: 'Y-m-d',
    timepicker: false,
    lang: user_lang,
    onSelectDate: (ct, input) ->
      console.log("timeline date selected")
      self.timeline.update(moment(ct).format(moment_datefmt))
      input.datetimepicker('hide')
    todayButton: true
  })

  d3.json(urlPrefix()+"users/"+uid+"/measurements.json?meas_type=blood_sugar", draw_bg_data)

  measStartDate = moment().subtract(6, 'months').format(moment_datefmt)
  meas_summary_url = "users/" + uid + "/measurements.json?summary=true&start="+measStartDate
  d3.json(urlPrefix()+meas_summary_url, draw_health_trend)

  startDate = moment().subtract(12, 'months').format(moment_datefmt)
  d3.json(urlPrefix()+"users/"+uid+"/summaries.json?bysource=true&start="+startDate, draw_patient_activity_data)


@draw_bg_data = (jsondata) ->
  data = {}
  grp_map = {}
  grp_map[48] = "Unspecified"
  grp_map[58] = "Pre Breakfast"
  grp_map[60] = "Pre Lunch"
  grp_map[62] = "Pre Supper"
  data['blood_glucose'] = $.map(jsondata, (d) ->
    return {date: d.date, value: d.blood_sugar, group: grp_map[d.blood_sugar_time]}
  )

  chartParams = {
    rightLabel: "mmol/L"
  }
  bg_trend_chart = new LineChart("bg-container", data, chartParams)
#  bg_extent = bg_trend_chart.get_time_extent()
#  higlight_extents = getExtentsMiddle(bg_extent)
  bg_trend_chart.draw()
#  if jsondata && jsondata.size>0
#    bg_trend_chart.add_highlight(higlight_extents[0], higlight_extents[1], "selA")
#    bg_trend_chart.add_highlight(higlight_extents[1], higlight_extents[2], "selB")


@draw_health_trend = (data) ->
#  heart_trend_chart = new TrendChart("heart-trend", data,
#    ["systolicbp", "pulse", "diastolicbp"],
#    ["SYS", "HR", "DIA"],
#    ["left", "right", "left"]
#    ["colset4_0", "colset4_1", "colset4_2"],
#    ["mmHg", "1/min"],
#    false
#  )
#  heart_trend_chart.margin = {top: 20, right: 45, bottom: 20, left: 30}
#  heart_trend_chart.draw()
  convert = (raw) ->
    sys = []
    dia = []
    pulse = []
    raw.forEach( (d) ->
      if d.systolicbp && d.systolicbp>0
        sys.push({date: d.date, value: d.systolicbp, group: "sys"})
      if d.diastolicbp && d.diastolicbp>0
        dia.push({date: d.date, value: d.diastolicbp, group: "dia"})
      if d.pulse && d.pulse>0
        pulse.push({date: d.date, value: d.pulse, group: "pulse"})
    )
    return {sys: sys, dia: dia, pulse: pulse}

  heartData = convert(data)
  console.log("HEART DATA", heartData)
  chartParams = {
    leftLabel: "1/min",
    rightLabel: "Hgmm",
    leftGroups: ["pulse"]
  }
  heart_trend_chart = new LineChart("heart-trend-container", heartData, chartParams)
  heart_trend_chart.draw()


@draw_patient_activity_data = (jsondata) ->
  console.log "patient data"
  getters = {
    cycling: (d) ->
      return d.distance
    running: (d) ->
      return d.steps
    walking: (d) ->
      return d.steps
  }
  Object.keys(jsondata).forEach( (src)->
    dev_chart = $("#device-data-template").children().first().clone()
    container_name = src+"_data-container"
    dev_chart.attr("id", container_name)
    $("#analytics-container").append(dev_chart)

    $(dev_chart).find("div.training-type").html(capitalize(src))
    devData = {}
    keys = Object.keys(jsondata[src])
    keys.forEach( (k) ->
      if k!="sleep" && k!="transport"
        grpData = $.map(jsondata[src][k], (d) ->
          return {date: d.date, value: getters[k](d), group: k};
        )
        grpData = grpData.filter((d) -> d.value!=0)

        devData[k] = grpData
    )
    chartParams = {
      leftLabel: "distance(m)",
      rightLabel: "steps",
      leftGroups: ["cycling"]
    }
    graph = new LineChart(container_name, devData, chartParams)
    graph.draw()
  )



@loadStatistics = () ->
  resetMdUI()

  registerLogoutHandler()
  registerLangHandler()

  console.log "md_statistics"
  $("#statistics-link").addClass("menulink-selected")
  define_globals()

  initStatUI()
  loadStatisticsPatients()

  $("section.dataSelect").on("click", "i.showAnalysis", showAnalysis)

  self = this
  @zooming = false
  $("svg.bg-chart-svg").on("click", (evt) ->
    console.log "svg clicked "+self.zooming
    if self.zooming
      return
    self.zooming = !self.zooming
    document.body.style.cursor = 'move'
    if self.lineChart
      self.lineChart.startZoom()
    isClickout = (elem) ->
      curr = elem
      found = false
      while(curr && !found)
        if curr.id == 'overviewChart'
          found = true
        curr = curr.parentElement
      return !found
    $("html").on("click.zooming", (evt) ->
      window.tmptarget = evt.target
      if isClickout(evt.target)
        $("html").unbind("click.zooming")
        self.zooming = false
        if self.lineChart
          self.lineChart.endZoom()
        document.body.style.cursor = 'auto'
    )
  )


@initStatUI = () ->
  self = this
  measList = [
    { label: "blood_glucose", value: "blood_sugar" },
    { label: "systolic", value: "systolic" },
    { label: "diastolic", value: "diastolic" },
    { label: "pulse", value: "pulse" }
  ]
  $('input[name=attributeName]').autocomplete({
    minLength: 0,
    source: measList,
    change: (event, ui) ->
      measSelected = ui['item']
    select: (event, ui) ->

      measureSelected(ui['item'].value)
  }).focus ->
    $(this).autocomplete("search")

  $('input[name=startA]').datetimepicker({
    format: 'Y-m-d',
    timepicker: false
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
      self.updateHighlight()
    todayButton: true
  })
  $('input[name=endA]').datetimepicker({
    format: 'Y-m-d',
    timepicker: false
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
      self.updateHighlight()
    todayButton: true
  })
  $('input[name=startB]').datetimepicker({
    format: 'Y-m-d',
    timepicker: false
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
      self.updateHighlight()
    todayButton: true
  })
  $('input[name=endB]').datetimepicker({
    format: 'Y-m-d',
    timepicker: false
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
      self.updateHighlight()
    todayButton: true
  })

@loadStatisticsPatients = () ->
  $.ajax urlPrefix()+'/users.json',
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load patients AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load patients  Successful AJAX call"
      #      console.log data
      $(".patientName").autocomplete({
        minLength: 0,
        source: (request, response) ->
          console.log request
          matcher = new RegExp($.ui.autocomplete.escapeRegex(remove_accents(request.term), ""), "i")
          result = []
          cnt = 0
          for element in data
            if matcher.test(remove_accents(element.name))
              result.push({label: element.name, value: element.name, obj: element})
              cnt += 1
          response(result)
        select: (event, ui) ->
          patientSelected(ui.item.obj.id)

#          $("#patientName").html( ui.item.label.trim() )

#          $("input[name=patientId]").val(ui.item.obj.id)
#          $("#headerItemAvatar").attr( "src", ui.item.obj.avatar_url )
#          $("#patientHeader").removeClass("hidden")
#          $(".patientData").removeClass("hidden")
#          $("#patientHeader").tooltip({
#            items: "img",
#            content: '<img src="'+ui.item.obj.avatar_url+'" />'
#          })
#          initStatistics()
#          uid = ui.item.obj.id
#          console.log "loadBgData for "+uid
#          loadBgData(uid)


        create: (event, ui) ->
#          document.body.style.cursor = 'auto'
          $(".patientName").removeAttr("disabled")
        change: (event, ui) ->
          console.log "change"
      }).focus ->
        $(this).autocomplete("search")

@patientSelected = (uid) ->
  console.log "patientSelected "+uid
  $(".patientId").val(uid)
  $(".patientSelectDone").removeClass("grayed")

  $(".attrSelect").removeClass("grayed")
  $(".attrSelect").removeAttr("disabled")

@measureSelected = (measure) ->
  console.log measure
  $("div.stat-container").addClass("hidden")
  $("div.stat-chart").html("")
  uid = $(".patientId").val()
  $(".measureName").val(measure)
  initStatistics()
  meas = "blood_pressure"
  if measure == "blood_sugar"
    meas = "blood_sugar"

  loadBgData(uid, meas)

@loadBgData = (uid, measure) ->
  d3.json(urlPrefix()+"/users/"+uid+"/measurements.json?meas_type="+measure, statBgDdataReceived)

@getMeasGroup = (d) ->
  ret = "unspecified"
  if moment(d).hour() >= 5 && moment(d).hour() <= 10
    ret = "breakfast"
  else if moment(d).hour() >= 10 && moment(d).hour() <= 14
    ret = "lunch"
  else if moment(d).hour() >= 18 && moment(d).hour() <= 22
    ret = "dinner"
  return ret

@getBgGroup = (d) ->
  lbMap = {
    '48': 'Unspecified',
    '57': 'Unspecified2',
    '58': 'Pre Breakfast',
    '59': 'Post Breakfast',
    '60': 'Pre Lunch',
    '61': 'Post Lunch',
    '62': 'Pre Supper',
    '63': 'Post Supper',
    '64': 'Pre Snack'
  }
  return lbMap[d]
@mapDia = (d) ->
  return( {date: d.date, value: d.diastolicbp, group: getMeasGroup(d.date)})
@mapSys = (d) ->
  return( {date: d.date, value: d.systolicbp, group: getMeasGroup(d.date)})
@mapPulse = (d) ->
  return( {date: d.date, value: d.pulse, group: getMeasGroup(d.date)})
@mapBG = (d) ->
  return( {date: d.date, value: d.blood_sugar, group: getBgGroup(d.blood_sugar_time)})

@sortData = (data) ->
  data.sort( (a, b) ->
    if a.date<b.date
      return -1
    if a.date>b.date
      return 1
    return 0
  )
@getSummary = (data) ->
  return {length: data.length, from: data[0].date, to: data[data.length-1].date, mean: calcMean(data)}

@showSummary = (meas, summary) ->
  from = moment(summary.from).format(moment_fmt)
  to = moment(summary.to).format(moment_fmt)
  $(".allDataChart").html("<div class='training-type left'><i class='fa fa-bar-chart fa-2x'></i>"+meas+" Interval: "+from+" to "+to+" Data points: "+summary.length+" Mean: "+summary.mean.toFixed(2)+"</div><div class='selected-meas legend-container right'></div>")

@updateHighlight = () ->
  self = this
  console.log "updatehighlight"
  if self.lineChart && self.lineChart.chartData
    console.log "updating"
    self.lineChart.clearHighlights()
    self.lineChart.addHighlight($('input[name=startA]').val(), $('input[name=endA]').val(), 'selA')
    self.lineChart.addHighlight($('input[name=startB]').val(), $('input[name=endB]').val(), 'selB')

@getExtentsMiddle = (ext) ->
  f = moment(ext[0])
  t = moment(ext[1]).add(1, 'days')
  d = t.diff(f, 'days')
  m = moment(f).add(d/2, 'days')
  return [[f.format(moment_datefmt), m.format(moment_datefmt)], [m.format(moment_datefmt), t.format(moment_datefmt)]]

@getSel = (name) ->
  ".dataSelect input[name='"+name+"']"

@statBgDdataReceived = (jsonData) ->
  console.log "stat bg_data_received, size="+jsonData.length
  console.log jsonData[0]
  @currdata = jsonData
  if jsonData && jsonData.length>0
    $("section.sectionPatients").removeClass("hidden")
    meas = $(".measureName").val()

    $("#bg-container svg.bg-chart-svg").html("")

    sortData(jsonData)

    if meas=="blood_sugar"
      chartData = jsonData.map(  mapBG ).filter( (d) -> d.value>0 )
      yaxisTitle = "BG (mmol/L)"
      measName = "Blood glucose"
    else if meas=="systolic"
      chartData = jsonData.map(  mapSys ).filter( (d) -> d.value>0 )
      yaxisTitle = "SYS (mmHg)"
      measName = "Systolic blood pressure"
    else if meas=="diastolic"
      chartData = jsonData.map(  mapDia ).filter( (d) -> d.value>0 )
      yaxisTitle = "DIA (mmHg)"
      measName = "Diastolic blood pressure"
    else if meas=="pulse"
      chartData = jsonData.map(  mapPulse ).filter( (d) -> d.value>0 )
      yaxisTitle = "Pulse (1/min)"
      measName = "Pulse"

    window.chartData = chartData
    summary = getSummary(chartData)
    showSummary( measName, summary )
    setTimeout(() ->
      console.log("legend: ",$(".chart-legend"))
      data = {}
      data[meas] = chartData
      @lineChart = new ZoomableLineChart("bg-container", data, yaxisTitle)

      @lineChart.draw()
      highlight_extents = getExtentsMiddle(@lineChart.timeExtent)

      $(getSel("startA")).val(highlight_extents[0][0])
      $(getSel("endA")).val(highlight_extents[0][1])
      $(getSel("startB")).val(highlight_extents[1][0])
      $(getSel("endB")).val(highlight_extents[1][1])
      $(getSel("startA")).removeAttr("disabled")
      $(getSel("endA")).removeAttr("disabled")
      $(getSel("startB")).removeAttr("disabled")
      $(getSel("endB")).removeAttr("disabled")
      $(".dataSelect i.showChart").removeAttr("disabled")
      updateHighlight()

      $(".dataSelect li.attrSelectDone").removeClass("grayed")
      $(".dataSelect li.aSelect").removeClass("grayed")
      $(".dataSelect li.sSelectDone").removeClass("grayed")
      $(".dataSelect li.bSelect").removeClass("grayed")
      $(".dataSelect li.showChart").removeClass("grayed")
    ,0)

@showAnalysis = (evt) =>
  console.log("add analysis clicked")
  if !@lineChart
    return

  rangeA = [$(getSel("startA")).val(), $(getSel("endA")).val()]
  rangeB = [$(getSel("startB")).val(), $(getSel("endB")).val()]
  console.log rangeA
  console.log rangeB

  eid = "stat-chart"
  $(".statHeader div.title").html("Statistics")

  $("div."+eid).html("")

  axisLabels = {
    blood_sugar: "BG (mmol/L)",
    systolic: "SYS (mmHg)",
    dioastolic: "DIA (mmHg)",
    pulse: "Pulse (1/min)",
  }
  keys = Object.keys(@lineChart.chartData)
  pp = new ParallelPlot(eid, @lineChart.chartData[keys[0]], axisLabels[$("section.dataSelect input[name=attributeName]").val()])
  pp.draw(rangeA, rangeB)

  console.log("Ranges:")
  console.log rangeA
  console.log rangeB
  draw_boxplot(eid, @lineChart.chartData[keys[0]], rangeA, rangeB, @lineChart.colorMap)

  $("div.stat-container").removeClass("hidden")

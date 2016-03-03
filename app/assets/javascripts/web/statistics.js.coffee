@analytics2_loaded = () ->
  self = this
  uid = $("#current-user-id")[0].value

  initStatistics()

  d3.json(urlPrefix()+"users/"+uid+"/measurements.json?meas_type=blood_sugar", bg_data_received)

  $(document).unbind("click.closeStat")
  $(document).on("click.closeStat", "#closeModalStat", (evt) ->
    location.href = "#close"
  )

  $(document).unbind("click.addAnalysis")
  $(document).on("click.addAnalysis", "#add-analysis", (evt) ->
    if self.currdata
      a = new Date(self.currextent[0])
      b = new Date(self.currextent[1])

      diff = moment(a).diff(moment(b))
      mid = moment(moment(a)-diff/2).format("YYYY-MM-DD")

      $("#bg_from").html(fmt(a))
      $("#bg_to").html(fmt(b))

      $("#start_a").datetimepicker({value: moment(a).format("YYYY-MM-DD")})
      $("#end_a").datetimepicker({value: mid})
      $("#start_b").datetimepicker({value: mid})
      $("#end_b").datetimepicker({value: moment(b).format("YYYY-MM-DD")})

      self.update_elements()

      location.href = "#openModalStat"
  )

  $(document).unbind("click.analysisParams")
  $(document).on("click.analysisParams", "#analysis-params", (evt) ->
    console.log("add analysis clicked")
    if !self.bg_trend_chart
      return

    data = self.bg_trend_chart.data

    rangeA = [$("#start_a").val(), $("#end_a").val()]
    rangeB = [$("#start_b").val(), $("#end_b").val()]
    self.bg_trend_chart.add_highlight(rangeA[0], rangeA[1], "selA")
    self.bg_trend_chart.add_highlight(rangeB[0], rangeB[1], "selB")

    location.href = "#close"

    eid = "stat-"+self.statnum+"-container"
    self.statnum = self.statnum+1
    h = $("#stat-template").clone()
    window.h = h
    h.attr('id', eid)
    h.prependTo("#allstats")

    $("#"+eid+" div.title").html($("#title").val())
    draw_boxplot(eid, data, rangeA, rangeB)
    draw_parallelplot(eid, data, rangeA, rangeB)
  )

@initStatistics = () ->
  console.log("statistics init")
  @margin = {top: 30, right: 40, bottom: 55, left: 40}

  @currdata = null
  @currextent = null
  @statnum = 1

  @lbMap = {
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

  @color_map = {}
  @color_map[48] = "bg1Point"
  @color_map[58] = "bg2Point"
  @color_map[60] = "bg3Point"
  @color_map[62] = "bg4Point"

  @base_r = 4

  @calc_n_ab = () ->
    self = this
    start_a = moment($("#start_a").val()).toDate()
    end_a = moment($("#end_a").val()).toDate()
    start_b = moment($("#start_b").val()).toDate()
    end_b = moment($("#end_b").val()).toDate()
    a = 0
    b = 0
    for dd in self.currdata
      currdate = new Date(dd.date)
      if currdate >=start_a && currdate <end_a
        a = a + 1
      if currdate >=start_b && currdate <end_b
        b = b + 1
    return [a, b]

  @update_elements = () ->
    arr = self.calc_n_ab()
    $("#num_a").html(arr[0])
    $("#num_b").html(arr[1])

  $('#start_a').datetimepicker({
    format: 'Y-m-d',
    timepicker: false
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
      self.update_elements()
    todayButton: true
  })
  $('#end_a').datetimepicker({
    format: 'Y-m-d',
    timepicker: false
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
      self.update_elements()
    todayButton: true
  })
  $('#start_b').datetimepicker({
    format: 'Y-m-d',
    timepicker: false
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
      self.update_elements()
    todayButton: true
  })
  $('#end_b').datetimepicker({
    format: 'Y-m-d',
    timepicker: false
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
      self.update_elements()
    todayButton: true
  })
  $('.xdsoft_datetimepicker').css('zIndex', 999999);

#@stat_bg_data_received = (jsondata) ->
#  console.log "stat bg_data_received, size="+jsondata.length
#  @currdata = jsondata
#  if jsondata && jsondata.length>0
#    @currextent = d3.extent(jsondata, (d) -> d.date)
#    @bg_trend_chart = new BGChart("bg", jsondata, 1.0/8)
#    @bg_trend_chart.draw()

@draw_parallelplot = (eid, data, rangeA, rangeB) ->
  self = this
  colorMap = getColorMap(data)
  parDataA = {}
  parDataB = {}
  dotData = []
  data.forEach( (d)->
    selData = null
    dd = new Date(d.date)
    if(dd>= new Date(rangeA[0]) && dd < new Date(rangeA[1]))
      selData = parDataA
    if(dd>= new Date(rangeB[0]) && dd < new Date(rangeB[1]))
      selData = parDataB

    if( selData )
      dd = new Date(d.date)
      t = fmt(dd)
      dd.setYear(2015)
      dd.setMonth(0)
      dd.setDate(0)
      item = {date: fmt_hms(dd), value: d.value, group: d.group}
      if(!selData[t])
        selData[t] = [item]
      else
        selData[t].push(item)
      dotData.push(item)
  )

  width = $("#"+eid).parent().width()/2
  height = width*2.0/7.0

  svg = d3.select("#"+eid+" > div")
    .append("svg")
    .attr("class", "box")
    .attr("width", width )
    .attr("height", height )
  dwg = svg
    .append("g")
    .attr("transform", "translate(" + self.margin.left + "," + self.margin.top + ")")

  arr = []
  for k in Object.keys(parDataA)
    for currd in parDataA[k]
      arr.push(currd.date)
  for k in Object.keys(parDataB)
    for currd in parDataB[k]
      arr.push(currd.date)

  time_extent = d3.extent(arr, (d) -> new Date(d) )
  d1 = time_extent[0]
  d2 = time_extent[1]
  d1.setHours(0)
  d1.setMinutes(0)
  d2.setHours(23)
  d2.setMinutes(59)
  time_extent[0] = d1
  time_extent[1] = d2

  time_scale = d3.time.scale().domain(time_extent).range([0, width-self.margin.left-self.margin.right])

  bg_extent = d3.extent(data, (d) -> d.value)
  scale_left = d3.scale.linear().range([height - self.margin.bottom- self.margin.top, 0]).domain(bg_extent)

  bgline = d3.svg.line()
    .x( (d) -> return(time_scale(new Date(d.date))))
    .y( (d) -> return(scale_left(d.value)))

  for k in Object.keys(parDataA)
    dwg.append("path")
      .datum(parDataA[k])
      .attr("class", "pplineA")
      .attr("d", bgline)

  for k in Object.keys(parDataB)
    dwg.append("path")
      .datum(parDataB[k])
      .attr("class", "pplineB")
      .attr("d", bgline)

  dwg.selectAll("circle.bg")
      .data(dotData)
      .enter()
      .append("circle")
        .attr("cx", (d) -> time_scale(new Date(d.date)))
        .attr("cy", (d) -> scale_left(d.value))
        .attr("r", self.base_r)
        .attr("class", (d) -> colorMap[d.group])

  xAxis = d3.svg.axis()
    .scale(time_scale)
    .orient("bottom")
    .tickFormat(d3.time.format("%H:%m"))

  yAxis = d3.svg.axis()
    .scale(scale_left)
    .orient("left")

  # draw y axis
  dwg.append("g")
    .attr("class", "y axis")
    .call(yAxis)
    .append("text")
    .attr("transform", "rotate(-90)")
    .attr("y", 6)
    .attr("dy", ".71em")
    .style("text-anchor", "end")
    .style("font-size", "16px")
    .text("BG (mmol/L)");

  # draw x axis
  dwg.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0," + ( height-self.margin.bottom) + ")")
    .call(xAxis)
      .append("text")
      .attr("x", (width / 2) )
      .attr("y",  -20 )
      .attr("dy", ".71em")
      .style("text-anchor", "middle")
      .style("font-size", "16px")
      .text("Time of Day");

@draw_boxplot = (eid, data, rangeA, rangeB, colorMap) ->
  self = this
  minv = Infinity
  maxv = -Infinity
  boxDataA = {}
  boxDataB = {}

  console.log("draw_boxplot", data)
#  colorMap = getColorMap(data);

#  console.log data[0]
  data.forEach( (d)->
    if d.value > maxv
      maxv = d.value
    if d.value < minv
      minv = d.value
    t = d.group
    selData = null

    dd = new Date(d.date)
    if(dd>= new Date(rangeA[0]) && dd < new Date(rangeA[1]))
      selData = boxDataA
    if(dd>= new Date(rangeB[0]) && dd < new Date(rangeB[1]))
      selData = boxDataB
    if( selData )
      if(!selData[t])
        selData[t] = [d.value]
      else
        selData[t].push(d.value)
  )
  boxDataArrA = []
  boxDataArrB = []
  Object.keys(boxDataA).forEach( (d) ->
    tmp = [d]
    tmp.push(boxDataA[d])
    boxDataArrA.push(tmp)
  )
  Object.keys(boxDataB).forEach( (d) ->
    tmp = [d]
    tmp.push(boxDataB[d])
    boxDataArrB.push(tmp)
  )

  width = $("div."+eid).parent().parent().parent().width()/2
  height = width*3.0/7.0

  chart = d3.box()
    .whiskers(iqr(1.5))
    .width(width-self.margin.left-self.margin.right)
    .height(height-self.margin.top-self.margin.bottom)
    .domain([minv, maxv])
    .showLabels(true)
    .tickFormat(d3.format(",.02f"))

  chartRL = d3.box()
    .whiskers(iqr(1.5))
    .width(width-self.margin.left-self.margin.right)
    .leftLabel(true)
    .height(height-self.margin.top-self.margin.bottom)
    .domain([minv, maxv])
    .showLabels(true)
    .tickFormat(d3.format(",.02f"))

  bpWidth = 20
  bpHeight = 420
  #(width-margin.left-margin.right)/boxDataArr.length

  svg = d3.select("div."+eid)
    .append("svg")
    .attr("class", "box")
    .attr("width", width )
    .attr("height", height )
  dwg = svg
    .append("g")
    .attr("transform", "translate(" + self.margin.left + "," + self.margin.top + ")")

  x = d3.scale.ordinal()
    .domain(  boxDataArrA.concat(boxDataArrB).map( (d) -> return d[0]  )  )
    .rangeRoundBands([0 , width], 0.7, 0.3)

  xAxis = d3.svg.axis()
    .scale(x)
    .orient("bottom");

  y = d3.scale.linear()
    .domain([minv, maxv])
    .range([height-self.margin.top-self.margin.bottom, 0])

  yAxis = d3.svg.axis()
    .scale(y)
    .orient("left")

  barwidth = x.rangeBand()/3.0
  console.log "barwidht = "+barwidth
  window.barwidht = barwidth

  dwg.selectAll("g.boxA")
    .data(boxDataArrA)
    .enter()
    .append("g")
    .attr("class","boxA")
    .attr("transform", (d) -> return "translate(" +  x(d[0])  + "," + 0 + ")"  )
    .call(chart.width(barwidth))

  dwg.selectAll("g.boxB")
    .data(boxDataArrB)
    .enter()
    .append("g")
    .attr("class","boxB")
    .attr("transform", (d) -> return "translate(" +  (x(d[0])+30)  + "," + 0 + ")"  )
    .call(chartRL.width(barwidth))

  # draw y axis
  dwg.append("g")
    .attr("class", "y axis")
    .call(yAxis)
    .append("text")
    .attr("transform", "rotate(-90)")
    .attr("y", 6)
    .attr("dy", ".71em")
    .style("text-anchor", "end")
    .style("font-size", "16px")
    .text("BG (mmol/L)");

  # draw x axis
  dwg.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0," + ( height-self.margin.bottom) + ")")
    .call(xAxis)
    .append("text")
    .attr("x", (width / 2) )
    .attr("y",  -20 )
    .attr("dy", ".71em")
    .style("text-anchor", "middle")
    .style("font-size", "16px")
    .text("Measurement");


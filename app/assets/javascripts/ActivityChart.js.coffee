#= require BaseChart

class ActivityChart extends BaseChart
  constructor: (@chart_element, data, @data_helper) ->
    super(data)
    @time_scale = null
    @callback = null

  draw: (date, meas) ->
    self = this
    date_ymd = @data_helper.fmt(date)
    console.log "draw_activity_chart "+date_ymd+" -> "+meas
    $("#moves-group input.curr-date")[0].value = date_ymd

    currdata = @data_helper.get_week_activities(date_ymd)
    console.log currdata
    margin = {top: 30, right: 10, bottom: 40, left: 50}
    aspect = 400/700
    width = $("#moves-chart").parent().width()-margin.left-margin.right
    @height = aspect*width-margin.top-margin.bottom
    barwidth = width/14.0

    showdata = currdata.walking
    if meas=="running"
      showdata = currdata.running
    else if meas=="cycling"
      showdata = currdata.cycling

    if showdata.length==0
      console.log "no data"

    svg = d3.select($("#moves-chart-svg")[0])
    svg = svg
      .attr("width", width+margin.left+margin.right)
      .attr("height", self.height+margin.top+margin.bottom)
      .append("g")
      .attr("transform", "translate("+margin.left+","+margin.top+")")

    if showdata.length==0
      console.log "no data"
      svg.append("text")
      .text("No data!")
      .attr("class", "warn")
      .attr("x", width/2-margin.left)
      .attr("y", self.height/2)

    time_padding = 8*60*60*1000
    time_extent = [@data_helper.get_monday(date_ymd).getTime()-time_padding, @data_helper.get_sunday(date_ymd).getTime()-time_padding]
    console.log date_ymd
    console.log "draw_activity_chart time extent="+ new Date(time_extent[0])+" - "+ new Date(time_extent[1])
    console.log "monday="+@fmt(new Date(@data_helper.get_monday(date_ymd).getTime()-time_padding))
    @time_scale = d3.time.scale().domain(time_extent).range([0, width])

    if meas=='walking'
      x_getter = (d) -> d.steps
    else
      x_getter = (d) -> d.distance

    y_extent = d3.extent( showdata, x_getter )
    y_extent[0] = 0
    y_scale = d3.scale.linear().domain(y_extent).range([self.height, 0])


    svg
      .selectAll("rect."+meas)
      .data(showdata)
      .enter()
      .append("rect")
      .attr("class", meas)
      .attr("x", (d) -> self.time_scale(Date.parse(d.date))-barwidth/2)
      .attr("width", (d) -> barwidth)
      .attr("y", (d) -> y_scale(x_getter(d)))
      .attr("height", (d) -> self.height-y_scale(x_getter(d)))

    time_axis = d3.svg.axis()
      .scale(self.time_scale)
      .tickSize(8, 0)
      .ticks(d3.time.days)
    svg
      .append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0 ,"+self.height+")")
      .call(time_axis)
    svg.
      select(".x.axis")
      .append("text")
      .text("Date")
      .attr("x", (width / 2) - margin.right)
      .attr("y", margin.bottom / 1.2);

    if meas=='walking'
      y_axis_steps = d3.svg.axis()
      .scale(y_scale)
      .orient("left")
      svg
      .append("g")
      .attr("class", "y axis steps")
      .attr("transform", "translate(0, 0)")
      .call(y_axis_steps)
      svg.select(".y.axis.steps")
      .append("text")
      .text("Distance (steps)")
      .attr("x", -30)
      .attr("y", -10)
    else
      y_axis_km = d3.svg.axis()
      .scale(y_scale)
      .orient("left")
      svg
      .append("g")
      .attr("class", "y axis km")
      .attr("transform", "translate(0, 0)")
      .call(y_axis_km)
      svg.select(".y.axis.km")
      .append("text")
      .text("Distance (km)")
      .attr("x", -20)
      .attr("y", -10)

    d3.selectAll("rect")
    .on("mouseover", (d) ->
      d3.select(this)
      .classed("selected", true)

      act_date =  self.data_helper.fmt_day(new Date(Date.parse(d.date)))
      act_type = d.group
      if act_type == "walking"
        act_value = d.steps.toString() + " steps"
      else
        act_value = (d.distance).toString()+" km"
      d3.select("#training-detail").html(act_date+" "+act_type+" "+act_value)

    ).on("mouseout", (d) ->
      d3.select(this)
      .classed("selected", false)
      d3.select("#training-detail").html("")
    ).on("click", (d) ->
      sel_date = self.data_helper.fmt(new Date(Date.parse(d.date)))
      self.update_daily(sel_date)
      $("#moves-group input.curr-date")[0].value = sel_date
      self.show_selection()
      if self.callback
        self.callback(d)
    )

  set_callback: (cb) ->
    @callback = cb

  show_selection: ->
    currdate = Date.parse($("#moves-group input.curr-date")[0].value)
    console.log "show selection " + currdate

    self = this
    svg = d3.select($("#moves-chart-svg g:first-child")[0])
    d3.selectAll($("#moves-chart-svg line.sel")).remove()
    svg.insert("line", ":first-child")
      .attr("class", "sel")
      .attr("x1", self.time_scale(currdate))
      .attr("y1", -10)
      .attr("x2", self.time_scale(currdate))
      .attr("y2", self.height)

  update_daily: (sel_date) ->
    $("#moves-group input.is-weekly")[0].value = ""
    today = @data_helper.fmt(new Date(Date.now()))
    if today==sel_date
      $("#moves-chart-date").html("Today")
    else
      $("#moves-chart-date").html(@data_helper.fmt_words(new Date(Date.parse(sel_date))))
    daily = @data_helper.get_daily_activities(sel_date)
    $("#moves-group div.steps").html(@data_helper.get_sum_measure(daily, 'steps', ['walking']))
    $("#moves-group div.km-running").html(@data_helper.get_sum_measure(daily, 'distance', ['running']).toFixed(2))
    $("#moves-group div.km-cycling").html(@data_helper.get_sum_measure(daily, 'distance', ['cycling']).toFixed(2))
    $("#moves-group div.calories").html(@data_helper.get_sum_measure(daily, 'calories', ['walking', 'running', 'cycling']))
    $("#moves-group div.distance").html(@data_helper.get_sum_measure(daily, 'distance', ['walking', 'running', 'cycling']).toFixed(2))
    duration_sec = @data_helper.get_sum_measure(daily, 'duration', ['walking', 'running', 'cycling'])
    timestr = @data_helper.get_hour(duration_sec)+"h "+@data_helper.get_min(duration_sec)+"min"
    $("#moves-group div.duration").html(timestr)

  update_weekly: (sel_date) ->
    $("#moves-group input.is-weekly")[0].value = "yes"
    weekly = @data_helper.get_week_activities(sel_date)
    console.log sel_date
    monday =  @data_helper.get_monday(sel_date)
    sunday = @data_helper.get_sunday(sel_date)
    $("#moves-chart-date").html(@data_helper.fmt_words(monday)+" - "+@data_helper.fmt_words(sunday))
    $("#moves-group div.steps").html(@data_helper.get_sum_measure(weekly, 'steps', ['walking']))
    $("#moves-group div.km-running").html(@data_helper.get_sum_measure(weekly, 'distance', ['running']).toFixed(2))
    $("#moves-group div.km-cycling").html(@data_helper.get_sum_measure(weekly, 'distance', ['cycling']).toFixed(2))
    $("#moves-group div.calories").html(@data_helper.get_sum_measure(weekly, 'calories', ['walking', 'running', 'cycling']))
    $("#moves-group div.distance").html(@data_helper.get_sum_measure(weekly, 'distance', ['walking', 'running', 'cycling']).toFixed(2))
    duration_sec = @data_helper.get_sum_measure(weekly, 'duration', ['walking', 'running', 'cycling'])
    timestr = @data_helper.get_hour(duration_sec)+"h "+@data_helper.get_min(duration_sec)+"min"
    $("#moves-group div.duration").html(timestr)

window.ActivityChart = ActivityChart
@admin_loaded = () ->
  console.log "admin loaded"
  url = "pages/traffic"
  $.ajax urlPrefix()+url,
    type: "GET"
    dataType: "json"
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "AJAX Error: #{textStatus}"
    success: (result, textStatus, jqXHR) ->
      console.log "Successful AJAX call"
      if result['status'] == "OK"
        drawTraffic(result)
      else
        console.log "status nok"


  $("form.traffic-form").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    $("#"+form_id+" input.dataFormField").val("")
    if JSON.parse(xhr.responseText).status == "NOK"
      console.log "nok"
    else
      console.log "ok"
      $("#admin-link").addClass("menulink-selected")
      $("#sectionAdmin").removeClass("hiddenSection")
      drawTraffic(data)
      if data.email
        $("#traffic-uinfo p").html(data.email)
      else
        $("#traffic-uinfo p").html("All traffic of site")
  ).on("ajax:error", (e, data, status, xhr) ->
    console.log "err"
  )

  $("#edit-button").click (event) ->
    console.log "edit pressed"

  $("#delete-button").click (event) ->
    console.log "delete pressed"

@drawTraffic = (data) ->
  buckets = 11
  colorScheme = 'rbow2'
  days = [['Monday', 'Mo' ],['Tuesday', 'Tu' ],['Wednesday', 'We' ],['Thursday', 'Th' ],['Friday', 'Fr' ],['Saturday', 'Sa' ],['Sunday', 'Su' ]]
  hours = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23']
  d3.select(("#traffic-vis")).classed(colorScheme, true)
  pdata = JSON.parse(data.data)
  date = new Date(pdata[0][1])
  for i in [0..date.getDay()-2]
    t = days.shift()
    days.push(t)
  for i in [0..6]
    newdate = new Date
    newdate.setDate(newdate.getDate() - (6-i));
    days[i][0] = fmt(newdate) + " "+ days[i][0]
  createTiles(hours,days)
  reColorTiles(buckets, pdata)

@createTiles = (hours, days) ->
  html = '<table id="traffic-tiles" class="front">'
  html += '<tr><th><div>&nbsp;</div></th>'
  for  h in [0..hours.length-1]
    html += '<th class="h' + h + '">' + hours[h] + '</th>'
  html += '</tr>';
  for d in [0..days.length-1]
    html += '<tr class="d' + d + '">'
    html += '<th>' + days[d][0] + '</th>'
    for h in [0..hours.length-1]
      html += '<td id="d' + d + 'h' + h + '" class="d' + d + ' h' + h + '"><div class="tile"><div class="face front"></div><div class="face back"></div></div></td>'
    html += '</tr>'
  html += '</table>'
  d3.select("#traffic-vis").html(html)

@reColorTiles = (buckets, pdata) ->
  calcs = getCalcs(pdata)
  range = []
  for i in [1..buckets]
    range.push(i)
  m = 10
  if calcs[1] > 0
    m = calcs[1]
  bucket = d3.scale.quantize().domain([0, m]).range(range)
  side = d3.select("#traffic-tiles").attr('class')
  j = 0;
  for d in [0..6]
    for h in [0..23]
      sel = '#d' + d + 'h' + h + ' .tile .' + side
      val = pdata[j][2]
      j = j + 1;
      #erase all previous bucket designations on this cell
      for i in [1..buckets]
        cls = 'q' + i + '-' + buckets;
        d3.select(sel).classed(cls, false);
      #set new bucket designation for this cell
      v = 1
      if val > 0
        v = bucket(val)
      cls = 'q' + v + '-' + buckets
      d3.select(sel).classed(cls, true)

@getCalcs = (pdata) ->
  min = 0
  max = 0
  for d in [0..pdata.size]
    tot = pdata[d][2]
    if (tot > max)
      max = tot;
  if max > 100
    max = 100;
  v = 10/max;
  max = max * v;
  return [min, max]


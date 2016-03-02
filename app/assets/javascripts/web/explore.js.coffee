@explore_loaded = () ->
  self = this
  console.log "explore loaded"
  $("#sensorDataTable").on("click", "button.tableControl", show_sensor)
  uid = $("#current-user-id")[0].value
  s = getParameterByName("sid")
  if s!=""
    do_show(uid, s)

@getParameterByName = (name) ->
  name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]")
  regex = new RegExp("[\\?&]" + name + "=([^&#]*)")
  results = regex.exec(location.search)
  if results == null
    return ""
  else
    return decodeURIComponent(results[1].replace(/\+/g, " "))

@show_sensor = (event) ->
  console.log "show: "
  console.log event.currentTarget.id

  arr = event.currentTarget.id.split("-")
  sid = arr[arr.length-1]
  uid = $("#current-user-id")[0].value

  if event.metaKey
    window.open("/users/"+uid+"/sensor_measurements/"+sid+"/edit", "_blank")
    return

  do_show(uid, sid)

@do_show = (uid, sid) ->
  $("div.sensorTable tr").removeClass("selectedRow")
  $("div.sensorTable tr#sensor-meas-"+sid).addClass("selectedRow")

  url = '/users/' + uid + '/sensor_measurements/'+sid+'.json'
  $.ajax urlPrefix()+url,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent activities AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load recent activities  Successful AJAX call"
      console.log textStatus


      $("#sensor-data-group").html(data['group']+" data ("+moment(data['start_time']).format("YYYY-MM-DD hh:mm:ss")+")")
      res = null
      if data['version'] && data['version']=='2.0'
        res = proc_20(data)
      else
        res = proc_old(data, sid)

      rr_data = res[0]
      hr_data = res[1]
      cr_data = res[2]
      speed_data = res[3]
      rr_chart = new RRChart("sensordata", rr_data, hr_data, cr_data, speed_data)
      # rr_chart.margin = {top: 20, right: 50, bottom: 20, left: 35}
      rr_chart.draw()

@proc_20 = (data) ->
#  window.tmpdata = data
  for sens in data['sensor_data']
    if sens['sensor_type'] == 'HEART'
      hr_data = []
      rr_data = []
      for seg in sens['sensor_segments']
        hr_values = decodeSensorTimeVal(seg['data_a'])
        curr = Date.parse(seg['start_time'])
        for i in [0..hr_values.length-1]
          if i % 2 == 0
            curr += hr_values[i]
          else
            hr_data.push({time: curr, value: hr_values[i]})

        rr_values = decodeSensorTimeVal(seg['data_b'])
        curr = Date.parse(seg['start_time'])
        for i in [0..rr_values.length-1]
          if i % 2 == 0
            curr += rr_values[i]
          else
            rr_data.push({time: curr, value: rr_values[i]})

    if sens['sensor_type'] == 'BIKE'
      cr_values = []
      cr_data = []
      speed_data = []
      for seg in sens['sensor_segments']
        if seg['data_a']
          cr_values = decodeSensorTimeVal(seg['data_a'])

        curr = Date.parse(seg['start_time'])
        cr_prev = 0
        speed_prev = 0
        curr_dt = 0
        for i in [0..cr_values.length-1]
          if (i % 3) == 0
            curr += cr_values[i]
          else if (i%3)==1
            cr_prev = cr_values[i]
          else
            cr_data.push({time: curr, value: cr_prev})
            speed_data.push({time: curr, value: cr_values[i]})

      console.log speed_data
      console.log cr_data
#  window.rr_data = rr_data
#  window.hr_data = hr_data
  return [rr_data, hr_data, cr_data, speed_data]

@proc_old = (data, sid) ->
  rr_data=null
  start = data['start_time']
  curr = Date.parse(start)
  if data['rr_data'] && data['rr_data'].length!=0
    rr_values = decodeSensorTimeVal(data['rr_data'])
    rr_data = [{time: curr, value: rr_values[0]}]
    for rr in rr_values
      curr += rr
      rr_data.push({time: curr, value: rr})
    console.log "sid = " + sid + " duration (sec): " + (rr_data[rr_data.length - 1]['time'] - rr_data[0]['time']) / 1000.0

  cr_data = null
  speed_data = null

  if data['cr_data'] && data['cr_data'].length!=0
    cr_values = decodeSensorTimeVal(data['cr_data'])
  curr = Date.parse(start)
  cr_prev = 0
  speed_prev = 0
  curr_dt = 0

  if data['version'] =='1.1'
    if data['cr_data'] && data['cr_data']!=""
      console.log "adding speed data"
      cr_data = [{time: curr, value: cr_prev}]
      speed_data = [{time: curr, value: speed_prev}]

      for i in [0..cr_values.length-1]
        if (i % 3) == 0
          curr += cr_values[i]
        else if (i%3)==1
          cr_prev = cr_values[i]
        else
          cr_data.push({time: curr, value: cr_prev})
          speed_data.push({time: curr, value: cr_values[i]})
  else
    if data['cr_data'] && data['cr_data']!=""
      cr_data = [{time: curr, value: cr_prev}]
      for i in [0..cr_values.length-1]
        if i % 2 == 0
          curr += cr_values[i]
          curr_dt = cr_values[i]
        else
          cr_data.push({time: curr, value: (cr_values[i]-cr_prev)*6000.0/curr_dt})
          cr_prev = cr_values[i]

  hr_data = null
  if data['hr_data'] && data['hr_data']!=""
    hr_values = decodeSensorTimeVal(data['hr_data'])
    curr = Date.parse(start)
    hr_data = [{time: curr, value: 0}]
    for i in [0..hr_values.length-1]
      if i % 2 == 0
        curr += hr_values[i]
      else
        hr_data.push({time: curr, value: hr_values[i]})
#  window.hr_data = hr_data
  return [rr_data, hr_data, cr_data, speed_data]
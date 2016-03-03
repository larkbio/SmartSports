@health_loaded = () ->
  uid = $("#current-user-id")[0].value
  @popup_messages = JSON.parse($("#popup-messages").val())

  $("div.app2Menu a.menulink").removeClass("selected")
  $("#health-link").css
    background: "rgba(137, 130, 200, 0.3)"

  initMeasurement()
  loadHealthHistory()

  $("form.resource-create-form.measurement-form button").on('click', (evt) ->
    return validateMeasForm(evt.target.parentNode.parentNode.querySelector("form").id)
  )

  $("form.resource-create-form.measurement-form").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id

    $("#"+form_id+" input.dataFormField").val("")
    $('.defaultDatePicker').val(moment().format(moment_fmt))

    loadHealthHistory()
    popup_success(popup_messages.save_success, "healthStyle")
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    console.log error
    popup_error(popup_messages.failed_to_add_data, "healthStyle")
  )

  $("#recentMeasTable").on("ajax:success", (e, data, status, xhr) ->
    form_item = e.target
    console.log "delete success "+form_item.id
    loadHealthHistory()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    alert("Failed to delete measurement.")
  )

  $('.hisTitle').click ->
    loadHealthHistory()

  $(".favTitle").click ->
    loadHealthHistory(true)

  $("#recentMeasTable").on("click", "td.measItem", (e) ->
    console.log "loading measurement "+e.target
    data = JSON.parse(e.currentTarget.querySelector("input").value)
    console.log data
    meas = data['measurement']
    if(meas.meas_type=="blood_pressure")
      load_measurement_blood_pressure(".measurement_blood_pressure_elem", data)
    else if(meas.meas_type=="blood_sugar")
      load_measurement_blood_glucose(".measurement_blood_glucose_elem", data)
    else if(meas.meas_type=="weight")
      load_measurement_weight(".measurement_weight_elem", data)
    else if(meas.meas_type=="waist")
      load_measurement_waist(".measurement_waist_elem", data)
    else
      console.log("WARN: no measurement type "+meas.meas_type)
  )

  $(document).unbind("click.showHealth")
  $(document).on("click.showHealth", "#health-show-table", (evt) ->
    console.log "datatable clicked"
    get_table_row = (item ) ->
      if item.meas_type==null
        return null
      value = ""
      if item.meas_type == 'blood_pressure'
        if item.systolicbp
          value = item.systolicbp.toString()
        if value != ""
          value = value+"/"
        if item.diastolicbp
          value = value+item.diastolicbp.toString()
        if value != ""
          value = value+" "
        if item.pulse
          value= value+item.pulse.toString()
      else if item.meas_type == 'blood_sugar'
        value = item.blood_sugar
      else if item.meas_type == 'weight'
        value = item.weight
      else if item.meas_type == 'waist'
        value = item.waist
      return ([item.id, moment(item.date).format("YYYY-MM-DD HH:MM"), item.meas_type, value])

    current_user = $("#current-user-id")[0].value
    url = 'users/' + current_user + '/measurements.json'
    $.ajax urlPrefix()+url,
      type: 'GET',
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "datatable measurements AJAX Error: #{textStatus}"
      success: (data, textStatus, jqXHR) ->
        tblData = $.map(data, (item) ->
          return([get_table_row(item)])
        ).filter( (v) ->
          return(v!=null)
        )
        $("#health-data-container").html("<table id=\"health-data\" class=\"display\" cellspacing=\"0\" width=\"100%\"></table>")
        $("#health-data").dataTable({
          "data": tblData,
          "columns": [
            {"title": "id"},
            {"title": "date"},
            {"title": "type"},
            {"title": "value"}
          ],
          "order": [[1, "desc"]],
          "lengthMenu": [10]
        })
        location.href = "#openModal"
  )

  $(document).unbind("click.downloadHealth")
  $(document).on("click.downloadHealth", "#download-health-data", (evt) ->
    current_user = $("#current-user-id")[0].value
    url = '/users/' + current_user + '/measurements.csv?order=desc'
    location.href = url
  )

  $(document).unbind("click.closeHealth")
  $(document).on("click.closeHealth", "#close-health-data", (evt) ->
    $("#health-data-container").html("")
    location.href = "#close"
  )

@validateMeasForm = (formId) ->
  formNode = document.getElementById(formId)
  formType = formNode.querySelector("input[name='measurement[meas_type]']").value
  console.log "validate meas form: "+formId+", meas_type="+formType
  fn = {
    blood_pressure: ((node) ->
      if (isempty("#bp_sys") && isempty("#bp_dia") && isempty("#bp_hr")) ||
      (!isempty("#bp_sys") && isempty("#bp_dia")) ||
      (isempty("#bp_sys") && !isempty("#bp_dia")) ||
      (notpositive("#bp_sys") || notpositive("#bp_dia") || notpositive("#bp_hr"))
        popup_error(popup_messages.invalid_health_hr, "healthStyle")
        return false
    ),
    blood_sugar: ((node) ->
      if isempty("#glucose") || notpositive("#glucose")
        popup_error(popup_messages.invalid_health_bg, "healthStyle")
        return false
    ),
    weight: ((node) ->
      if isempty("#weight") || notpositive("#weight")
        popup_error(popup_messages.invalid_health_wd, "healthStyle")
        return false
    ),
    waist: ((node) ->
      if isempty("#waist") || notpositive("#waist")
        popup_error(popup_messages.invalid_health_cd, "healthStyle")
        return false
    )
  }
  if fn[formType]
    return fn[formType](formNode)
  else
    console.log "WARN: missing validation function for "+formType
    retrn true

@resetMeasForm = () ->
  console.log "reset meas form"

@initMeasurement = () ->
  console.log "init meas"

  $('.defaultDatePicker').datetimepicker(timepicker_defaults)

  stressList = $("#stressList").val().split(",")
  $(".bg_stress_scale").slider({
    min: 0,
    max: 3,
    value: 1
  }).slider({
    slide: (event, ui) ->
      event.target.parentElement.parentElement.querySelector(".bg_stress_percent").innerHTML = stressList[ui.value]
    change: (event, ui) ->
      event.target.parentElement.parentElement.querySelector(".bg_stress_amount").value = ui.value
  })
  $(".bg_stress_amount").val(1)

  bgTimeList = $("#bgTimeList").val().split(",")
  $(".bg_time_scale").slider({
    min: 0,
    max: 2,
    value: 0
  }).slider({
    slide: (event, ui) ->
      event.target.parentElement.parentElement.querySelector(".bg_time_unit").innerHTML = bgTimeList[ui.value]
    change: (event, ui) ->
      event.target.parentElement.parentElement.querySelector(".bg_time_val").value = ui.value
  })

  $('.bp_sys').focus()

@loadHealthHistory = (fav=false) ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load recent meas"
  lang = $("#data-lang-health")[0].value
  url = 'users/' + current_user + '/measurements.js?source='+window.default_source+'&order=desc&limit=20&lang='+lang
  if fav
    console.log "loading favorites"
    url = url+"&favourites=true"
  $.ajax urlPrefix()+url,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent measurements AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      if fav
        $(".deleteMeas").addClass("hidden")
      else
        $(".deleteMeas").removeClass("hidden")
      console.log "load recent measurements  Successful AJAX call"
      console.log textStatus

  if fav
    $(".hisTitle").removeClass("selected")
    $(".favTitle").addClass("selected")
  else
    $(".hisTitle").addClass("selected")
    $(".favTitle").removeClass("selected")


@load_measurement_blood_pressure = (sel, data) ->
  console.log "load_meas_bp"
  meas = data['measurement']
  $(sel+" input[name='measurement[systolicbp]']").val(meas.systolicbp)
  $(sel+" input[name='measurement[diastolicbp]']").val(meas.diastolicbp)
  $(sel+" input[name='measurement[pulse]']").val(meas.pulse)
  $(sel+" input[name='measurement[date]']").val(moment().format(moment_fmt))

@load_measurement_blood_glucose = (sel, data) ->
  console.log "load_meas_bg"
  console.log data
  meas = data['measurement']
  stressList = $("#stressList").val().split(",")
  bgTimeList = $("#bgTimeList").val().split(",")
  $(sel+" .bg_stress_scale").val(meas.stress_amount)
  $(sel+" .bg_time_scale").val(meas.blood_sugar_time)

  $(sel+" .bg_stress_percent").html(stressList[meas.stress_amount])
  $(sel+" .bg_stress_scale").slider({value: meas.stress_amount})

  $(sel+" .bg_time_unit").html(bgTimeList[meas.blood_sugar_time])
  $(sel+" .bg_time_scale").slider({value: meas.blood_sugar_time})

  if meas.blood_sugar
    $(sel+" input[name='measurement[blood_sugar]']").val(parseFloat(meas.blood_sugar).toFixed(2))
  else
    $(sel+" input[name='measurement[blood_sugar]']").val("")

  $(sel+" input[name='measurement[date]']").val(moment().format(moment_fmt))

@load_measurement_weight = (sel, data) ->
  console.log "load_meas_weight"
  meas = data['measurement']
  $(sel+" input[name='measurement[weight]']").val(meas.weight)
  $(sel+" input[name='measurement[date]']").val(moment().format(moment_fmt))

@load_measurement_waist= (sel, data) ->
  console.log "load_meas_waist"
  meas = data['measurement']
  $(sel+" input[name='measurement[waist]']").val(meas.waist)
  $(sel+" input[name='measurement[date]']").val(moment().format(moment_fmt))

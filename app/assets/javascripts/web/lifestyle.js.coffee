@wellbeing_loaded = () ->
  uid = $("#current-user-id")[0].value
  @popup_messages = JSON.parse($("#popup-messages").val())
  @resource_titles = JSON.parse($("#resource_titles").val())

  $("div.app2Menu a.menulink").removeClass("selected")
  $("#lifestyle-link").css
    background: "rgba(232, 115, 180, 0.3)"

  loadIllnessTypes( () ->
    initLifestyle()
    loadLifestyles()
  )

  $("form.resource-create-form.lifestyle-form").on("ajax:success", (e, data, status, xhr) ->
    self = this
    form_id = e.currentTarget.id
    loadLifestyles()

    msg = data['category']
    resetLifesyleForms()
  ).on("ajax:error", (e, xhr, status, error) ->
    popup_error(popup_messages.failed_to_add_data, "lifestyleStyle")
    $("input[name='lifestyle[name]']").val(null)
    $('#illnessname').val(null)
    $('#pain_name').val(null)
    console.log xhr.responseText
  )

  $("form.resource-create-form.lifestyle-form button").on('click', (evt) ->
    return validateLifestyleForm(evt.target.parentNode.parentNode.querySelector("form").id)
  )

  $("#recentResourcesTable").on("click", "td.lifestyleItem", (e) ->
    data = JSON.parse(e.currentTarget.querySelector("input").value)
    if data.lifestyle_category=='illness'
      load_lifestyle_illness("#lifestyle_forms .wellbeing_illness", data)
    else if data.lifestyle_category=='pain'
      load_lifestyle_pain("#lifestyle_forms .wellbeing_pain", data)
    else if data.lifestyle_category=='sleep'
      load_lifestyle_sleep("#lifestyle_forms .wellbeing_sleep", data)
    else if data.lifestyle_category=='stress'
      load_lifestyle_stress("#lifestyle_forms .wellbeing_stress", data)
  )

  $("#recentResourcesTable").on("ajax:success", (e, data, status, xhr) ->
    form_item = e.currentTarget
    console.log "delete success "+form_item

    loadLifestyles()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    alert("Failed to delete measurement.")
  )

  $('.hisTitle').click ->
    loadLifestyles()

  $(document).unbind("click.lifestyleShow")
  $(document).on("click.lifestyleShow", "#lifestyle-show-table", (evt) ->
    current_user = $("#current-user-id")[0].value
    lang = $("#user-lang")[0].value
    lifestyle_header = $("#lifestyle_header_values").val().split(",")
    url = 'users/' + current_user + '/lifestyles.json'+'?table=true&lang='+lang
    show_table(url, lang, lifestyle_header, 'get_lifestyle_table_row', 'show_lifestyle_table')
  )

  $(document).unbind("click.downloadLifestyle")
  $(document).on("click.downloadLifestyle", "#download-lifestyle-data", (evt) ->
    current_user = $("#current-user-id")[0].value
    lang = $("#user-lang")[0].value
    url = '/users/' + current_user + '/lifestyles.csv?order=desc&lang='+lang
    location.href = url
  )

  $(document).unbind("click.closeLifestyle")
  $(document).on("click.closeLifestyle", "#close-lifestyle-data", (evt) ->
    $("#lifestyle-data-container").html("")
    location.href = "#close"
  )

@initLifestyle = (selector) ->
  self = this
  if selector==null||selector==undefined
    selector = ""
  else
    selector = selector+" "

  @sleepList = $("#sleepList").val().split(",")
  @stressList = $("#stressList").val().split(",")
  @illnessList = $("#illnessList").val().split(",")
  @painList = $("#painList").val().split(",")
  @periodPainList = $("#periodPainList").val().split(",")
  @periodVolumeList = $("#periodVolumeList").val().split(",")
  @painTypeList = $("#painTypeList").val().split(",")

  console.log("running initLifestyle")

  user_lang = $("#user-lang")[0].value
  lifestyle_illness_select = $(".illness_name")
  lifestyle_pain_select = $(".pain_type_name")
  if user_lang
    illnesskey = 'sd_illness_'+user_lang
    painkey = 'sd_pains_'+user_lang
  else
    illnesskey = 'sd_illness_hu'
    painkey = 'sd_pains_hu'

  for element in getStored(illnesskey)
    lifestyle_illness_select.append($("<option />").val(element.id).text(element.label))

  for element in getStored(painkey)
    lifestyle_pain_select.append($("<option />").val(element.id).text(element.label))

  $(selector+' .sleep_start_datepicker').datetimepicker(timepicker_defaults)
  $(selector+' .sleep_start_datepicker').on("change.dp", (e) ->
    starttime = $(selector+'.sleep_start_datepicker').val()
    a = moment(starttime).add(8,'hours').format(moment_fmt)
    $(selector+'.sleep_end_datepicker').val(a)
  )

  $(selector+' .sleep_end_datepicker').datetimepicker(timepicker_defaults)
  $(selector+" .sleep_scale").slider({
    min: 0,
    max: 3,
    value: 2
  }).slider({
    slide: (event, ui) ->
      event.target.parentElement.parentElement.querySelector(".sleep_percent").innerHTML = sleepList[ui.value]
    change: (event, ui) ->
      event.target.parentElement.parentElement.querySelector(".sleep_amount").value = ui.value
  })
  $(selector+" .sleep_amount").val(2)

  $(selector+" .stress_scale").slider({
    min: 0,
    max: 3,
    value: 1
  }).slider({
    slide: (event, ui) ->
      event.target.parentElement.parentElement.querySelector(".stress_percent").innerHTML = stressList[ui.value]
    change: (event, ui) ->
      event.target.parentElement.parentElement.querySelector(".stress_amount").value = ui.value
  })
  $(selector+" .stress_amount").val(1)

  user_lang = $("#user-lang")[0].value
  if !user_lang
    user_lang='hu'

  $(selector+' .stress_datepicker').datetimepicker({
    format: 'Y-m-d',
    timepicker: false,
    lang: user_lang,
    scrollInput: false,
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
    todayButton: true
  })

  $(selector+" .illness_scale").slider({
    min: 0,
    max: 4,
    value: 1
  }).slider({
  slide: (event, ui) ->
      event.target.parentElement.parentElement.querySelector(".illness_percent").innerHTML = illnessList[ui.value]
    change: (event, ui) ->
      event.target.parentElement.parentElement.querySelector(".illness_amount").value = ui.value
  })
  $(selector+".illness_amount").val(1)

  $(selector+' .illness_start_datepicker').datetimepicker({
    format: 'Y-m-d',
    timepicker: false,
    lang: user_lang,
    scrollInput: false,
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
    todayButton: true
  })

  $(selector+' .illness_end_datepicker').datetimepicker({
    format: 'Y-m-d',
    timepicker: false,
    lang: user_lang,
    scrollInput: false,
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
    todayButton: true
  })

  $(selector+' .pain_start_datepicker').datetimepicker(timepicker_defaults)
  $(selector+' .pain_end_datepicker').datetimepicker(timepicker_defaults)

  $(selector+" .pain_scale").slider({
    min: 0,
    max: 4,
    value: 1
  }).slider({
    slide: (event, ui) ->
      event.target.parentElement.parentElement.querySelector(".pain_percent").innerHTML = painList[ui.value]
    change: (event, ui) ->
      event.target.parentElement.parentElement.querySelector(".pain_amount").value = ui.value
  })
  $(selector+" .pain_amount").val(1)


  $(selector+' .period_start_datepicker').datetimepicker({
    format: 'Y-m-d',
    timepicker: false,
    lang: user_lang,
    scrollInput: false,
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
    todayButton: true
  })

  $(selector+' .period_end_datepicker').datetimepicker({
    format: 'Y-m-d',
    timepicker: false,
    lang: user_lang,
    scrollInput: false,
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
    todayButton: true
  })

  $(selector+" .period_amount").val(1)
  $(selector+" .period_volume_amount").val(1)
  $(selector+" .period_scale").slider({
    min: 0,
    max: 4,
    value: 1
  }).slider({
    slide: (event, ui) ->
      event.target.parentElement.parentElement.querySelector(".period_percent").innerHTML = periodPainList[ui.value]
    change: (event, ui) ->
      event.target.parentElement.parentElement.querySelector(".period_amount").value = ui.value
  })
  $(selector+" .period_amount").val(1)

  $(selector+" .period_volume_scale").slider({
    min: 0,
    max: 4,
    value: 1
  }).slider({
    slide: (event, ui) ->
      event.target.parentElement.parentElement.querySelector(".period_volume_percent").innerHTML = periodVolumeList[ui.value]
    change: (event, ui) ->
      event.target.parentElement.parentElement.querySelector(".period_volume_amount").value = ui.value
  })
  $(selector+".period_volume_amount").val(1)

@resetLifesyleForms = () ->
  $(".sleep_scale").slider({value: 2})
  $(".sleep_percent").html(sleepList[2])
  $(".stress_scale").slider({value: 1})
  $(".stress_percent").html(stressList[1])
  $(".illness_scale").slider({value: 1})
  $(".illness_percent").html(illnessList[1])
  $(".pain_scale").slider({value: 1})
  $(".pain_percent").html(illnessList[1])
  $(".default_datetime_picker").val(new moment().format(moment_fmt))
  $(".default_date_picker").val(new moment().format(moment_datefmt))
  $(".illness_details").val("")
  $(".pain_details").val("")

@validateLifestyleForm = (formId) ->
  console.log "validate lifestyle: "+formId
  return true

@loadLifestyles = () ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load recent lifestyles"
  lang = $("#data-lang-wellbeing")[0].value
  url = 'users/' + current_user + '/lifestyles.js?source='+window.default_source+'&order=desc&limit=10&lang='+lang
  $.ajax urlPrefix()+url,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent lifestyles AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log textStatus

@loadIllnessTypes = (cb) ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load illness types"
  user_lang = $("#user-lang")[0].value
  db_version = $("#db-version")[0].value
  if user_lang
    painkey = 'sd_pains_'+user_lang
    illnesskey = 'sd_illness_'+user_lang
  else
    painkey = 'sd_pains_hu'
    illnesskey = 'sd_illness_hu'
  if getStored(illnesskey)==undefined || getStored(illnesskey).length==0 || testDbVer(db_version,['sd_illness_hu','sd_illness_en','sd_pains_hu','sd_pains_en'])
    ret = $.ajax urlPrefix()+'lifestyle_types.json',
      type: 'GET',
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "load lifestyle_types AJAX Error: #{textStatus}"
      success: (data, textStatus, jqXHR) ->
        console.log "load lifestyle_types  Successful AJAX call"

        setStored("sd_illness_hu", data.filter( (d) ->
          d['category'] == "illness"
        ).map( (d) ->
          {
          label: d['hu'],
          id: d['name']
          }))

        setStored("sd_illness_en", data.filter( (d) ->
          d['category'] == "illness"
        ).map( (d) ->
          {
          label: d['en'],
          id: d['name']
          }))

        setStored('sd_pains_hu', data.filter( (d) ->
          d['category'] == "pain"
        ).map( (d) ->
          {
          label: d['hu'],
          id: d['name']
          }))

        setStored('sd_pains_en', data.filter( (d) ->
          d['category'] == "pain"
        ).map( (d) ->
          {
          label: d['en'],
          id: d['name']
          }))
        setStored('db_version', db_version)

        cb()
  else
    ret = new Promise( (resolve, reject) ->
      console.log "illnesses already downloaded"
      cb()
      resolve("illness cbs called")
    )
  return ret

@load_lifestyle_sleep = (sel, data) ->
  console.log "load sleep "+sel+", ignored"

@load_lifestyle_stress = (sel, data) ->
  console.log "load stress"+sel+", ignored"

@load_lifestyle_illness = (sel, data) ->
  console.log "load illness"+sel
  lifestyle = data['lifestyle']
  $(sel+" .illness_name").val(data['lifestyle_name'])
  $(sel+" .illness_scale").slider({value: lifestyle.amount})
  $(sel+" .illness_percent").html(illnessList[lifestyle.amount])
  $(sel+" .illness_details").val(lifestyle.details)
  $(sel+" input[name='lifestyle[start_time]']").val(new moment().format(moment_datefmt))
  $(sel+" input[name='lifestyle[end_time]']").val(new moment().format(moment_datefmt))

@load_lifestyle_pain = (sel, data) ->
  console.log "load pain"+sel
  lifestyle = data['lifestyle']
  $(sel+" .pain_type_name").val(data['lifestyle_name'])
  $(sel+" .pain_scale").slider({value: lifestyle.amount})
  $(sel+" .pain_percent").html(painList[lifestyle.amount])
  $(sel+" .pain_details").val(lifestyle.details)
  $(sel+" input[name='lifestyle[start_time]']").val(new moment().format(moment_fmt))
  $(sel+" input[name='lifestyle[end_time]']").val(new moment().format(moment_fmt))


@load_lifestyle_period = (sel, data) ->
  console.log "load period"+sel+", ignored"

@get_lifestyle_label = (key) ->
  user_lang = $("#user-lang")[0].value
  arr = ['sd_illness_', 'sd_pains_']

  value = null
  console.log "get_label "+key

  arr.forEach((item) ->
    if user_lang
      life_db = item+user_lang
    else
      life_db = item+'hu'

    if getStored(life_db)!=undefined && getStored(life_db).length!=0
      tmp = getStored(life_db).filter((d) ->
        return d.id==key;
      )
      if tmp.length!=0
        value = tmp[0].label
  )
  if value==null
    value = 'Unknown'
  return value
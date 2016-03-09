@mdPatientsLoaded = () ->
  console.log "mdPatientsLoaded called"

  define_globals()
  @popup_messages = JSON.parse($("#popup-messages").val())
  customPreload()

  registerLogoutHandler()
  registerPopupHandler()
  registerLangHandler()

  resetMdUI()
  $("#patients-link").addClass("menulink-selected")

  @dateToShow = moment().format("YYYY-MM-DD")

  $("#patients-link").click (event) ->
    event.preventDefault()
    resetMdUI()
    $("#patients-link").addClass("menulink-selected")
    $("#sectionPatients").removeClass("hiddenSection")

  $("#notifDate").datetimepicker(timepicker_defaults)

  $(document).unbind("click.fillForm")
  $(document).on("click.fillForm", "#fillForm", (evt) ->

    if $("#fillForm").prop("checked")
      console.log "ch"
      $("#formDetails").removeClass("hidden")
      $("#openModalAddNotification .formContents").addClass("hidden")
      $("#elementName").val("")
      $("#openModalAddNotification div.formContents").empty()
    else
      console.log "no ch"
      $("#formDetails").addClass("hidden")
      $("#openModalAddNotification .formContents").addClass("hidden")
      $("#elementName").val("")
      $("#openModalAddNotification div.formContents").empty()
      getFormElement("notification_date", "#openModalAddNotification div.formContents", false)
  )

  $(document).unbind("click.addNotif")
  $(document).on("click.addNotif", "#addNotification", (evt) ->
    $("#notifDate").val(moment().format(moment_fmt))
    userid = $("input[name=patientId").val()
    $("#notificationCreateForm").attr("action", "/users/"+userid+"/notifications")
    location.href = "#openModalAddNotification"
    resetNotifForm()
    $("#notifTitle").focus()
    getFormElement("notification_date", "#openModalAddNotification div.formContents", false)
  )

  $("#openModalAddNotification").on("click", ".add-notification-button", (evt) ->
    evt.preventDefault()
    console.log("add notif clicked")

    window.tgt = evt.target
    addForm = evt.target.closest("form")
    action = addForm.getAttribute("action")
    params = decodeURIComponent($("#"+addForm.id).serialize())

    data = paramsToHash(params)
    fname = data['elementName']
    delete data['elementName']
    data["notification[form_name]"] = fname
    k = fname.split("_")[0]
    console.log("k = "+k)
    defaultForm = $(".formContents form")
    defaultParams = decodeURIComponent(defaultForm.serialize())
    defaultValues = generateDefaults(defaultParams)['custom_form_element[defaults]']
    defaultHashVal = paramsToHash(defaultParams)
    console.log defaultHashVal

    if defaultHashVal.hasOwnProperty("notification[date]")
      data["notification[date]"] = defaultHashVal["notification[date]"]
      data["notification[form_name]"] = "No form"

    timeKey = k+"[date]"
    console.log "checking "+timeKey
    if defaultHashVal.hasOwnProperty(timeKey)
      data["notification[date]"] = defaultHashVal[k+"[date]"]

    timeKey = k+"[start_time]"
    window.timeKey = timeKey
    window.defaultHashVal = defaultHashVal
    console.log "checking "+timeKey
    if defaultHashVal.hasOwnProperty(timeKey)
      console.log "defaulhash starttime:"
      console.log defaultHashVal[timeKey]
      data["notification[date]"] = defaultHashVal[timeKey]

    data["notification[default_data]"] = defaultValues
    $.ajax action,
      type: 'POST',
      data: data
      dataType: 'json'
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "Addnotif AJAX Error: #{textStatus}"
      success: (data, textStatus, jqXHR) ->
        console.log "Addnotif Successful AJAX call"
        location.href = "#close"
        console.log(data)
        userid = $("input.patientId").val()
        loadNotifications(userid)
  )

  $(document).unbind("click.closeNotif")
  $(document).on("click.closeNotif", "#closeModalAddNotification", (evt) ->

    location.href = "#close"
  )

  $("table.notificationTable tbody.recentResourcesTable").on("ajax:success", (e, data, status, xhr) ->
    console.log "delete success"
    userid = $("input[name=patientId").val()
    loadNotifications(userid)
  )

  $(document).unbind("click.tagDays")
  $(document).on("click.tagDays", "span.dayTag", (evt) ->
    evt.currentTarget.classList.toggle("selected")
    notifid = $(this).closest('tr').attr('id')
    e = document.getElementById(notifid)
    dayTags = e.getElementsByClassName("dayTag")
    notifs = []
    for j in dayTags
      notifs.push({id: j.id, selected: j.classList.contains("selected")})
    nid = notifid[13..]
    url = 'notifications/'+nid
    $.ajax urlPrefix()+url,
      type: 'PUT',
      data: {'notification[recurrence_data]': JSON.stringify(notifs)}
      dataType: 'json'
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "Dayselect clicked AJAX Error: #{textStatus}"
      success: (data, textStatus, jqXHR) ->
        console.log "Dayselect clicked Successful AJAX call"
  )

  $(document).unbind("click.userDetails")
  $(document).on("click.userDetails", "#headerItemAvatar", (evt) ->
    if evt.altKey
      $(".patientData .patientDetails").toggleClass("hidden")
  )
  loadPatients()

@initNotification = () ->
  $("#notifSimpleDate").datetimepicker(timepicker_defaults)

@resetNotifForm = () ->
  $("#notifTitle").val("")
  $("#notificationContainer textarea").val("")
  $("#fillForm").prop("checked", false)
  $("#elementName").val("")
  $("#formDetails").addClass("hidden")

  $(".formContents").addClass("hidden")
  $(".formContents").html("")


@loadPatients = () ->
  self = this
  $.ajax urlPrefix()+'users.json',
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
          console.log "select patient"

          $(".patientId").val(ui.item.id)

          $("#patientName").html( ui.item.label.trim() )
          $("input[name=patientId]").val(ui.item.obj.id)

          pic = ui.item.obj.avatar_url
          if pic == "unknown.jpeg"
            pic = "/assets/unknown.jpeg"
          $("#headerItemAvatar").attr( "src", pic )
          $("#patientHeader").removeClass("hidden")
          $(".patientData").removeClass("hidden")
          $(".patientData .patientDetails pre").html(JSON.stringify(ui.item.obj, null, '\t'))
          loadNotifications(ui.item.obj.id)
          $("#headerItemAvatar").tooltip({
            items: "img",
            content: '<img src="'+pic+'" />'
          })

          uid = ui.item.obj.id

          initFormElements("#openModalAddNotification div.formContents", false)

          registerShowPatientData(uid)

          dateToShow = moment().format(moment_datefmt)
          console.log("----------- Timeline starts --------------")
          self.timeline = new TimelinePlot(uid, "analysis_data", dateToShow, "Weekly timeline", {period: "weekly"})
          self.timeline.draw("div.timelineChart")

          $('#timeline_datepicker').datetimepicker({
            format: 'Y-m-d',
            timepicker: false,
            onSelectDate: (ct, input) ->
              console.log("timeline date selected")
              self.timeline.update(moment(ct).format(moment_datefmt))
              input.datetimepicker('hide')
            todayButton: true
          })

          plist = ["weekly", "daily"]
          $("#timeline_period").autocomplete({
            minLength: 0,
            source: plist,
            select: (event, ui) ->
              self.timeline.updatePeriod(ui['item']['label'])
          }).focus ->
            $(this).autocomplete("search")

          d3.json(urlPrefix()+"users/"+uid+"/measurements.json?meas_type=blood_sugar", draw_bg_data)

          measStartDate = moment().subtract(6, 'months').format(moment_datefmt)
          meas_summary_url = "users/" + uid + "/measurements.json?summary=true&start="+measStartDate
          d3.json(urlPrefix()+meas_summary_url, draw_health_trend)

          startDate = moment().subtract(12, 'months').format(moment_datefmt)
          d3.json(urlPrefix()+"users/"+uid+"/summaries.json?bysource=true&start="+startDate, draw_patient_activity_data)

        create: (event, ui) ->
#          document.body.style.cursor = 'auto'
          $(".patientName").removeAttr("disabled")
        change: (event, ui) ->
          console.log "change"

      }).focus ->
        $(this).autocomplete("search")


@loadNotifications = (userId) ->
  console.log "calling load notifications for: "+userId
  url = 'users/' + userId + '/notifications.js?order=desc&limit=10'
  $.ajax urlPrefix()+url,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent diets AJAX Error: #{textStatus}"
    success: (jqXHR, textStatus, errorThrown) ->
      console.log "render notifications done"

@registerShowPatientData = (uid) ->
  $(document).unbind("click.showPatientData")
  $(document).on("click.showPatientData", ".md-show-table", (evt) ->
    console.log "datatable clicked"
    get_table_row = (item ) ->
      e = ""
      if item.end
        e = moment(item.end).format(moment_fmt)

      return ([moment(item.start).format(moment_fmt), e, item.evt_type, item.group, item.value1, item.value2 ])

    url = 'users/' + uid + '/analysis_data.json?tabular=true'
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
        $("#patient-data-container").html("<table id=\"patient-data\" class=\"display\" cellspacing=\"0\" width=\"100%\"></table>")
        $("#patient-data").dataTable({
          "data": tblData,
          "columns": [
            {"title": "start"},
            {"title": "end"},
            {"title": "type"},
            {"title": "group"}
            {"title": "value1"}
            {"title": "value2"}
          ],
          "order": [[1, "desc"]],
          "lengthMenu": [5]
        })
        location.href = "#openModal"
  )

  $(document).unbind("click.downloadPatient")
  $(document).on("click.downloadPatient", "#download-patient-data", (evt) ->
    url = '/users/' + uid + '/analysis_data.csv?tabular=true'
    location.href = url
  )

  $(document).unbind("click.closePatient")
  $(document).on("click.closePatient", "#close-patient-data", (evt) ->
    $("#health-data-container").html("")
    location.href = "#close"
  )

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
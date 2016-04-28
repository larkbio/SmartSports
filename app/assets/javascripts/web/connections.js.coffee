@connections_loaded = () ->
  console.log("connections_loaded()")
  $("#connections-link").addClass("menulink-selected")
  reset_ui()
  define_globals()
  @popup_messages = JSON.parse($("#popup-messages").val())
  load_connections()


  $("#sectionConnections").on("ajax:success", "form.resource-delete-form", (e, data, status, xhr) ->
    console.log "delete conn success"
    load_connections(true)
  ).on("ajax:error", (e, xhr, status, error) ->
    popup_error(popup_messages.failed_to_add_data)
  )

@load_connections = (nopopup=false) ->
  self = this
  current_user = $("#current-user-id")[0].value

  if $("#sectionConnections").size() > 0
    # if still on the connections page
    url = 'users/' + current_user + '/connections.js'
    $.ajax urlPrefix()+url,
      type: 'GET',
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "load connections AJAX Error: #{textStatus}"
      success: (data, textStatus, jqXHR) ->
        add_connect_button()
        $("#recentResourcesTable").on("click", "button.syncConnButton", (evt) ->
          evt.target.className += " fa-spin"
          if typeof self.timeoutId=="number"
            window.clearTimeout(self.timeoutId)
          self.timeoutId = setTimeout( () ->
            console.log("connection timer fired")
            load_connections()
          , 10000)

          if typeof self.timeoutId2=="number"
            window.clearTimeout(self.timeoutId2)
          self.timeoutId2 = setTimeout( () ->
            console.log("connection timer 2 fired")
            load_connections()
          , 50000)
        )
        $("#addDeviceButton").on("click", () ->
          $("#addDeviceButton").addClass("hidden")
          $("#addconnForm").removeClass("hidden")
        )
        if $("#recentResourcesTable .connectionItem").size()>0
          $("#conntitle").removeClass("hidden")
          $("#noconntitle").addClass("hidden")
        else
          $("#noconntitle").removeClass("hidden")
          $("#conntitle").addClass("hidden")
        if $("#addconn").val()!="" and !nopopup
          console.log "addconn: "+$("#addconn_message").val()
          popup_success($("#addconn-message").val())
  else
    console.log("not on connections page")

@add_connect_button = () ->
  addConnRow = $("#template_addconn").children().first().clone()
  $("#recentResourcesTable").append(addConnRow)
  $("#recentResourcesTable select").attr("id", "connectionToAdd")
  connected = $.map($("#recentResourcesTable [data-conn]"), (d) -> d.dataset.conn)
  remaining = new Set();
  remaining.add(['withings', 'moves', 'fitbit', 'google', 'misfit'])
  connected.forEach( (c) -> remaining.delete(c))
  remaining.forEach( (c) -> $("#connectionToAdd").append("<option>"+c+"</option>"))
  links = {
    moves: "/auth/moves",
    withings: "/auth/withings",
    fitbit: "/auth/fitbit",
    google: "/auth/google_oauth2",
    misfit: "/auth/shine"
  }
  $("#recentResourcesTable").on("click", "button.addConnButton", (evt) ->
    evt.preventDefault()
    console.log "link: "+links[$("#connectionToAdd").val()]
    window.location = links[$("#connectionToAdd").val()]
  )

# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@pages_menu = () ->
  console.log "pages layout"

@reset_ui = () ->
  $("#browser-menu-tab a.browser-subnav-item").removeClass("selected")
  $("#friend-form-div div.friend-message").addClass("hidden")

  close_modals = () ->
    $("div.friend-select-holder").addClass("hidden")
    $(document).off("click")

  $("i.friend-select-arrow").click (event) ->
    event.stopPropagation()
    $("div.friend-select-holder").removeClass("hidden")
    $(document).click (event) ->
      event.preventDefault()
      close_modals()

  load_friends()

load_friends = () ->
  $.ajax '/users/'+$("#current-user-id")[0].value+'/friendships',
    type: 'GET'
    dataType: 'json'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "Successful friendship call"
      console.log data

      $("div.friend-select-list").empty()
      $("#friend-form div.friend-list").empty()

      if $("#current-user-id")[0].value !=  $("#shown-user-id")[0].value
        add_me()

      for f in data
        console.log "other_id="+f.other_id+" shownid="+$("#shown-user-id")[0].value
        if f.other_id.toString() == $("#shown-user-id")[0].value
          continue
        if f.authorized
          newfriend = $("#friend-select-item-template").children().first().clone()
          console.log newfriend
          newid = "f-"+f.id
          newfriend.attr("id", newid)
          $("div.friend-select-list:last-child").append(newfriend)
          $("#"+newid+" .friend-select-item-text").html(f.other_name)
          friend_sel_id = "friend-sel-"+f.other_id
          $("#"+newid+" .friend-select-item-text").attr("id", friend_sel_id)
          $("#"+friend_sel_id).click (evt) ->
            friend_id = evt.target.id.split("-")[-1..]
            console.log "friend selected: "+friend_id
            window.location = "/pages/health?shown_user="+friend_id

        if f.authorized
          $("#friend-form div.friend-list:last-child").append("<div>"+f.other_name+" <i class=\"fa fa-check activated\"></i></div>")
        else
          $("#friend-form div.friend-list:last-child").append("<div>"+f.other_name+"<span class=\"activate_friend\" id=\"friend_act_"+f.id+"\"> Activate</span></div>")
          $("#friend_act_"+f.id).click (evt) ->
            arr = evt.target.id.split("_")
            fid = arr[arr.length-1]
            console.log fid
            $.ajax '/users/'+f.my_id+'/friendships/'+fid+"?cmd=activate",
              type: 'GET'
              dataType: 'json'
              error: (jqXHR, textStatus, errorThrown) ->
                console.log "AJAX Error: #{textStatus}"
              success: (data, textStatus, jqXHR) ->
                console.log "Successful activate call"
                load_friends()

add_me = () ->
  console.log "adding me"
  newfriend = $("#friend-select-item-template").children().first().clone()
  newid = "f-me"
  newfriend.attr("id", newid)
  $("div.friend-select-list:last-child").append(newfriend)
  $("#"+newid+" .friend-select-item-text").html("Me")
  friend_sel_id = "friend-sel-me"
  $("#"+newid+" .friend-select-item-text").attr("id", friend_sel_id)
  $("#"+friend_sel_id).click (evt) ->
    window.location = "/pages/dashboard"
@profile_reg_loaded = () ->
  console.log "profile loaded"
  popup_messages = JSON.parse($("#popup-messages").val())
  $('#lastname_field').focus()

  $('#profile_datepicker').datetimepicker({
    format: 'Y',
    timepicker: false
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
  })

  langList = [{ label: "Magyar", value: "hu"},
    { label: "English", value: "en"}
  ]
  $("#lang_sel").autocomplete({
    minLength: 0,
    source: langList
    change: (event, ui) ->
      console.log ui.item
      setLang(event, ui)
    select: (event, ui) ->
      setLang(event, ui)
      return false
  }).focus ->
    $(this).autocomplete("search")

  gendervals = $("#gender_values").val().split(",")
  sexList = [{ label: gendervals[0], value: "male"},
    { label: gendervals[1], value: "female"}
  ]
  $("#sex_sel").autocomplete({
      minLength: 0,
      source: sexList
      change: (event, ui) ->
        console.log ui.item
        setGender(event, ui)
      select: (event, ui) ->
        setGender(event, ui)
        return false
  }).focus ->
    $(this).autocomplete("search")

  yesnovals = $("#yes_no_values").val().split(",")
  yesnoList = [{ label: yesnovals[0], value: "1"},
    { label: yesnovals[1], value: "0"}
  ]
  $("#smoke_sel").autocomplete({
    minLength: 0,
    source: yesnoList
    change: (event, ui) ->
      console.log ui.item
      setSmoke(event, ui)
    select: (event, ui) ->
      setSmoke(event, ui)
      return false
  }).focus ->
    $(this).autocomplete("search")

#  $("#insulin_sel").autocomplete({
#    minLength: 0,
#    source: yesnoList
#    change: (event, ui) ->
#      console.log ui.item
#  }).focus ->
#    $(this).autocomplete("search")

  setSmoke = (event, ui) ->
    labelItem = event.target
    labelItem.value = ui['item']['label']
    valueItem = labelItem.parentNode.querySelector("input[name='profile[smoke]']")
    valueItem.value = ui['item']['value']

  setGender = (event, ui) ->
    labelItem = event.target
    labelItem.value = ui['item']['label']
    valueItem = labelItem.parentNode.querySelector("input[name='profile[sex]']")
    valueItem.value = ui['item']['value']

  setLang = (event, ui) ->
    labelItem = event.target
    labelItem.value = ui['item']['label']
    valueItem = labelItem.parentNode.querySelector("input[name='profile[default_lang]']")
    valueItem.value = ui['item']['value']

  $("#profileForm").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id

    #    redir to main page
    document.location = urlPrefix()+data.locale+"/pages/dashboard"
  ).on("ajax:error", (e, data, status, error) ->
    #console.log data.responseJSON
    #popup_error(popup_messages.failed_to_add_data)
    popup_error(data.statusText)
  )
  $("#emptyProfileForm").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id

    #    redir to main page
    document.location = urlPrefix()+data.locale+"/pages/dashboard"
  ).on("ajax:error", (e, data, status, error) ->
    #console.log data.responseJSON
    #popup_error(data.responseJSON["msg"])
    popup_error(data.statusText)
  )


@signup_loaded = () ->
  console.log "signup loaded"
  popup_messages = JSON.parse($("#popup-messages").val())
  $('#username_field').focus()
  $("#signupForm").on("ajax:success", (e, data, status, error) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id

    if(data.ok == false)
      popup_error(data.responseJSON["msg"])
    else
      document.location = urlPrefix()+data.locale+"/profile/new"
  ).on("ajax:error", (e, data, status, error) ->
    console.log data.responseJSON
    popup_error(data.responseJSON["msg"])
#    popup_error(popup_messages.sign_up_failed)
  )


@signin_loaded = () ->
  console.log "signin loaded"
  popup_messages = JSON.parse($("#popup-messages").val())
  $('#username_field').focus()

  $(document).unbind("ajax:success.login")
  $(document).on("ajax:success.login", "#loginForm", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id
    document.location = data.redir_url
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log error
    popup_error(xhr.responseJSON["msg"])
  )

@resetpw_loaded = () ->
  console.log "resetpw loaded"
  popup_messages = JSON.parse($("#popup-messages").val())
  $("#forgotten_email_field").focus()

  $("#pwResetForm").on("ajax:success", (e, data, status, error) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id
    if data.ok
      popup_success(popup_messages.passwd_reset_success)
      document.location = urlPrefix()+data.locale+"/pages/signin"
    else
      popup_error(popup_messages.password_reset_failed)
  ).on("ajax:error", (e, data, status, error) ->
    console.log data.responseJSON
    popup_error(popup_messages.password_reset_failed)
  )

@resetpw_page_loaded = () ->
  console.log "resetpw page loaded"

  $("#pwChangeForm").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id
    console.log data.locale
    if data.ok
       popup_success(xhr.responseJSON["msg"])
       document.location = urlPrefix()+data.locale+"/pages/signin"
    else
      console.log xhr.responseJSON
      popup_error(xhr.responseJSON["msg"])
  ).on("ajax:error", (e, data, status, xhr) ->
    popup_error(xhr.responseJSON["msg"])
    #popup_error(popup_messages.password_reset_failed)
  )
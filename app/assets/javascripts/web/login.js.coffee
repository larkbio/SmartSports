@profile_reg_loaded = () ->
  console.log "profile loaded"
  popup_messages = JSON.parse($("#popup-messages").val())
  $('#lastname_field').focus()

  user_lang = $("#user-lang")[0].value
  if !user_lang
    user_lang='hu'

  $('#profile_datepicker').datetimepicker({
    format: 'Y',
    timepicker: false,
    lang: user_lang
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
  })

  langList = [{ value: "Magyar", dbval: "hu"},
    { value: "English", dbval: "en"}
  ]
  $("#lang_sel").autocomplete({
    minLength: 0,
    source: langList
    change: (event, ui) ->
      setLang(event, ui)
    select: (event, ui) ->
      setLang(event, ui)
      return false
  }).focus ->
    $(this).autocomplete("search")

  gendervals = $("#gender_values").val().split(",")
  sexList = [{ value: gendervals[0], dbval: "male"},
    { value: gendervals[1], dbval: "female"}
  ]
  $("#sex_sel").autocomplete({
      minLength: 0,
      source: sexList
      change: (event, ui) ->
        setGender(event, ui)
      select: (event, ui) ->
        setGender(event, ui)
        return false
  }).focus ->
    $(this).autocomplete("search")

  yesnovals = $("#yes_no_values").val().split(",")
  yesnoList = [{ value: yesnovals[0], dbval: "1"},
    { value: yesnovals[1], dbval: "0"}
  ]
  $("#smoke_sel").autocomplete({
    minLength: 0,
    source: yesnoList
    change: (event, ui) ->
      setSmoke(event, ui)
    select: (event, ui) ->
      setSmoke(event, ui)
      return false
  }).focus ->
    $(this).autocomplete("search")

  setSmoke = (event, ui) ->
    event.target.parentElement.querySelector("#smoke_sel").value = ui.item.value
    event.target.parentNode.querySelector("input[name='profile[smoke]']").value = ui.item.dbval

  setGender = (event, ui) ->
    event.target.parentElement.querySelector("#sex_sel").value = ui.item.value
    event.target.parentNode.querySelector("input[name='profile[sex]']").value = ui.item.dbval

  setLang = (event, ui) ->
    event.target.parentElement.querySelector("#lang_sel").value = ui.item.value
    event.target.parentNode.querySelector("input[name='profile[default_lang]']").value = ui.item.dbval

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
  $('[data-toggle="tooltip"]').tooltip();
  $('#username_field').focus()
  $("#signupForm").on("ajax:success", (e, data, status, error) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id

    if(data.ok == false)
      popup_error(data.responseJSON["msg"])
    else
      document.location = urlPrefix()+data.locale+"/profile/edit"
  ).on("ajax:error", (e, data, status, error) ->
    console.log data.responseJSON
    popup_error(data.responseJSON["msg"])
    #popup_error(popup_messages.sign_up_failed)
  )


@signin_loaded = () ->
  console.log "signin loaded"
  popup_messages = JSON.parse($("#popup-messages").val())
  $('#username_field').focus()

  $(document).unbind("ajax:success.login")
  $(document).on("ajax:success.login", "#loginForm", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id
    #redir to main page
    document.location = urlPrefix()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log error
    popup_error(xhr.responseJSON["msg"])
    #popup_error(popup_messages.login_failed)
  )

@resetpw_loaded = () ->
  console.log "resetpw loaded"
  popup_messages = JSON.parse($("#popup-messages").val())
  $("#forgotten_email_field").focus()


  $("#infoPopup").one( "click", ".infoButton", () ->
    console.log document.location.href
    if document.location.pathname.indexOf("en") > -1
      lang = "en"
    else
      lang = "hu"
    document.location = urlPrefix()+lang+"/pages/signin"
  )
  $("#pwResetForm").on("ajax:success", (e, data, status, error) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id
    if data.ok
      popup_success(popup_messages.passwd_reset_success)
    else
      popup_error(popup_messages.password_reset_failed)
  ).on("ajax:error", (e, data, status, error) ->
    console.log data.responseJSON
    popup_error(popup_messages.password_reset_failed)
  )

@resetpw_page_loaded = () ->
  console.log "resetpw page loaded"

  $("#infoPopup").one( "click", ".infoButton", () ->
    if document.location.pathname.indexOf("en") > -1
      lang = "en"
    else
      lang = "hu"
    document.location = urlPrefix()+lang+"/pages/signin"
  )
  $("#pwChangeForm").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id
    console.log xhr.responseJSON
    if data.ok
       popup_success(xhr.responseJSON["msg"])
    else
      console.log xhr.responseJSON
      popup_error(xhr.responseJSON["msg"])
  ).on("ajax:error", (e, data, status, xhr) ->
    console.log xhr.responseJSON

    errorMessage = (xhr.responseJSON && xhr.responseJSON["msg"]) || "Invalid pasword reset"
    popup_error(errorMessage)
    #popup_error(popup_messages.password_reset_failed)
  )
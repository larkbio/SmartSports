@mdCustomformsLoaded = () ->
  console.log "md loaded"

  registerLogoutHandler()
  registerPopupHandler()
  registerLangHandler()

  resetMdUI()
  $("#forms-link").addClass("menulink-selected")

  @dateToShow = moment().format("YYYY-MM-DD")

  define_globals()
  customPreload()
  initCustomForms()

  registerCustomFormHandlers()

#  initDiet()
#  initActivity()
#  initMeas()
#  initMedications()
#  initLifestyle()

#  initCustomForms()

#  $("form#custom-create-form").on("ajax:success", (e, data, status, xhr) ->
#    console.log data
#    if data['ok'] == true
#      location.href = "md_customforms"
#    else
#      $("#input-form_name").addClass("formFail")
#      $("i.formFailSign").removeClass("hidden")
#  ).on("ajax:error", (e, xhr, status, error) ->
#    $("#input-form_name").addClass("formFail")
#    $("i.formFailSign").removeClass("hidden")
#  )
#
#  $(".delete-form-form").on("ajax:success", (e, data, status, xhr) ->
#    console.log e.target
#    location.href = 'md_customforms'
#  ).on("ajax:error", (e, xhr, status, error) ->
#    console.log "delete failed"
#    console.log e.target
#  )
#
#  $("#openModalAddCustomFormElement form.resource-create-form").on("ajax:success", (e, data, status, xhr) ->
#    location.href = "md_customforms"
#  )

@resetMdUI = () ->
  $(".menuitem a.menulink").removeClass("menulink-selected")
#  $(".menu-section").addClass("hiddenSection")


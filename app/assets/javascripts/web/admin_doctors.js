function load_doctors() {
    self = this;

    url = 'users.js?doctor=true';
    $.ajax({
        url: urlPrefix() + url,
        type: 'GET',
        error:  function(jqXHR, textStatus, errorThrown) {
            console.log("load doctors AJAX Error: #{textStatus}");
        },
        success: function(data, textStatus, jqXHR) {
            console.log("load doctors AJAX success");
        }
    });
}
function admin_doctors_loaded() {
    popup_messages = JSON.parse($("#popup-messages").val())
    console.log("admin doctors loaded");
    $("div.app2Menu a.menulink").removeClass("menulink-selected");
    $("#doctors-link").addClass("menulink-selected");

    $("#inviteDoctorContainer").on("ajax:success", function(e, data, status, xhr) {
            msg = JSON.parse(xhr.responseText);
            console.log( msg);
            popup_success(popup_messages[msg.msg].replace("%{email}", msg.email));
            load_doctors();
        }
    ).on("ajax:error", function(e, xhr, status, error) {
            msg = JSON.parse(xhr.responseText);
            console.log(msg);
            popup_error(popup_messages[msg.msg].replace("%{email}", msg.data));
        }
    );

    $("table.userTable").on("ajax:success", function(e, data, status, xhr) {
        console.log("usertable ajax success");
        console.log(data);
        load_doctors();
    }).on("ajax:error", function(e, xhr, status, error) {
        console.log("usertable ajax error");
        console.log(xhr);
        load_doctors();
    })

}

'use strict';

var adverses_loaded = function() {
    console.log("adverses page showing");
    $(".adverse_effects_datepicker").datetimepicker(timepicker_defaults);
    resetAdverse();
    var popup_messages = JSON.parse($("#popup-messages").val());
    loadAdverse();

    $("form.resource-create-form.adverse-form").on("ajax:success", function(e, data, status, xhr) {
        resetAdverse();
        loadAdverse();
        popup_success(popup_messages.saved_successfully);
    }).on("ajax:error", function (e, xhr, status, error) {
        $('#diet_type_id').val(null);
        $('#diet_drink_type_id').val(null);
        $('.diet_smoke_type').val(null);
        console.log(xhr.responseText);
        var resp = JSON.parse(xhr.responseText);
        popup_error(resp.msg);
    });

    $("#recentResourcesTable").on("ajax:success", function (evt, data) {
            loadAdverse();
            console.log(data);
            popup_success(data.msg);
        }
    ).on("ajax:error", function (e, xhr, status, error) {
            console.log(xhr.responseText);
            popup_error(popup_messages.failed_to_delete_data);
        }
    );

    $("#yesButton").on("click", function(evt) {
        evt.preventDefault();
        $("#yesButton").attr("disabled", true).addClass("selected");
        $("#noButton").attr("disabled", true);
        $("input[name='adverse[effect_present]']").val("yes").removeClass("hidden");
        $("button.adverseAddButton").removeClass("hidden");
        $(".adverseDetailSearch").removeClass("hidden");
        $("input[name='adverse[time]']").removeClass("hidden");
    });

    var adverseSelected = null;
    $(".adverseDetailSearch").autocomplete({
        source: function(request, response) {
            response(["Hasmenés", "Hányinger", "Fejfájás", "Émelygés", "Kiütés"]);
        },
        select: function(event, ui) {
            console.log("selected: ");
            console.log(ui.item);
            $(".adverseDetail").val(ui.item.label);
        },
        minLength: 0
    }).focus(function() {
        $(this).autocomplete("search");
    });
};

function resetAdverse() {
    $("#yesButton").attr("disabled", false);
    $("#yesButton").removeClass("selected");
    $("#noButton").attr("disabled", false);
    $("input[name='adverse[time]']").addClass("hidden");
    $("button.adverseAddButton").addClass("hidden");
    $(".adverseDetailSearch")
        .addClass("hidden")
        .val("");
    $(".adverseDetail").val("");
    $("input[name='adverse[effect_present]']").val("no");
}

function loadAdverse () {
    var current_user = $("#current-user-id")[0].value;
    var lang = $("#data-lang-diet")[0].value;
    var url = '/users/' + current_user + '/adverses.js';
    console.log("url = "+url);
    $.ajax({
            url: url,
            type: 'GET',
            error: function (jqXHR, textStatus, errorThrown) {
                console.log( "load recent diets AJAX Error: #{textStatus}");
            },
            success: function (data, textStatus, jqXHR) {
                console.log("load adverse success");
                $(".deleteDiet").removeClass("hidden");
            }
    });
}
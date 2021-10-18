$(document).on('click', '.test-slet', function(e) {
    e.preventDefault();

    $(".new-notepad-textarea").val("");
    // MI.Phone.Animations.SoldanSaga(".notepad-home")
    MI.Phone.Animations.SoldanSaga(".new-notepad")
});

$(document).on('click', '#new-notepad-back', function(e) {
    e.preventDefault();

    // MI.Phone.Animations.SagdanSola(".notepad-home")
    MI.Phone.Animations.SagdanSola(".new-notepad")
});

$(document).on('click', '#new-notepad-submit', function(e) {
    e.preventDefault();

    var notepad = $(".new-notepad-textarea").val();

    if (notepad !== "") {
        MI.Phone.Animations.SagdanSola(".new-notepad")
        $.post('http://almez-phonev2/PostNotepad', JSON.stringify({
            message: notepad,
        }));
    } else {
        MI.Phone.Notifications.Add("yellow", "Hata!", "Mesajın boş olamaz!", "");
    }
});

MI.Phone.Functions.RefreshNotepads = function(notepads) {
    if (notepads.length > 0 || notepads.length == undefined) {
        $.each(notepads, function(i, notepad) {
            var element = '<div class="notepad"><span class="notepad-sender">' + notepad.name + ' | ' + notepad.number + '</span><p>' + notepad.message + '</p></div>';
            $(".notepad-list").append(element);
        });
    }
}
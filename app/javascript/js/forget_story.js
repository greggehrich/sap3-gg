
document.addEventListener("turbolinks:load", function () {
  $("body").on('click', '.forget-story-link', function (event) {
    event.preventDefault();
    let id = this.id;
    let linksDiv = $(this).parent();
    let forgetStoryWrapper = $(".forget-story-link-" + id);
    let savedText = $(".saved-text-" + id);
    let savedTextHr = $(".saved-text-hr-" + id);
    let statusText = $(".status-text-" + id);

    $.ajax({
      url: '/stories/' + id + '/forget',
      method: 'post',
      contentType: 'application/json',
    })
      .done(function (data) {
        if (data['success']) {
          // remove link
          forgetStoryWrapper.remove();
          // remove status text
          statusText.remove();
          // remove saved text
          savedText.remove();
          savedTextHr.remove();
          // append text and forget btn
          linksDiv.append("<p class='m-auto save-story-link save-story-link-" + id + "' id=" + id +"><a href='javascript: void(0)' id=" + id + " class=' btn btn-sm btn-primary grid-item-save-story-" + id + "'><i class='fas fa-bookmark mr-1'></i> Save Story</a></p>");
          // success text
          // linksDiv.append("<p class='status-text-" + id + " success-"+ data['success'] +"'>" + data['message'] + "</p>");
        } else {
          linksDiv.append("<p class='status-text-" + id + " success-" + data['success'] +"'>" + data['message'] + "</p>");
        };
      })
  })
});

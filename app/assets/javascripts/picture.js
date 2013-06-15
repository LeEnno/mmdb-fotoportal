$(function() {

  // INIT FACE DETECTION
  // ---------------------------------------------------------------------------
  var image = $('.do-facedetect').get(0);
  image.onload = function () {
    detectNewImage(image, true);
  };


  // HANDLE AJAX RESPONSE AFTER SUBMITTING FORM
  // ---------------------------------------------------------------------------
  $('#form-picture-edit').on('ajax:success', function(evt, data, status, xhr) {
    console.log("data:", data);

  // blur input and submit form on enter (dunno why doesn't automatically)
  }).on('keydown', 'input', function(e) {
      if (e.keyCode == 13) { // 13 = Enter key
        $(this).blur();
        $('#form-picture-edit').submit();
      }
  });
});


// EXECUTE FACE DETECTION AND INSERT INPUT FOR FOUND FACES
// -----------------------------------------------------------------------------
function detectNewImage(image, async) {
  
  // callback after face was found
  function post(comp) {
    console.log('stopped');

    for (var i = 0; i < comp.length; i++) {

      // give border to found face
      var $detectedArea = $('<div class="found-image" />').appendTo('#form-picture-edit').css({
        top:    comp[i].y + image.offsetTop,
        left:   comp[i].x + image.offsetLeft,
        height: comp[i].height,
        width:  comp[i].width
      });

      // make input
      $('<input />').attr({
        name:  'picture[person][]',
        id:    'picture_person_' + i,
        class: 'input-face-detection'

      // position next to found face
      }).appendTo($detectedArea).css({
        top:  comp[i].height / 2 - 10,
        left: comp[i].width
      });
    }
  }

  // call main detect_objects function
  if (async) {
    console.log('started');
    ccv.detect_objects({
      "canvas":        ccv.grayscale(ccv.pre(image)),
      "cascade":       cascade,
      "interval":      5,
      "min_neighbors": 1,
      "async":         true,
      "worker":        1
    })(post);
  } else {
    var comp = ccv.detect_objects({
      "canvas":        ccv.grayscale(ccv.pre(image)),
      "cascade":       cascade,
      "interval":      5,
      "min_neighbors": 1 });
    post(comp);
  }
}
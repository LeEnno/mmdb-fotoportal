$(function() {

  var $pictureForm = $('#form-picture-edit');

  // INIT FACE DETECTION
  // ---------------------------------------------------------------------------
  var image = $('.do-facedetect').get(0);
  if (typeof image != 'undefined') {
    image.onload = function () {
      detectNewImage(image, true);
    };
  }


  // EVENT LISTENER FOR FORM AND ITS INPUTS
  // ---------------------------------------------------------------------------

  // handle ajax response
  $pictureForm.on('ajax:success', function(evt, data, status, xhr) {

    // set faces input to returned value
    $('#picture_persons').val(data.persons);

    // if user typed a person's name, remove input and the detected area
    $('.input-face-detection').each(function(i, el) {
      var $this = $(this);
      if ($.trim($this.val()) !== '') {
        $this.add($this.data('detectedArea')).fadeOut(function() {
          $(this).remove();
        });
      }
    });


  // blur input and submit form on enter (dunno why doesn't automatically)
  }).on('keydown', 'input', function(e) {
      if (e.keyCode == 13) { // 13 = Enter key
        $(this).blur();
        $pictureForm.submit();
      }

  // submit form on folder change
  }).on('change', 'select', function() {
    $pictureForm.submit();
  });
});


// EXECUTE FACE DETECTION AND INSERT INPUT FOR FOUND FACES
// -----------------------------------------------------------------------------
function detectNewImage(image, async) {

  // callback after face was found
  function post(comp) {
    console.log('stopped', comp);

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

      // assign input to detectedArea
      }).data('detectedArea', $detectedArea)

      // position next to found face
      .appendTo($detectedArea).css({
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

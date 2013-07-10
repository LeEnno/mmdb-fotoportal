$(function() {

  // vars
  var $pictureForm = $('#form-picture-edit'),
      typeaheadSrc;


  /* INIT FACE DETECTION
   * -----------------------------------------------------------------------------
   */
  var image = $('.do-facedetect').get(0);
  if (typeof image != 'undefined') {
    image.onload = function () {
      detectNewImage(image, true);
    };
  }


  /* INIT AUTOCOMPLETE FOR FACES AND KEYWORDS
   * ---------------------------------------------------------------------------
   * 
   * We have to wrap the typeahead()-call in a little plugin so we can apply it
   * to elements that do not yet exist.
   */
  $.fn.applyTypeahead = function() {

    return this.typeahead({
      source: function(query, process) {
        var processQuery = function(process, $element){
          return function() {
            var takeKeywords = $element.attr('id') == 'picture_keywords';
            process(takeKeywords ? typeaheadSrc.keywords : typeaheadSrc.faces);
          };
        }(process, this.$element);

        // load faces and keywords if we haven't done already
        if (typeof typeaheadSrc == 'undefined') {
          $.ajax({
            url: $('#user_faces_and_keywords').val(),
            success: function(data) {
              typeaheadSrc = data;
              processQuery();
            }
          });

        // if faces and keywords have already been loaded: continue to process
        } else {
          processQuery();
        }
      },

      matcher: function (item) {
        var query = this.query.replace(/.*(, ?(.*))/, '$2');
        return ~item.toLowerCase().indexOf(query.toLowerCase());
      },

      updater: function (item) {
        var val = this.$element.val();
        if (val.indexOf(',') < 0)
          return item;
        return val.replace(/(.+),.*/, '$1, ' + item);
      }
    });
  };
  $('#picture_persons, #picture_keywords').applyTypeahead();



  /* AJAX--LISTENER FOR FORM AND SUBMIT-TRIGGER FOR ITS INPUTS
   * -----------------------------------------------------------------------------
   */

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
        var $this = $(this).blur();

        // prevent double submit
        if ($this.attr('id') != 'picture_title')
          $pictureForm.submit();
      }


  // submit form on folder change
  }).on('change', 'select', function() {
    $pictureForm.submit();
  });


  /* EDIT TITLE
   * -----------------------------------------------------------------------------
   */
  var $editBtn    = $('#ediPicturetTitle'),
      $editIcon   = $editBtn.find('i'),
      $titleSpan  = $('#spanPictureTitle'),
      $titleInput = $('#picture_title'),
      endEdit     = function() {
        $editIcon.toggleClass('icon-pencil icon-ok');
        $pictureForm.submit();
        $titleSpan.text(
          $titleInput.hide().val()
        ).show();
      };

  // if edit-button is clicked hide span and show input
  $editBtn.on('click', function(e) {
    e.preventDefault();
    if ($editIcon.hasClass('icon-pencil')) {
      $editIcon.toggleClass('icon-pencil icon-ok');
      $titleSpan.hide();
      $titleInput.show().focus();
    }
  });

  // catch submits in blur and enter
  $titleInput.on('blur', function() {
    endEdit();
  });
});


/* EXECUTE FACE DETECTION AND INSERT INPUT FOR FOUND FACES
 * -----------------------------------------------------------------------------
 */
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

      // enable autocomplete
      }).applyTypeahead();
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

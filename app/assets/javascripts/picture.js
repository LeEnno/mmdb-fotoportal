$(function() {
  $('.do-facedetect').load(function(e) {
    var $this = $(this),
        coords = $this.faceDetection({
          error: function(img, code, message) {
            console.log(img);
            console.log(code);
            console.log(message);
          },
          complete: function(img, coords) {
            console.log(img);
            console.log(coords);
          }
        });
      // console.log(coords);
      console.log('done');
  });
});
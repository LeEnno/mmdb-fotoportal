$(function() {
  $('.dropzone').on('dzUploadSuccess', '.dz-preview', function(e, permalink) {
    $(this).append('<a href="' + permalink + '">Link</a>');
  });
});
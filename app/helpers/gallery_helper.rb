module GalleryHelper

  # Render markup for show_folders (also infinite scroll).
  # 
  # We replace double quotes with single quotes for compatibility with JSON
  # format. JSON only allows double quotes as string wrappers, so we have to
  # make sure we only return string with single quotes in it.
  # 
  def image_previews_with_markup(pictures)
    pictures.map do |p|
      link_to(image_tag(p.file_url('thumb')).html_safe,
              picture_url(:picture_id => p.id),
              :class => 'show-folder-image-preview').gsub(/"/, "'")
    end
  end
end

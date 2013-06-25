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


  # Render markup for folder children
  # 
  def folder_as_tree(folder, active_folder, is_root = false)
    is_active = folder == active_folder

    out = content_tag :i, nil, :class => 'icon-folder-' + (is_active ? 'open' : 'close')

    folder_name = (folder.name || ('Alle Fotos' if is_root) || 'unbenannt') + " (#{folder.all_pictures.count})"
    folder_link = is_root ? gallery_path : folder_path(:folder_id => folder.id)
    out += link_to(folder_name, folder_link, :class => ('active' if is_active))
    out += link_to('+', new_folder_path(:parent_id => folder.id), :class => 'btn btn-mini btn-success folder-add')
    out += link_to('-', delete_folder_path, :class => 'btn btn-mini btn-danger folder-remove') if !is_root
    
    out = content_tag :span, out.html_safe, :class => 'folder-links-wrapper'
    
    folder.children.each do |c|
      out += folder_as_tree(c, active_folder)
    end

    out = content_tag :li, out.html_safe

    if is_root
      ul_options = {
        :id                      => 'navFolderTree',
        :class                   => 'tree',
        :"data-active-folder-id" => active_folder.id
      }
    end
    content_tag :ul, out.html_safe, (ul_options || {})
  end
end

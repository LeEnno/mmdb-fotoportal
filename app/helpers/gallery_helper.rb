module GalleryHelper

  # Render markup for show_folders (also infinite scroll).
  # 
  # We replace double quotes with single quotes for compatibility with JSON
  # format. JSON only allows double quotes as string wrappers, so we have to
  # make sure we only return string with single quotes in it.
  # 
  def image_previews_with_markup(pictures)
    pictures.map do |p|
      out = content_tag :div, :class => 'show-folder-image-preview-wrapper' do
        link_to(image_tag(p.file_url('thumb')).html_safe,
                picture_url(:picture_id => p.id),
                :class => 'show-folder-image-preview').html_safe +
        link_to('x',
                delete_picture_path(:picture_id => p.id),
                :class => 'btn btn-mini btn-danger btn-delete-picture').html_safe
      end
      out.gsub(/"/, "'")
    end
  end


  # Render markup for folder children.
  # 
  def folder_as_tree(folder, active_folder, is_root = false)
    is_active = folder == active_folder

    out = content_tag :i, nil, :class => 'icon-folder-' + (is_active ? 'open' : 'close')

    folder_name  = folder.name || 'unbenannt'
    folder_name += '(' + content_tag(:span, "#{folder.all_pictures.count}", :class => 'folder-picture-count') + ')'
    folder_link  = is_root ? gallery_path : folder_path(:folder_id => folder.id)
    out += link_to(folder_name.html_safe, folder_link, :class => 'folder-link' + (is_active ? ' active' : ''), :id => "folder#{folder.id}", :'data-folder-id' => folder.id)
    out += link_to('+', new_folder_path(:parent_id => folder.id), :class => 'btn btn-mini btn-success folder-add')
    out += link_to('-', delete_folder_path(:folder_id => folder.id), :class => 'btn btn-mini btn-danger folder-remove') if !is_root
    
    out = content_tag :span, out.html_safe, :class => 'folder-link-wrapper'
    
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


  # Make list item with label and value.
  # 
  def list_horizontal_group(key, value, li_class = '')
    content_tag :li, :class => ['control-group', li_class].join(' ') do
      out = label_tag(nil, key, :class => 'control-label')
      out += content_tag(:div, :class => 'controls') do
        value
      end
    end
  end
end

module ApplicationHelper
  
  def form_horizontal_group(label, input)
    content_tag :div, :class => 'control-group' do
      label + content_tag(:div, :class => 'controls') do
        input
      end
    end
  end

end

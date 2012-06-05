class AvatarInput < SimpleForm::Inputs::FileInput
  def input
    out = ''
    if object.send("#{attribute_name}?")
      out << template.image_tag(object.send(attribute_name).url(:thumb), :class => 'thumbnail', id: 'avatar')
    end
    (out << @builder.file_field(attribute_name, input_html_options)).html_safe
  end
end
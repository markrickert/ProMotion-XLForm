module ProMotion
  module XLFormSectionBuilder

    def create_section(section_data)
      section = XLFormSectionDescriptor.section(section_data)

      tag = section_data[:name]
      if tag.respond_to? :to_s
        tag = tag.to_s
      end
      unless section.options.nil?
        mp("MutliValued section with no :name option", force_color: :red) unless tag
      end

      # force a tag for procs
      if tag.nil?
        @section_index ||= 0
        tag = "section_#{@section_index}"
      end
      section.multivaluedTag = tag

      if view = section_data[:title_view]
        view = section_data[:title_view].new if section_data[:title_view].respond_to?(:new)
        view.on_load if view.respond_to?(:on_load)
        view.title = section_data[:title] if view.respond_to?(:title=)

        section.titleView = view
      end
      section.footerTitle = section_data[:footer] if section_data[:footer]

      add_proc tag, :on_add, section_data[:on_add] if section_data[:on_add]
      add_proc tag, :on_remove, section_data[:on_remove] if section_data[:on_remove]

      # section visible
      if section_data[:hidden]
        configure_hidden(section, section_data[:hidden])
      end

      section_data[:cells].each do |cell_data|
        cell = create_cell(cell_data)

        section.addFormRow(cell)

        # multi sections
        if section.multivaluedTag
          cell.action.required = @required
          section.multivaluedRowTemplate = cell.copy
        end
      end

      section
    end

  end
end

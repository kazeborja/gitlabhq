module Projects
  class UploadService < BaseService
    def initialize(project, file)
      @project, @file = project, file
    end

    def execute
      return nil unless @file and @file.size <= max_attachment_size

      uploader = FileUploader.new(@project)
      uploader.store!(@file)

      filename = uploader.image? ? uploader.file.basename : uploader.file.filename

      escaped_filename = filename.gsub("]", "\\]")
      markdown = "[#{escaped_filename}](#{uploader.secure_url})"
      markdown.prepend("!") if uploader.image?

      {
        alt:      filename,
        url:      uploader.secure_url,
        is_image: uploader.image?,
        markdown: markdown
      }
    end

    private

    def max_attachment_size
      current_application_settings.max_attachment_size.megabytes.to_i
    end
  end
end

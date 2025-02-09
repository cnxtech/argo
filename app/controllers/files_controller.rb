# frozen_string_literal: true

class FilesController < ApplicationController
  before_action :load_resource

  ##
  # Brings up a modal dialog that lists all locations of the file
  def index
    raise ArgumentError, 'Missing file parameter' if filename.blank?

    @available_in_workspace = Dor::Services::Client.object(params[:item_id]).files.list.include?(filename)

    respond_to do |format|
      format.html { render layout: !request.xhr? }
    end
  end

  def show
    authorize! :view_content, @object
    response.headers['Content-Type'] = 'application/octet-stream'
    response.headers['Content-Disposition'] = 'attachment; filename=' + filename
    response.headers['Last-Modified'] = Time.now.utc.rfc2822 # HTTP requires GMT date/time
    self.response_body = Dor::Services::Client.object(params[:item_id]).files.retrieve(filename: filename)
  end

  def preserved
    authorize! :view_content, @object
    file_content = Dor::Services::Client.object(@object.pid).files.preserved_content(filename: filename, version: params[:version].to_i)
    response.headers['Content-Type'] = 'application/octet-stream'
    response.headers['Content-Disposition'] = "attachment; filename=#{filename}"
    response.headers['Last-Modified'] = Time.now.utc.rfc2822 # HTTP requires GMT date/time
    self.response_body = file_content
  end

  private

  def filename
    params[:id]
  end

  def load_resource
    @object = Dor.find params[:item_id]
  end
end

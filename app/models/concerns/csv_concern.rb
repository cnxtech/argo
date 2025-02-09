# frozen_string_literal: true

require 'csv'

module CsvConcern
  ##
  # Converts the `report_data` into CSV data
  # TODO: this method uses data iteration and `search_results` assumed to be in the model already
  #
  # @return [String] data in CSV format
  def to_csv
    @params[:page] = 1
    CSV.generate(force_quotes: true) do |csv|
      csv << @fields.map { |f| f[:label] } # header
      while @document_list.length > 0
        report_data.each do |record|
          csv << @fields.map { |f| record[f[:field]].to_s }
        end
        @params[:page] += 1
        (@response, @document_list) = search_results(params)
      end
    end
  end
end

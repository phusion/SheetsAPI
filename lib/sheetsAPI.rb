require 'set'
require 'googleauth'
require 'google/apis/sheets_v4'

# # Uncomment this to inspect requests made to the google API
# module Google
#   module Apis
#     module Core
#       class HttpClientAdapter
#         alias old_call call
#         def call(request)
#           puts request.inspect
#           old_call(request)
#         end
#       end
#     end
#   end
# end

module SheetsAPI
  if !File.file? "#{Dir.pwd}/GoogleAPICredentials.json"
    raise "Missing Google API Credentials: #{Dir.pwd}/GoogleAPICredentials.json"
  end

  ENV["GOOGLE_APPLICATION_CREDENTIALS"] = "#{Dir.pwd}/GoogleAPICredentials.json"
  scopes = ['https://www.googleapis.com/auth/drive']
  authorization = Google::Auth.get_application_default(scopes)

  SheetService = Google::Apis::SheetsV4::SheetsService.new
  SheetService.authorization = authorization

  class << self
    # This will raise if the document cannot be opened
    def document(id)
      return Document.new(id)
    end
  end

  class Sheet
    def initialize(document, sheetName)
      @document = document
      @sheetName = sheetName
    end

    def insert(rows:[], index:[], upsert: false, sort: false)
      # Get current content of sheet
      sheetContent = SheetService.get_spreadsheet_values(@document.id, "'#{@sheetName}'")&.values || []

      # Get current headers in the sheet
      sheetHeaders = sheetContent.shift || []

      # Add any missing headers
      missingHeaders = ([Set.new(index)] + rows.map(&:keys)).reduce(&:merge).to_a.map(&:to_s) - sheetHeaders
      newHeaders = sheetHeaders + missingHeaders
      symbolHeaders = newHeaders.map(&:to_sym)

      # If we need to upsert and an index is provided
      if upsert && index.length > 0
        # If we upsert a row it no longer needs further processing
        rows.delete_if do |row|
          rowIndex = index.map{ |i| row[i].to_s }
          lineIndex = index.map{ |i| symbolHeaders.index(i) }
          # Attempt to match the index of the row with the corresponding index of each line in the current content
          match = sheetContent.index{ |line| lineIndex.map{ |i| line[i] } == rowIndex }
          # If we match, replace the values in that line with the contents of our row, and return true to remove this row
          if match
            sheetContent[match] = symbolHeaders.each_with_index.map { |header, index| row[header] || sheetContent[match][index] }
            true
          else
            false
          end
        end
      end

      # Append any remaining rows
      sheetContent += rows.map{ |row| symbolHeaders.map{ |header| row[header] || "" }}

      # Sort the output
      if sort && index.length > 0
        sortIndex = index.map{ |s| symbolHeaders.index(s) }
        sheetContent.sort!{ |row1, row2| sortIndex.map{ |i| row1[i].to_s } <=> sortIndex.map{ |i| row2[i].to_s }}
      end

      # Write the updated content to the spreadsheet
      SheetService.update_spreadsheet_value(@document.id, "'#{@sheetName}'", {major_dimension: "ROWS", values: sheetContent.unshift(newHeaders)}, value_input_option: 'USER_ENTERED')

    end
  end

  class Document
    def initialize(documentId)
      @id = documentId
      @document = SheetService.get_spreadsheet(documentId)
    end
    attr_reader :id

    def sheet(sheetName)
      @sheetName = sheetName

      sheet = @document.sheets.find{|sheet| sheet.properties.title.downcase == sheetName.downcase}
      if !sheet
        createSheet(sheetName)
      end

      return Sheet.new(self, sheetName)
    end

    private

    def createSheet(sheetName)
      batch_update_request = {requests: [{
        add_sheet: {
          properties: {
            title: sheetName
          }
        }
      }]}
      SheetService.batch_update_spreadsheet(@id, batch_update_request, {})
    end
  end
end

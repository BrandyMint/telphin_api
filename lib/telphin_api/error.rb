module TelphinApi
  # An exception raised by `TelphinApi::Result` when given a response with an error.
  class Error < StandardError
    # An error code.
    # @return [String]
    attr_reader :error_code

    # An exception is initialized by the data from response mash.
    # @param [Hash] data Error data.
    def initialize(data)
      @error_code = data.code
      @error_msg = data.message
    end

    # A full description of the error.
    # @return [String]
    def message
      "Telphin returned an error #{@error_code}: '#{@error_msg}'"
    end
  end
end

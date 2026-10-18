module StaffApi
  module V1
    class BaseController < ApplicationController
      include ApiErrorHandling
      include ApiResponses
    end
  end
end

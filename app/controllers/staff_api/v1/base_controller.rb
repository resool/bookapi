module StaffApi
  module V1
    class BaseController < ApplicationController
      include ApiErrorHandling
      include ApiResponses
      include Idempotency
    end
  end
end

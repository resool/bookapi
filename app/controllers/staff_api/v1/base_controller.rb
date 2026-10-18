module StaffApi
  module V1
    class BaseController < ApplicationController
      include ApiErrorHandling
    end
  end
end

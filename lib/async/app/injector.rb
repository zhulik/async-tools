# frozen_string_literal: true

module Async::App::Injector
  def inject(name)
    define_method(name) do
      $__ASYNC_APP.container[name] # rubocop:disable Style/GlobalVars
    end
    private name
  end
end

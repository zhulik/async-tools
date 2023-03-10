# frozen_string_literal: true

module Async::App::Injector
  def inject(name)
    define_method(name) do
      Async::App.instance.container[name]
    end
    private name
  end
end

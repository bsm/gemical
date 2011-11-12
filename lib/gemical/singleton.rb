module Gemical::Singleton

  def self.included(base)
    class << base
      private :new
    end
    base.extend ClassMethods
  end

  module ClassMethods

    def instance
      @instance ||= new
    end

    def reload!
      @instance = nil
    end

  end

end
module JkoPay
  class Configure
    attr_reader :online, :pos
    attr_accessor :mode

    def initialize
      @online = Config.new
      @pos = Config.new
      @mode = :sandbox
    end

    def production?
      @mode == :production
    end

    def method_missing(method_name, *args)
      if method_name.to_s.start_with? "setup"
        instance_name = method_name.to_s.gsub(/\Asetup_/, "")
        self.class.attr_reader instance_name.to_sym
        setting = instance_variable_get :"@#{instance_name}"
        instance_variable_set :"@#{instance_name}", self.class.new unless setting
        yield instance_variable_get(:"@#{instance_name}")
      else
        super
      end
    end

  end
end
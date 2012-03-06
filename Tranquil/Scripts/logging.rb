require "stringio"

# Just forwards stdout to tranquil's log view
class TranquilIO < StringIO
	def write(str)
        Logger.sharedLogger.log(str)
		STDOUT.write(str)
		super
	end
end
$stdout = TranquilIO.new

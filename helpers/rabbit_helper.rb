# Holds RabbitMQ-related helper functions

# Initialize RabbitMQ object & connection appropriate to
# the current env (viz., local vs. prod)
def get_rabbit_object
  if Sinatra::Base.production?
    # Determine what env variable(s) are needed in prod
  else
    rabbit = Bunny.new(automatically_recover: false)
  end
  rabbit.start
end

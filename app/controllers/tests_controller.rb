class TestsController < Simpler::Controller
  def index
    @time = Time.now
    status 201
    headers['Content-Type'] = 'text/plain'
    render plain: 'Plain text response'
  end

  def create
    status 302
  end
  
  def show
    status 200
  end
end

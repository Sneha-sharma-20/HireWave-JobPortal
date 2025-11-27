require 'sinatra'
require 'sinatra/reloader' if development?
require 'pg'
require 'bcrypt'
require 'time'
require 'securerandom'

# New session system for Sinatra 4.x + Rack 3.x
configure do
  use Rack::Session::Cookie,
      key: 'hirewave.session',
      path: '/',
      expire_after: 2592000, # 30 days
      secret: ENV['SESSION_SECRET'] || SecureRandom.hex(64)  # Must be 64 bytes
end

set :bind, '0.0.0.0'
set :port, 5000

def db_connection
  PG.connect(
  dbname: 'myappdb',
  user: 'postgres',
  password: 'Swathi@17',
  host: 'localhost',
  port: 5432
)

end

helpers do
  def current_user
    if session[:user_id]
      conn = db_connection
      result = conn.exec_params("SELECT * FROM users WHERE id = $1", [session[:user_id]])
      user = result.first
      conn.close
      user
    end
  end
  
  def logged_in?
    !current_user.nil?
  end
  
  def require_login
    redirect '/login' unless logged_in?
  end
  
  def employer?
    current_user && current_user['user_type'] == 'employer'
  end
  
  def jobseeker?
    current_user && current_user['user_type'] == 'jobseeker'
  end
end

# ROUTES BELOW (Unchanged)
get '/' do
  conn = db_connection
  @jobs = conn.exec("SELECT * FROM jobs ORDER BY created_at DESC")
  conn.close
  erb :index
end

get '/signup' do
  redirect '/' if logged_in?
  erb :signup
end

post '/signup' do
  conn = db_connection
  password_hash = BCrypt::Password.create(params[:password])

  begin
    result = conn.exec_params(
      "INSERT INTO users (username, email, password_hash, user_type, company_name, full_name) 
       VALUES ($1, $2, $3, $4, $5, $6) RETURNING id",
      [params[:username], params[:email], password_hash, params[:user_type], 
       params[:company_name], params[:full_name]]
    )
    session[:user_id] = result.first['id']
    conn.close
    redirect '/'
  rescue PG::UniqueViolation
    conn.close
    @error = "Username or email already exists"
    erb :signup
  end
end

get '/login' do
  redirect '/' if logged_in?
  erb :login
end

post '/login' do
  conn = db_connection
  result = conn.exec_params("SELECT * FROM users WHERE username = $1", [params[:username]])
  user = result.first
  conn.close

  if user && BCrypt::Password.new(user['password_hash']) == params[:password]
    session[:user_id] = user['id']
    redirect '/'
  else
    @error = "Invalid username or password"
    erb :login
  end
end

get '/logout' do
  session.clear
  redirect '/'
end

get '/jobs/new' do
  require_login
  redirect '/' unless employer?
  erb :new_job
end

post '/jobs' do
  require_login
  redirect '/' unless employer?

  conn = db_connection
  conn.exec_params(
    "INSERT INTO jobs (title, description, company, location, salary, job_type, employer_id) 
     VALUES ($1, $2, $3, $4, $5, $6, $7)",
    [params[:title], params[:description], params[:company], params[:location], 
     params[:salary], params[:job_type], current_user['id']]
  )
  conn.close
  redirect '/'
end

get '/jobs/:id' do
  conn = db_connection
  result = conn.exec_params("SELECT * FROM jobs WHERE id = $1", [params[:id]])
  @job = result.first

  if logged_in? && jobseeker?
    app_result = conn.exec_params(
      "SELECT * FROM applications WHERE job_id = $1 AND user_id = $2",
      [params[:id], current_user['id']]
    )
    @already_applied = !app_result.first.nil?
  end

  conn.close
  erb :job_detail
end

post '/jobs/:id/apply' do
  require_login
  redirect '/' unless jobseeker?

  conn = db_connection
  begin
    conn.exec_params(
      "INSERT INTO applications (job_id, user_id, cover_letter) VALUES ($1, $2, $3)",
      [params[:id], current_user['id'], params[:cover_letter]]
    )
  rescue PG::UniqueViolation
    # Already applied
  end
  conn.close

  redirect "/jobs/#{params[:id]}"
end

get '/my-jobs' do
  require_login
  redirect '/' unless employer?

  conn = db_connection
  @jobs = conn.exec_params("SELECT * FROM jobs WHERE employer_id = $1 ORDER BY created_at DESC", [current_user['id']])
  conn.close
  erb :my_jobs
end

get '/my-applications' do
  require_login
  redirect '/' unless jobseeker?

  conn = db_connection
  @applications = conn.exec_params(
    "SELECT applications.*, jobs.title, jobs.company, jobs.location 
     FROM applications 
     JOIN jobs ON applications.job_id = jobs.id 
     WHERE applications.user_id = $1 
     ORDER BY applications.applied_at DESC",
    [current_user['id']]
  )
  conn.close
  erb :my_applications
end

get '/jobs/:id/applications' do
  require_login
  redirect '/' unless employer?

  conn = db_connection
  job_result = conn.exec_params("SELECT * FROM jobs WHERE id = $1 AND employer_id = $2", [params[:id], current_user['id']])
  @job = job_result.first

  if @job
    @applications = conn.exec_params(
      "SELECT applications.*, users.full_name, users.email 
       FROM applications 
       JOIN users ON applications.user_id = users.id 
       WHERE applications.job_id = $1 
       ORDER BY applications.applied_at DESC",
      [params[:id]]
    )
  end

  conn.close
  erb :job_applications
end

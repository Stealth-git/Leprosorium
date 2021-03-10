#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'leprosorium.db'
	@db.results_as_hash = true
end
	
# before вызывается каждый раз при перезагрузке 
# любой страницы
before do
	# инициализация базы данных
	init_db
end

# configure вызывается каждый раз при инициализации приложения
# когда изменился код программы и перезагрузилась страница

configure do
	# инициализация базы данных
	init_db

	# создает таблицу если таблица не существует
	@db.execute 'CREATE TABLE IF NOT EXISTS "Posts" 
	(
	"id" INTEGER PRIMARY KEY AUTOINCREMENT, 
	"created_date" DATE, 
	"content" TEXT
	)'
end

get '/' do
	# выбираем список постов из БД

	@results = @db.execute 'SELECT * FROM Posts order by id desc'
	erb :index		
end

# обработчик get-запроса /new
# (браузер получает страницу с сервера)

get '/new' do
	erb :new
end

# обработчик post-запроса /new
# (браузер отправляет данные на сервер)
post '/new' do

	# получаем переменную из пост запроса
	content = params[:content]

	if content.length <= 0
		@error = 'Type post text'
		return erb :new
	end

	# сохранение данных в БД
	@db.execute 'insert into Posts (content, created_date) values (?, datetime())', [content]

	# перенаправление на главную страницу
	redirect to '/'

	erb "You typed: #{content}"
end

# вывод информации о посте

get '/details/:post_id' do
	# получаем переменную из url'а
	post_id = params[:post_id]

	# получаем список постов
	# (у нас будет только один пост)
	results = @db.execute 'SELECT * FROM Posts WHERE id = ?', [post_id]
	
	# выбираем этот один пост в переменную @row
	@row = results[0]

	# возвращаем представление details.erb
	erb :details
end

# обработчик post-запроса /details/...
# бразер отправляет данные на сервер, мы их принимаем
post '/details/:post_id' do

	# получаем переменную из url'а
	post_id = params[:post_id]

	# получаем переменную из пост запроса
	content = params[:content]

	erb "You typed comment #{content} for post #{post_id}"

end
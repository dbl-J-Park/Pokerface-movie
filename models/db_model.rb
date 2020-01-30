require 'pg'

def dbconnect(sql)
    conn = PG.connect(ENV['DATABASE_URL'] || {dbname: 'movie_pockerface'})
    result = conn.exec(sql)
    conn.close
    return result
end



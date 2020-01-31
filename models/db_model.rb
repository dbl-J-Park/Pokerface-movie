require 'pg'


def dbconnect(sql,args=[])
    conn = PG.connect(ENV['DATABASE_URL'] || {dbname: 'movie_pockerface'})
    result = conn.exec_params(sql,args)
    conn.close
    return result
end







# This method is for mega_data of movie_db_table
def dbparsing(sql)
    conn = PG.connect(ENV['DATABASE_URL'] || {dbname: 'movie_pockerface'})
    resultstr = conn.exec(sql)
    conn.close
    result = JSON.parse(resultstr)
end

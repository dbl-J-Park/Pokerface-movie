require 'bcrypt'

# digesting password
def password_hiding(password)
    return digested_password = BCrypt::Password.create(password)
end

#varification 
def varify_password?(encripted_password,password)
    if BCrypt::Password.new(encripted_password) == password
        return true
    else 
        return false 
    end
end

local test = {}

function test.index(page)
	local stringVariable = 'this variable is being passed from a controller to a view!'
    local anotherVar = 2342 -- this one too! \o/
    
    page:write("Here we are testing basic functionalities, such as LP parsing and V-C communication.")

    page:render('index',{stringVariable = stringVariable,anotherVar = anotherVar})
end

function test.mailer(page)

	local mail = require "src.mail"

	local message = "Hello!"
	if page.POST['email'] then
        local sent, err = mail.send_message("<"..page.POST['email']..">","This is the subject!","This is the body!")
        if err then
        	message = err
        else
        	message = "The email was sent!"
        end
    end

    page:render('mailer',{msg = message})
end

function test.models(page)
	--Testing Models
    --[[
		I'm using 'User' model for testing under a mysql db.	
		If you want to check it out, you need to create this table:

		create table user(
			id int primary key auto_increment, 
			name varchar(20), 
			password varchar(20)
		);
    ]]
    local User = sailor.model("user")
    local u = User:new()

    u.name = "maria"
    u.password = "1234"

    if u:save() then
        page:write("saved! "..u.id.."<br/>")
    end
    
    -- NOT ESCAPED, DONT USE IT UNLESS YOU WROTE THE WHERE STRING YOURSELF
    local u2 = User:find("name ='francisco'")

    if u2 then
        page:write(u2.id.." - "..u2.name.."<br/>")
    end

    local users = User:find_all()
    for _, user in pairs(users) do 
        page:write(user.id.." - "..user.name.."<br/>")
    end
      
    u.name = "catarina"
    if u:save() then
        page:write("saved! "..u.id.."<br/>")
    end

    local users = User:find_all()
    for _, user in pairs(users) do 
        page:write(user.id.." - "..user.name.."<br/>")
    end

    page:write("Finding user with id 1:<br/>")
    local some_user = User:find_by_id(1)
    if some_user then
        page:write(some_user.id.." - "..some_user.name.."<br/>")
    end

    page:write("Finding user with id 47:<br/>")
    local some_user = User:find_by_id(47)
    if some_user then
        page:write(some_user.id.." - "..some_user.name.."<br/>")
    else
        page:write("User not found!")
    end
end

function test.form(page)
	local form = require "src.form"
	local User = sailor.model("user")
    local u = User:new()
    u.name="test"
    page:render('form',{user=u,form = form})
end

function test.validation(page)
	local validation = require "src.validation"

	local print = function(str,err,exp) 
						page:write("Validation check on '"..str.."': ") 
						if exp then page:write ("Expected ") end
						if err then page:write("Error: value "..err) else page:write("Check!") end 
						page:write("<br/>")
					end

	local test_string = "test string!"
	local _,err = validation.check(test_string).type("string").len(3,5)
    print(test_string,err,true)

    _,err = validation.check(test_string).type("number").len(3,5)
    print(test_string,err,true)
    
    test_string = "hey"
    _,err = validation.check(test_string).not_empty()
    print(test_string, err)
   	_,err = validation.check(test_string).len(2,10)
    print(test_string, err)

    _,err = validation.check(test_string).type("number")
    print(test_string,err,true)

    test_string = ""
    _,err = validation.check(test_string).empty()
    print(test_string,err)
    _,err = validation.check(test_string).not_empty()
    print(test_string,err,true)

    local test_value
    _,err = validation.check(test_value).not_empty()
    print('nil',err,true)
    _,err = validation.check(test_value).empty()
    print('nil',err)

end

return test
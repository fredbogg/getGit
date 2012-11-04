-- ImportURL

-- Usage: importURL([tabname,] url)
function importURL(tabname, url)
    tabname, url = url and tabname, url or tabname

    if not tabname then
        tabname = url:sub(#url - url:reverse():find("/", 1) + 2, #url)
        tabname = tabname:sub(1, tabname:find("%.", 1) - 1)
    end

    http.request(url, function(data, status, headers)
        if status == 200 then
            saveProjectTab(tabname, data)
            print("Tab '"..tabname.."' created")
        else
            print("Failed to download '"..url.."' to '"..tabname.."'")
        end
    end)
end

---
-- getGit
-- This program uses a URL to find all the bits of a GitHub repo and replicate it.
-- usage: getGit("https://github.com/fredbogg/ABCplayerCodea")
function getGit(URLstring)
    
    print("Close this project and reopen it to see the new tabs. It should run straight away.")
    print("The Main tab will have moved to be first, and be aware that tab orders could change due to download times.")
    print("Credit to Rui Viana (ruilov) and toadkick for code and inspiration.")
    
    -- we change the URL a bit and assume the master branch is correct
    URL = string.sub(URLstring,1,8) .. "raw." .. string.sub(URLstring,9) .. "/master/"
    
    -- get the info.plist file for its list of tabs
    http.request(URL .. "Info.plist", httpSuccess, httpFail)
    
    -- hopefully go to success()
end

function httpSuccess(string)
    -- create the tabs one by one
    contents = string
    buffers = {}
    
    -- code from Rui Viana's GitHub client, https://github.com/ruilov/GitClient-Release 
---
    -- find the buffer order
    local bufferKey = "<key>Buffer Order</key>"
    local idx = contents:find(bufferKey)
    assert(idx~=nil,"Could not find buffer order.")
    contents = contents:sub(idx)
    
    -- find the end of the buffer order
    local idx2 = contents:find("</array>")
    assert(idx2~=nil,"Could not find the end of the buffer order.")
    contents = contents:sub(1,idx2)
    
    local buffers = {}
    for buff in contents:gmatch("<string>([%a%s%d]+)</string>") do
        table.insert(buffers,buff..".lua")
    end
---
-- end Rui's code

    -- make buffers
    for i = 1, #buffers do
        importURL(URL .. buffers[i])
    end
end

function httpFail(error)
    print("some kinda http problem")
    print(error)
end
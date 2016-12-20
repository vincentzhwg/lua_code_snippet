-- 

--ngx.log(ngx.ERR, "access_by_grbac.lua begin")

local sid = ngx.var["cookie_" .. COOKIE_YCFM_ACCOUNTS_NAME]
if not sid or sid == '' then
    --ngx.log(ngx.ERR, "sid empty")
    -- continue dealing request
    ngx.exit(ngx.OK)
end

-- ===== get sid value from redis ======
-- redis connect config
local config = {
    redis_session = SESSION_REDIS_YCFM_ACCOUNTS_CONFIG,
}
local redis_factory = require('redis_factory')(config) -- import config when construct
local ok, redis_sess = redis_factory:spawn('redis_session')
if not ok then
    ngx.header.content_type = 'text/plain; charset=utf-8'
    ngx.say('{"err_code":' .. ERROR_CODE_YCFM_ACCOUNTS_REDIS_CONFIG_WRONG .. ', "err_msg":"session redis connection config wrong"}')
    ngx.exit(ngx.HTTP_OK)
end

-- whether if sid exists
--sid = "test"
local sess_encoded_msgpack, err = redis_sess:get( sid )
if not sess_encoded_msgpack then
    ngx.header.content_type = 'text/plain; charset=utf-8'
    ngx.say('{"err_code":' .. ERROR_CODE_YCFM_ACCOUNTS_SESSION_NOT_WORK .. ', "err_msg":"session not work"}')
    ngx.exit(ngx.HTTP_OK)
end

redis_factory:destruct() -- important, better call this method on your main function return

if sess_encoded_msgpack == ngx.null then
    --ngx.log(ngx.ERR, "no exists, sid:", sid)
    -- continue dealing request
    ngx.exit(ngx.OK)
end


-- unpack into sess_data
local sess_data -- store session data, table
local mp = require 'MessagePack'
local succ, sess_data = pcall(mp.unpack, sess_encoded_msgpack)
if not succ then
    --ngx.log(ngx.ERR, "msgpack unpack error, sid:", sid)
    -- continue dealing request
    ngx.exit(ngx.OK)
end

--local inchuang_util = require 'inchuang_util'
--ngx.log(ngx.ERR, "msgpack data:", inchuang_util.serialize(sess_data))

-- set header
if sess_data["user_id"] ~= nil then
    --ngx.log(ngx.ERR, "add header user_id")
    ngx.req.set_header(HEADER_YCFM_ACCOUNTS_USER_ID, sess_data["user_id"])
end
if sess_data["company_id"] ~= nil then
    --ngx.log(ngx.ERR, "add header company_id")
    ngx.req.set_header(HEADER_YCFM_ACCOUNTS_COMPANY_ID, sess_data["company_id"])
end


--ngx.req.read_body()
--local bodyData = ngx.req.get_body_data()
--ngx.log(ngx.ERR, "body data:", bodyData)
--local res = ngx.location.capture('/v1/grbac/users/ttt', {method=ngx.HTTP_POST})
--ngx.log(ngx.ERR, res.status, res.body)

ngx.exit(ngx.OK)

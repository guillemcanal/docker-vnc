-- round a number
-- @param n A number.
local function round(n)
    return n % 1 >= 0.5 and math.ceil(n) or math.floor(n)
end

-- resize a remote session
-- @param pixel_doubling Double the pixel density.
local function resize_remote_session(pixel_doubling)
  local win             = hs.window.focusedWindow()
  local title           = win:title()
  local frame           = win:frame()
  local titlebar_height = 22
  
  -- Expecting a session name which contains the display number between parenthesis
  -- 
  -- @example "localhost:5900 (APP:0) - VNC Viewer"
  -- 
  -- A session name can be attributed:
  -- When starting a VNC server      (vncserver :0 -desktop=APP:0)
  -- By modifying a existing session (DISPLAY=:0 vncconfig -set desktop=APP:0)
  local display_num = string.match(title, "%d%f[%)]") 

  if win:isFullScreen() then
    titlebar_height = 0
  end

  local remote_width  = frame.w
  local remote_height = frame.h-titlebar_height
  if pixel_doubling then
    remote_width  = round(remote_width*2)
    remote_height = round(remote_height*2)
  end

  hs.execute(string.format("docker exec vnc change-geometry %s %s %s 60", display_num, remote_width, remote_height), true)

  win:setFrame(frame)

  hs.notify.new({
    title="VNC", 
    informativeText=string.format(
      "screen geometry set to\n%sx%s on screen %s", 
      remote_width, 
      remote_height, 
      display_num
    )
  }):send()
end

hs.hotkey.bind({"cmd", "alt"}, "H", function()
  resize_remote_session(true)
end)

hs.hotkey.bind({"cmd", "alt"}, "J", function()
  resize_remote_session(false)
end)

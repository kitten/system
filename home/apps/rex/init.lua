rex.bind("ctrl+0", "client.font.reset")

for _, modifier in ipairs({ "super", "ctrl" }) do
  for _, change in ipairs({ { "=", "increase" }, { "shift+=", "increase" }, { "-", "decrease" } }) do
    local action = "font_" .. change[2] .. "_two"
    -- Register each action once; queue twice to match Ghostty's two-point step.
    if modifier == "super" and change[1] ~= "shift+=" then
      local client_action = "client.font." .. change[2]
      rex.action {
        name = action,
        title = change[2] .. " font size by two",
        run = function()
          rex.client.queue(client_action)
          rex.client.queue(client_action)
        end,
      }
    end
    rex.bind(modifier .. "+" .. change[1], action)
  end
end

rex.bind("ctrl+a>z", "pane.zoom")
rex.bind("ctrl+a>x", "pane.close")
rex.bind("ctrl+a>f", "client.window.fullscreen.toggle")
rex.bind("ctrl+a>space", "client.prompt.next")
rex.bind("ctrl+a>shift+5", "pane.split", { direction = "right" })
rex.bind("ctrl+a>shift+'", "pane.split", { direction = "down" })
rex.bind("ctrl+a>d", "pane.split", { direction = "right" })
rex.bind("ctrl+a>s", "pane.split", { direction = "down" })
rex.bind("ctrl+a>n", "client.tab.next")
rex.bind("ctrl+a>p", "client.tab.previous")
rex.bind("ctrl+a>c", "client.tab.new")
rex.bind("ctrl+a>shift+n", "client.tab.move.forward")
rex.bind("ctrl+a>shift+p", "client.tab.move.backward")

for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  rex.bind("ctrl+" .. key, "pane.focus", { direction = direction })
  rex.bind("ctrl+a>" .. key, "pane.resize", { direction = direction, amount = 40 })
end
rex.bind("ctrl+a>g", "pane.balance")

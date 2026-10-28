-- ~/.config/rex/init.lua  (stow package: ~/dotfiles/rex)
-- After editing: `rex config check`, then `rex config reload`.
-- Verify action names your client supports with: `rex -C <label> actions`

local SHELL = "com.superlogical.terminal.shell"
local USER_SHELL = os.getenv("SHELL") or "/bin/zsh"
local HOME = os.getenv("HOME") or "/"

-- Expand a leading ~ ourselves: the path is shell-quoted below, which would
-- otherwise stop zsh from expanding it.
local function expand(p)
  if p == "~" then return HOME end
  return (p:gsub("^~/", HOME .. "/"))
end

-- POSIX single-quote, so directories with spaces survive the trip.
local function shq(s)
  return "'" .. (s:gsub("'", "'\\''")) .. "'"
end

-- Run a command in a directory, then drop back into an interactive shell so
-- the pane stays open if the command exits.
--
-- The outer `-ic` is deliberate and load-bearing: ~/.zshrc is what puts node,
-- pnpm and friends on PATH and defines aliases like `domorun`. A plain `-c`
-- shell never sources it, so a GUI-launched Rex (which inherits launchd's bare
-- PATH) would fail with "command not found".
local function in_dir(dir, cmd)
  local script = "cd " .. shq(expand(dir))
    .. (cmd and (" && " .. cmd) or "")
    .. "; exec " .. USER_SHELL
  return { USER_SHELL, "-ic", script }
end

----------------------------------------------------------------------
-- Panes
----------------------------------------------------------------------
rex.bind("cmd+d",       "pane.split", { direction = "right" })
rex.bind("shift+cmd+d", "pane.split", { direction = "down" })
rex.bind("cmd+e",       "pane.zoom")
rex.bind("cmd+w",       "pane.close")

-- Tabs 1-5 (physical keys, so they work on any layout)
for i = 1, 5 do
  rex.bind("cmd+[Digit" .. i .. "]", "client.tab.goto", { index = i })
end

-- Cmd+K clears the screen in the focused pane
rex.bind("cmd+k", "pane.send_key", { key = "ctrl+l" })

----------------------------------------------------------------------
-- Resize mode: Cmd+R, then arrows. Shift = big steps, = balances,
-- Enter/Escape leaves. Exclusive so stray keys don't hit the terminal.
----------------------------------------------------------------------
rex.mode("resize", { exclusive = true })
rex.bind("cmd+r", "client.mode.enter", { name = "resize" })

for _, dir in ipairs({ "left", "right", "up", "down" }) do
  rex.bind("resize/" .. dir, "pane.resize", { direction = dir })
  rex.bind("resize/shift+" .. dir, "pane.resize", { direction = dir, amount = 15 })
end
rex.bind("resize/=",     "pane.balance")
rex.bind("resize/enter", "client.mode.exit")

----------------------------------------------------------------------
-- Leader sequences (Ctrl+Space, then a key). Avoids stealing Ctrl+B
-- from programs that use it.
----------------------------------------------------------------------
rex.bind("ctrl+space>s", "session.switch")
rex.bind("ctrl+space>c", "client.tab.new")
rex.bind("ctrl+space>n", "client.tab.next")
rex.bind("ctrl+space>p", "client.tab.previous")
rex.bind("ctrl+space>f", "focus_mode")
rex.bind("ctrl+space>a", "claude_pair")
rex.bind("ctrl+space>d", "dev_layout")
rex.bind("ctrl+space>w", "domoweb")

----------------------------------------------------------------------
-- Custom actions (also in the command palette and `rex do <name>`)
----------------------------------------------------------------------

-- pnpm lives in the inner DomoWeb/ directory, not the repo root.
local DOMOWEB_DIR = HOME .. "/Dev/DomoWeb/DomoWeb"

-- Full DomoWeb working setup:
--   left  : interactive shell for git / tests / typecheck
--   right : dev server (top) and Claude Code (bottom)
--
--   rex do domoweb
--   rex do domoweb cmd=domoruntypecheck
--   rex do domoweb claude=false
rex.action{
  name     = "domoweb",
  title    = "Open DomoWeb Workspace",
  category = "Workflow",
  keywords = { "domo", "domoweb", "pnpm", "dev server", "work" },
  args     = { dir = "string?", cmd = "string?", ratio = "number?", claude = "boolean?" },
  run      = function(ctx, args)
    local dir   = args.dir or DOMOWEB_DIR
    local cmd   = args.cmd or "domorun"   -- alias from ~/.zshrc
    local ratio = args.ratio or 0.55

    local right
    if args.claude == false then
      right = rex.layout.block{ flavor = SHELL, options = { command = in_dir(dir, cmd) } }
    else
      right = rex.layout.vertical(0.6,
        rex.layout.block{ flavor = SHELL, options = { command = in_dir(dir, cmd) } },
        rex.layout.block{ flavor = SHELL, options = { command = in_dir(dir, "claude") } })
    end

    local w, err = rex.session.new_window{
      layout = rex.layout.horizontal(ratio,
        rex.layout.block{ flavor = SHELL, options = { command = in_dir(dir) } },
        right),
    }
    if err ~= nil then error(err, 0) end
    return { window_id = w.window_id }
  end,
}

-- Shell on the left, Claude Code on the right, in the given directory
rex.action{
  name     = "claude_pair",
  title    = "Open Claude Code Pair",
  category = "Workflow",
  keywords = { "ai", "claude", "agent" },
  args     = { dir = "string?", ratio = "number?" },
  run      = function(ctx, args)
    local dir = args.dir or os.getenv("PWD") or HOME
    local w, err = rex.session.new_window{
      layout = rex.layout.horizontal(args.ratio or 0.5,
        rex.layout.block{ flavor = SHELL, options = { command = in_dir(dir) } },
        rex.layout.block{ flavor = SHELL, options = { command = in_dir(dir, "claude") } }),
    }
    if err ~= nil then error(err, 0) end
    return { window_id = w.window_id }
  end,
}

-- Editor/shell on the left, dev server on the right
--   rex do dev_layout dir=~/code/tablewise cmd="npm run dev"
rex.action{
  name     = "dev_layout",
  title    = "Open Dev Layout",
  category = "Workflow",
  args     = { dir = "string?", cmd = "string?", ratio = "number?" },
  run      = function(ctx, args)
    local dir = args.dir or os.getenv("PWD") or HOME
    local w, err = rex.session.new_window{
      layout = rex.layout.horizontal(args.ratio or 0.6,
        rex.layout.block{ flavor = SHELL, options = { command = in_dir(dir) } },
        rex.layout.block{ flavor = SHELL, options = { command = in_dir(dir, args.cmd or "npm run dev") } }),
    }
    if err ~= nil then error(err, 0) end
    return { window_id = w.window_id }
  end,
}

-- Clean screen for screen-sharing / live coding interviews
rex.action{
  name     = "focus_mode",
  title    = "Focus Mode",
  category = "Workflow",
  keywords = { "present", "share", "interview" },
  run      = function(ctx, args)
    rex.client.queue("pane.zoom")
    rex.client.queue("client.sidebar.toggle")
  end,
}

-- Quick scratch window
rex.action{
  name  = "scratch",
  title = "Open Scratch Window",
  run   = function(ctx, args)
    rex.session.new_window{ layout = rex.layout.block{ flavor = SHELL } }
  end,
}
rex.bind("shift+cmd+n", "scratch")

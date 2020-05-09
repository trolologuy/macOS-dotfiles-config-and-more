--------------------------
-- CONFIGURATION       --
--------------------------
-- GLOBAL
hyper = {"ctrl", "alt", "cmd"}

--------------------------
-- SpoonInstall         --
--------------------------
-- Simplifies the installation of spoons
-- taken from here 
-- https://zzamboni.org/post/my-hammerspoon-configuration-with-commentary/
hs.loadSpoon("SpoonInstall")
Install=spoon.SpoonInstall

--------------------------
-- App bindings         --
--------------------------
-- Makes the switching from one app to another super easy
-- Taken from here
-- https://msol.io/blog/tech/work-more-efficiently-on-your-mac-for-developers/

local log = hs.logger.new('main', 'info')

-- focus on the last-focused window of every application given by name
function hyperFocusAll(key, ...)
    hs.hotkey.bind(hyper, key, mkFocusByPreferredApplicationTitle(false, ...))
end

-- creates callback function to select application windows by application name
function mkFocusByPreferredApplicationTitle(stopOnFirst, ...)
    local arguments = {...} -- create table to close over variadic args
    return function()
      local nowFocused = hs.window.focusedWindow()
      local appFound = false
      for _, app in ipairs(arguments) do
        if stopOnFirst and appFound then break end
        log:d('Searching for app ', app)
        local application = hs.application.get(app)
        if application ~= nil then
          log:d('Found app', application)
          local window = application:mainWindow()
          if window ~= nil then
            log:d('Found main window', window)
            if window == nowFocused then
              log:d('Already focused, moving on', application)
            else
              window:focus()
              appFound = true
            end
          end
        end
      end
      return appFound
    end
  end

-- focus on the last-focused window of the application given by name, or else launch it
function hyperFocusOrOpen(key, app)
    local focus = mkFocusByPreferredApplicationTitle(true, app)
    function focusOrOpen()
      return (focus() or hs.application.launchOrFocus(app))
    end
    hs.hotkey.bind(hyper, key, focusOrOpen)
end

function setUpAppBindings()
    hyperFocusOrOpen('w', 'Finder')
    hyperFocusOrOpen('c', 'Visual Studio Code')
    hyperFocusOrOpen('x', 'Firefox')
    hyperFocusOrOpen('v', 'Telegram')
    hyperFocusOrOpen('b', 'Rambox')
    hyperFocusOrOpen('n', 'Mailspring')
    hyperFocusOrOpen('s', 'spotify')
    hyperFocusOrOpen('g', 'lepton')
    hyperFocusOrOpen(',', 'iTerm2')
end
setUpAppBindings()


--------------------------
-- ClipboardTool        --
--------------------------
-- Displays the content of the clipboard
function setUpClipboardTool()
    ClipboardTool = hs.loadSpoon('ClipboardTool')
    ClipboardTool.show_in_menubar = false
    ClipboardTool:start()
    ClipboardTool:bindHotkeys({
      toggle_clipboard = {hyper, ";"}
    })
end
setUpClipboardTool()

--------------------------
-- Caffeine             --
--------------------------
-- One of the basic examples in the doc. Adds a menu in the toolbar giving the
-- opportunity to allow the machine to go to sleep or not
caffeine = hs.menubar.new()
function setCaffeineDisplay(state)
    if state then
        caffeine:setTitle("AWAKE")
    else
        caffeine:setTitle("SLEEPY")
    end
end

function caffeineClicked()
    setCaffeineDisplay(hs.caffeinate.toggle("displayIdle"))
end

if caffeine then
    caffeine:setClickCallback(caffeineClicked)
    setCaffeineDisplay(hs.caffeinate.get("displayIdle"))
end

--------------------------
-- Open folder          --
--------------------------
-- Opens a given folder using a specific shortcut
local function directoryLaunchKeyRemap(mods, key, dir)
    local mods = mods or {}
    hs.hotkey.bind(mods, key, function()
        local shell_command = "open " .. dir
        hs.execute(shell_command)
    end)
end

directoryLaunchKeyRemap(hyper, "1", "/Applications")

--------------------------
-- MenuHammer           --
--------------------------
-- Add an overlay menu with shortcuts to programs
menuHammer = hs.loadSpoon("MenuHammer")

menuHammerMenuList = {
    mainMenu = {
        parentMenu = nil,
        menuHotkey = {{'alt'}, 'space'},
        menuItems =  {
            {cons.cat.action, '', 'W', 'Organize the files', {
                {cons.act.shellcommand, "organize run"},
            }},
            {cons.cat.submenu, '', 'A', 'Applications', {
                  {cons.act.menu, "applicationMenu"}
            }},
            {cons.cat.action, '', 'T', "Terminal", {
                  {cons.act.launcher, 'Terminal'}
            }},
            {cons.cat.action, '', 'D', 'Desktop', {
                  {cons.act.launcher, 'Finder'},
                  {cons.act.keycombo, {'cmd', 'shift'}, 'd'},
            }},
            {cons.cat.action, '', 'E', "Split Safari/iTunes", {
                {cons.act.func, function()
                      -- See Hammerspoon layout documentation for more info on this
                      local mainScreen = hs.screen{x=0,y=0}
                      hs.layout.apply({
                              {"Safari", nil, mainScreen, hs.layout.left50, nil, nil},
                              {"iTunes", nil, mainScreen, hs.layout.right50, nil, nil},
                      })
                end }
            }},
            {cons.cat.action, '', 'H', "Hammerspoon Manual", {
                  {cons.act.func, function()
                      hs.doc.hsdocs.forceExternalBrowser(true)
                      hs.doc.hsdocs.moduleEntitiesInSidebar(true)
                      hs.doc.hsdocs.help()
                  end }
            }},
            {cons.cat.action, '', 'M', 'MenuHammer Default Config', {
                {cons.act.openfile, "~/.hammerspoon/Spoons/MenuHammer.spoon/MenuConfigDefaults.lua"},
            }},
            {cons.cat.action, '', 'X', "Mute/Unmute", {
                  {cons.act.mediakey, "mute"}
            }},
        }
    },
    applicationMenu = {
        parentMenu = "mainMenu",
        menuHotkey = nil,
        menuItems = {
            {cons.cat.action, '', 'A', "App Store", {
                  {cons.act.launcher, 'App Store'}
            }},
        }
    },
}

menuHammer:enter()

--------------------------
-- DeepLTranslate       --
--------------------------
-- Opens a Deepl translation tool overlay. If you select text and wait
-- it will automatically fill out the text field
DeepLTranslate = hs.loadSpoon("DeepLTranslate")

hs.hotkey.bind(hyper, "d", function()
    hs.alert.show("Pressed cmd + alt + ctrl + d")
    DeepLTranslate:translateSelectionPopup()
  end)


--------------------------
-- MountedVolumes       --
--------------------------
-- Displays he available disk space for every mounted hard drive 
-- as an overlay on the finder
MountedVolumes = hs.loadSpoon("MountedVolumes")

hs.hotkey.bind(hyper, "a", function()
    hs.alert.show("Pressed cmd + alt + ctrl + a")
    MountedVolumes:show()
  end)

--------------------------
-- KSheet               --
--------------------------
-- Generates a Cheatsheet for the current app
Install:andUse("KSheet",
    {
        hotkeys = { 
            toggle = { hyper, ":" }
        }
    }
)

--------------------------
-- Time Machine backup  --
--------------------------
-- When plugging in a time machine harddrive 
-- It displays the percentage of the backup progress in the menu bar
Install:andUse("TimeMachineProgress",
    {
        start = true
    }
)

--------------------------
-- Shade                --
--------------------------
-- Used to work in a dark environment ?
-- Shade allows to reduce the brightness of the screen
-- in a more helpful way than to actually reduce the screen brightness
hs.loadSpoon("Shade")

hs.hotkey.bind(hyper, "q", function()
    hs.alert.show("Running shade")
    Shade:toggleShade()
end)

--------------------------
-- HoldToQuit           --
--------------------------
-- Tired of closing the apps by mistake ? 
local obj = hs.loadSpoon("HoldToQuit")
    obj:init()
    obj:start()

--------------------------
-- Wifi Notifier        --
--------------------------
-- Notifies you when the network changes
local obj = hs.loadSpoon("WifiNotifier")
    obj:init()
    obj:start()

--------------------------
-- MiroWindowsManager   --
--------------------------
-- Very usefull to resize windows
hs.loadSpoon("MiroWindowsManager")

hs.window.animationDuration = 0.3
spoon.MiroWindowsManager:bindHotkeys({
  up = {hyper, "up"},
  right = {hyper, "right"},
  down = {hyper, "down"},
  left = {hyper, "left"},
  fullscreen = {hyper, "f"}
})


--------------------------
-- reloadConfig         --
--------------------------
-- Automatically reloads the hammerspoon config on save
function reloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end

myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config loaded")

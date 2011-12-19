-- xmonad config used by Vic Fryzel
-- Author: Vic Fryzel
-- http://github.com/vicfryzel/xmonad-config

import System.IO
import System.Exit

import XMonad hiding ( (|||) )

import XMonad.Actions.Search
import XMonad.Actions.WindowGo
import qualified XMonad.Actions.Submap as SM

import XMonad.Prompt
import XMonad.Prompt.Input
import XMonad.Prompt.RunOrRaise
import XMonad.Prompt.Shell
import XMonad.Prompt.Window
import XMonad.Prompt.AppLauncher as AL
import XMonad.Prompt.Layout

import XMonad.Hooks.FadeInactive
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.UrgencyHook

import XMonad.Layout hiding ( (|||) )
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LayoutCombinators
import XMonad.Layout.ResizableTile
import XMonad.Layout.NoBorders
import XMonad.Layout.Spiral
import XMonad.Layout.Tabbed
import XMonad.Layout.Grid
import XMonad.Layout.LayoutHints
import XMonad.Layout.Named
import XMonad.Layout.PerWorkspace
import qualified XMonad.Layout.Magnifier as Mag

import XMonad.Util.WorkspaceCompare
import XMonad.Util.Scratchpad
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Util.XSelection
import XMonad.Util.NamedWindows (getName)

import XMonad.Actions.UpdatePointer

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

myTerminal      = "exec urxvtc"
myBorderWidth   = 2
myModMask       = mod4Mask

myWorkspaces    = ["comm","web","irc","4","5","6","7","music","vm"]

-- prompts
mySP = defaultXPConfig
       { font = "xft:Envy Code R:pixelsize=10"
       , bgColor           = "#222222"
       , fgColor           = "#f2f2f2"
       , fgHLight          = "#f2f2f2"
       , bgHLight          = "#f30085"
       , borderColor       = "#f30085"
       , promptBorderWidth = 0
       , position          = Top
       , height            = 22
       , defaultText       = []
       }

myAutoSP = mySP { autoComplete = Just 1000 }
myWaitSP = mySP { autoComplete = Just 1000000 }

searchEngineMap method = M.fromList $
    [ ((0, xK_g), method google)
    , ((0, xK_w), method wikipedia) ]

myLayoutPrompt = inputPromptWithCompl myAutoSP "Layout"
                 (mkComplFunFromList' ["1.tall", "2.wide", "3.tabs", "4.Full", "5.Spiral", "6.grid"]) ?+ \l ->
                     sendMessage $ JumpToLayout $ drop 2 l
------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
    [ ((modMask, xK_Return), spawn $ XMonad.terminal conf)-- launch a terminal
    , ((modMask .|. controlMask, xK_l   ), spawn "~/.xmonad/lock.sh")
    , ((modMask .|. controlMask, xK_F12 ), spawn "~/.xmonad/setxkbmap.sh us")
    , ((modMask .|. controlMask, xK_F11 ), spawn "~/.xmonad/setxkbmap.sh hu")
    , ((modMask .|. controlMask, xK_F8  ), spawn "urxvt -title mocp -e mocp")
    , ((0, 0x1008ff11                   ), spawn "amixer set Master 1-")
    , ((0, 0x1008ff13                   ), spawn "amixer set Master 1+")

    -- prompts
    , ((modMask,               xK_grave ), scratchpadSpawnAction conf) -- quake terminal
    , ((modMask .|. controlMask, xK_o   ), promptSelection "firefox")
    , ((modMask .|. controlMask, xK_s   ), transformSafePromptSelection ("http://google.com/search?q=" ++) "firefox")
    , ((modMask .|. controlMask, xK_w   ), windowPromptGoto myWaitSP)
    , ((modMask .|. controlMask, xK_e   ), windowPromptBring myWaitSP)
    , ((modMask .|. controlMask, xK_slash), (SM.submap $ searchEngineMap $ promptSearch mySP)
                                               >> raise (className =? "Firefox"))
    , ((modMask .|. controlMask, xK_period), myLayoutPrompt) -- layout prompt

    , ((modMask,               xK_p     ), spawn "~/.xmonad/dmenu.sh")-- launch dmenu

    , ((modMask .|. shiftMask, xK_c     ), kill)-- close focused window

    , ((modMask,               xK_space ), sendMessage NextLayout)-- Rotate through the available layout algorithms
    , ((modMask .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)--  Reset the layouts on the current workspace
    , ((modMask,               xK_n     ), refresh)-- Resize viewed windows to the correct size
    , ((modMask,               xK_Tab   ), windows W.focusDown)-- Move focus to the next window
    , ((modMask,               xK_j     ), windows W.focusDown)-- Move focus to the next window
    , ((modMask,               xK_k     ), windows W.focusUp  )-- Move focus to the previous window
    , ((modMask,               xK_m     ), windows W.focusMaster  )-- Move focus to the master window
    , ((modMask .|. shiftMask, xK_m     ), windows W.swapMaster)-- Swap the focused window and the master window
    , ((modMask .|. shiftMask, xK_j     ), windows W.swapDown  )-- Swap the focused window with the next window
    , ((modMask .|. shiftMask, xK_k     ), windows W.swapUp    )-- Swap the focused window with the previous window
    , ((modMask,               xK_h     ), sendMessage Shrink)-- Shrink the master area
    , ((modMask,               xK_l     ), sendMessage Expand)-- Expand the master area
    , ((modMask,               xK_u     ), sendMessage ToggleStruts)
    , ((modMask,               xK_t     ), withFocused $ windows . W.sink)-- Push window back into tiling
    , ((modMask              , xK_comma ), sendMessage (IncMasterN 1))-- Increment the number of windows in the master area
    , ((modMask              , xK_period), sendMessage (IncMasterN (-1)))-- Deincrement the number of windows in the master area
    , ((modMask .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))-- Quit xmonad
    , ((modMask              , xK_q     ), restart "xmonad" True)-- Restart xmonad
    ]
    ++
    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modMask, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++
    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $
    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modMask, button1), (\w -> focus w >> mouseMoveWindow w))
    -- mod-button2, Raise the window to the top of the stack
    , ((modMask, button2), (\w -> focus w >> windows W.swapMaster))
    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modMask, button3), (\w -> focus w >> mouseResizeWindow w))
    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
myNormalBorderColor  = "#222222"
myFocusedBorderColor = "#f30085"
myTabConfig = defaultTheme {   activeBorderColor = "#f30085"
                             , activeTextColor = "#f2f2f2"
                             , activeColor = "#f30085"
                             , inactiveBorderColor = "#222222"
                             , inactiveTextColor = "#f2f2f2"
                             , inactiveColor = "#222222" }

myLayout = smartBorders
           $ layoutHints
           $ onWorkspace "irc" irc
           $ onWorkspace "web" tabs
           $ onWorkspace "vm" Full
           $ avoidStruts
           $ basicLayout
  where
     basicLayout = tall ||| wide ||| tabs ||| spiral (6/7) ||| mgrid ||| Full
     tabs    = named "tabs" $ avoidStruts $ tabbed shrinkText myTabConfig
     tall    = named "tall" $ Tall nmaster delta ratio
     irc     = (named "irc" $ avoidStruts $ Tall 1 0 (1/2)) ||| tall
     wide    = named "wide" $ Mirror tall
     mgrid   = named "grid" $ Mag.magnifiercz 1.2 $ Grid
     nmaster = 1
     ratio   = 2/3
     delta   = 3/100

------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
composeRules = composeOne $
                  [ transience ]
               ++ [ resource  =? c -?> doIgnore  | c      <- ignoreR ]
               ++ [ resource  =? c -?> doFloat   | c      <- floatR ]
               ++ [ className =? c -?> doFloat   | c      <- floatC ]
               ++ [ className =? c -?> doShift w | (c, w) <- shiftC ]
               ++ [ title     =? c -?> doFloat   | c      <- floatT ]
               ++ [ title     =? c -?> doShift w | (c, w) <- shiftT ]
  where
     ignoreR = [ "desktop_window", "kdesktop" ]
     floatC  = [ "MPlayer", "Vlc", "Smplayer", "Gimp", "Exe", "<unknown>" ]
     floatT  = [ "Grafika hazi feladat" ]
     floatR  = [ "compose", "plugin-container" ]
     shiftC  = [ ("VirtualBox",    "vm" )
               , ( "Transmission-gtk", "irc" )
               , ( "Keepassx",     "5" )
               , ( "Skype",        "irc" ) ]
     shiftT  = [ ( "mocp",         "music" )
               , ( "k2net",        "irc" ) ]


myManageHook = manageDocks
               <+> composeRules
               <+> scratchpadManageHook (W.RationalRect 0 0 1 0.3)
               <+> manageHook defaultConfig

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'DynamicLog' extension for examples.
--
-- To emulate dwm's status bar
--
-- > logHook = dynamicLogDzen
--

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = return ()

myXmobarPP xmproc = xmobarPP
             { ppOutput = hPutStrLn xmproc
             , ppTitle = xmobarColor "#f30085" "" . shorten 100
             , ppCurrent = xmobarColor "#f30085" ""
             , ppUrgent = xmobarColor "#FF0000" "" . xmobarStrip
             , ppLayout = wrap " [" "] "
             , ppSort = fmap (.scratchpadFilterOutWorkspace) getSortByIndex
             , ppSep = "  "
             }

main = do
    xmproc <- spawnPipe "exec /usr/bin/xmobar ~/.xmonad/xmobar"
    xmonad $ withUrgencyHook NoUrgencyHook defaultConfig
             { terminal           = myTerminal
             , focusFollowsMouse  = myFocusFollowsMouse
             , borderWidth        = myBorderWidth
             , modMask            = myModMask
             , workspaces         = myWorkspaces
             , normalBorderColor  = myNormalBorderColor
             , focusedBorderColor = myFocusedBorderColor

             -- key binding
             , keys               = myKeys
             , mouseBindings      = myMouseBindings

             -- hooks, layouts
             , layoutHook         = myLayout
             , manageHook         = myManageHook
             , logHook = (dynamicLogWithPP $ myXmobarPP xmproc)
                          >> updatePointer (Relative 0.5 0.5)
                          >> fadeInactiveLogHook 0.85
             , startupHook        = myStartupHook
             }

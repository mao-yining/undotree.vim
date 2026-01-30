vim9script
# File: autoload/undotree.vim
# Description: Manage your undo history in a graph.
# Author: Mao-Yining <mao.yining@outlook.com>
# License: Apache 2.0

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

# 	http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# Options:
#
# Window layout
# style 1
# +----------+------------------------+
# |          |                        |
# |          |                        |
# | undotree |                        |
# |          |                        |
# |          |                        |
# +----------+                        |
# |          |                        |
# |   diff   |                        |
# |          |                        |
# +----------+------------------------+
# Style 2
# +----------+------------------------+
# |          |                        |
# |          |                        |
# | undotree |                        |
# |          |                        |
# |          |                        |
# +----------+------------------------+
# |                                   |
# |   diff                            |
# |                                   |
# +-----------------------------------+
# Style 3
# +------------------------+----------+
# |                        |          |
# |                        |          |
# |                        | undotree |
# |                        |          |
# |                        |          |
# |                        +----------+
# |                        |          |
# |                        |   diff   |
# |                        |          |
# +------------------------+----------+
# Style 4
# +-----------------------++----------+
# |                        |          |
# |                        |          |
# |                        | undotree |
# |                        |          |
# |                        |          |
# +------------------------+----------+
# |                                   |
# |                            diff   |
# |                                   |
# +-----------------------------------+
if !exists('g:undotree_WindowLayout')
    g:undotree_WindowLayout = 1
endif

# e.g. using 'd' instead of 'days' to save some space.
if !exists('g:undotree_ShortIndicators')
    g:undotree_ShortIndicators = false
endif

# undotree window width
if !exists('g:undotree_SplitWidth')
    if g:undotree_ShortIndicators
        g:undotree_SplitWidth = 24
    else
        g:undotree_SplitWidth = 30
    endif
endif

# diff window height
if !exists('g:undotree_DiffpanelHeight')
    g:undotree_DiffpanelHeight = 10
endif

# auto open diff window
if !exists('g:undotree_DiffAutoOpen')
    g:undotree_DiffAutoOpen = true
endif

# if set, let undotree window get focus after being opened, otherwise
# focus will stay in current window.
if !exists('g:undotree_SetFocusWhenToggle')
    g:undotree_SetFocusWhenToggle = false
endif

# tree node shape.
if !exists('g:undotree_TreeNodeShape')
    g:undotree_TreeNodeShape = '*'
endif

# tree vertical shape.
if !exists('g:undotree_TreeVertShape')
    g:undotree_TreeVertShape = '|'
endif

# tree split shape.
if !exists('g:undotree_TreeSplitShape')
    g:undotree_TreeSplitShape = '/'
endif

# tree return shape.
if !exists('g:undotree_TreeReturnShape')
    g:undotree_TreeReturnShape = '\'
endif

if !exists('g:undotree_DiffCommand')
    g:undotree_DiffCommand = "diff"
endif

# relative timestamp
if !exists('g:undotree_RelativeTimestamp')
    g:undotree_RelativeTimestamp = true
endif

# Highlight changed text
if !exists('g:undotree_HighlightChangedText')
    g:undotree_HighlightChangedText = true
endif

# Highlight changed text using signs in the gutter
if !exists('g:undotree_HighlightChangedWithSign')
    g:undotree_HighlightChangedWithSign = true
endif

# Highlight linked syntax type.
# You may chose your favorite through ":hi" command
if !exists('g:undotree_HighlightSyntaxAdd')
    g:undotree_HighlightSyntaxAdd = "DiffAdd"
endif
if !exists('g:undotree_HighlightSyntaxChange')
    g:undotree_HighlightSyntaxChange = "DiffChange"
endif
if !exists('g:undotree_HighlightSyntaxDel')
    g:undotree_HighlightSyntaxDel = "DiffDelete"
endif

# Signs to display in the gutter where the file has been modified
if !exists('g:undotree_SignAdded')
    g:undotree_SignAdded = "++"
endif
if !exists('g:undotree_SignChanged')
    g:undotree_SignChanged = "~~"
endif
if !exists('g:undotree_SignDeleted')
    g:undotree_SignDeleted = "--"
endif
if !exists('g:undotree_SignDeletedEnd')
    g:undotree_SignDeletedEnd = "-v"
endif

# Show help line
if !exists('g:undotree_HelpLine')
    g:undotree_HelpLine = true
endif

# Show cursorline
if !exists('g:undotree_CursorLine')
    g:undotree_CursorLine = true
endif

# Set statusline
if !exists('g:undotree_StatusLine')
    g:undotree_StatusLine = true
endif

# Ignored filetypes
if !exists('g:undotree_DisabledFiletypes')
    g:undotree_DisabledFiletypes = []
endif

# Ignored buftypes
if !exists('g:undotree_DisabledBuftypes')
    g:undotree_DisabledBuftypes = ['terminal', 'prompt', 'quickfix', 'nofile']
endif

# Define the default persistence undo directory if not defined in vim/nvim
# startup script.
if !exists('g:undotree_UndoDir')
    g:undotree_UndoDir = &undodir == '.' ? $HOME .. '/.local/state/vim/undo/'
        : &undodir
endif

var timeSecond: string
var timeSeconds: string

var timeMinute: string
var timeMinutes: string

var timeHour: string
var timeHours: string

var timeDay: string
var timeDays: string

var timeOriginal: string

# Short time indicators
if g:undotree_ShortIndicators
    timeSecond  = '1 s'
    timeSeconds = ' s'

    timeMinute  = '1 m'
    timeMinutes = ' m'

    timeHour  = '1 h'
    timeHours = ' h'

    timeDay  = '1 d'
    timeDays = ' d'

    timeOriginal = 'Orig'
else
    timeSecond = '1 second ago'
    timeSeconds = ' seconds ago'

    timeMinute  = '1 minute ago'
    timeMinutes = ' minutes ago'

    timeHour  = '1 hour ago'
    timeHours = ' hours ago'

    timeDay  = '1 day ago'
    timeDays = ' days ago'

    timeOriginal = 'Original'
endif

# Help text
var helpmore: list<string> = [
    '#    ===== Marks ===== ',
    '# >num< : The current state',
    '# {num} : The next redo state',
    '# [num] : The latest state',
    '# =num= : The diff mark',
    '#   s   : Saved states',
    '#   S   : The last saved state',
    '#   ===== Hotkeys =====']
var helpless: list<string>
if !g:undotree_HelpLine
    helpless = []
else
    helpless = ['# Press ? for help.']
endif

# Custom key mappings: add this function to your vimrc.
# You can define whatever mapping as you like, this is a hook function which
# will be called after undotree window initialized.
#
# def g:Undotree_CustomMap()
#    map <buffer> <C-N> J
#    map <buffer> <C-P> K
# enddef

# Keymap
var keymap: list<list<string>>
# action, key, help.
keymap += [['Help', '?', 'Toggle quick help']]
keymap += [['Close', 'q', 'Close undotree panel']]
keymap += [['FocusTarget', '<Tab>', 'Set Focus back to the editor']]
keymap += [['ClearHistory', 'C', 'Clear undo history (with confirmation)']]
keymap += [['TimestampToggle', 'T', 'Toggle relative timestamp']]
keymap += [['DiffToggle', 'D', 'Toggle the diff panel']]
keymap += [['DiffMark', '=', 'Set the diff marker']]
keymap += [['ClearDiffMark', 'M', 'Clear the diff marker']]
keymap += [['NextState', 'K', 'Move to the next undo state']]
keymap += [['PreviousState', 'J', 'Move to the previous undo state']]
keymap += [['NextSavedState', '>', 'Move to the next saved state']]
keymap += [['PreviousSavedState', '<', 'Move to the previous saved state']]
keymap += [['Redo', '<C-R>', 'Redo']]
keymap += [['Undo', 'u', 'Undo']]
keymap += [['Enter', '<2-LeftMouse>', 'Move to the current state']]
keymap += [['Enter', '<CR>', 'Move to the current state']]

# 'Diff' sign definitions. There are two 'delete' signs; a 'normal' one and one
# that is used if the very end of the buffer has been deleted (in which case the
# deleted text is actually beyond the end of the current buffer version and therefore
# it is not possible to place a sign on the exact line - because it doesn't exist.
# Instead, a 'special' delete sign is placed on the (existing) last line of the
# buffer)
exe $'sign define UndotreeAdd text={g:undotree_SignAdded} texthl={g:undotree_HighlightSyntaxAdd}'
exe $'sign define UndotreeChg text={g:undotree_SignChanged} texthl={g:undotree_HighlightSyntaxChange}'
exe $'sign define UndotreeDel text={g:undotree_SignDeleted} texthl={g:undotree_HighlightSyntaxDel}'
exe $'sign define UndotreeDelEnd text={g:undotree_SignDeletedEnd} texthl={g:undotree_HighlightSyntaxDel}'

# Id to use for all signs. This is an arbitrary number that is hoped to be unique
# within the instance of vim. There is no way of guaranteeing it IS unique, which
# is a shame because it needs to be!
#
# Note that all signs are placed with the same Id - as long as we keep a count of
# how many we have placed (so we can remove them all again), this is ok
var signId = 2123654789

# Get formatted time
def GetTime(time: number): string
    if time == 0
        return timeOriginal
    endif
    if !g:undotree_RelativeTimestamp
        var today = substitute(strftime("%c", localtime()), " .*$", '', 'g')
        if today == substitute(strftime("%c", time), " .*$", '', 'g')
            return strftime("%H:%M:%S", time)
        else
            return strftime("%H:%M:%S %b%d %Y", time)
        endif
    else
        var sec = localtime() - time
        if sec < 0
            sec = 0
        endif
        if sec < 60
            if sec == 1
                return timeSecond
            else
                return sec .. timeSeconds
            endif
        endif
        if sec < 3600
            if (sec / 60) == 1
                return timeMinute
            else
                return (sec / 60) .. timeMinutes
            endif
        endif
        if sec < 86400 # 3600 * 24
            if (sec / 3600) == 1
                return timeHour
            else
                return (sec / 3600) .. timeHours
            endif
        endif
        if (sec / 86400) == 1
            return timeDay
        else
            return (sec / 86400) .. timeDays
        endif
    endif
enddef

def Exec(cmd: string)
    Log("Exec() " .. cmd)
    silent exe cmd
enddef

# Don't trigger any events(like BufEnter which could cause redundant refresh)
def Exec_silent(cmd: string)
    Log("Exec_silent() " .. cmd)
    const ei_bak = &eventignore
    set eventignore=BufEnter,BufLeave,BufWinLeave,InsertLeave,CursorMoved,BufWritePost
    silent exe cmd
    &eventignore = ei_bak
enddef

# Return a unique id each time.
var cntr = 0
def GetUniqueID(): number
    cntr = cntr + 1
    return cntr
enddef

# Set to 1 to enable debug log
var debug = false
const debugfile = $HOME .. '/undotree_debug.log'
# If debug file exists, enable debug output.
if filewritable(debugfile)
    debug = true
    exec 'redir >> ' .. debugfile
    silent echo "=======================================\n"
    redir END
endif

def Log(msg: string)
    if debug
        exec 'redir >> ' .. debugfile
        silent echon strftime('%H:%M:%S') .. ': ' .. string(msg) .. "\n"
        redir END
    endif
enddef

def ObserveOptions()
    augroup Undotree_OptionsObserver
        try
            autocmd!
            if exists('+fdo')
                open_folds = &fdo =~# 'undo'
                if exists('##OptionSet')
                    autocmd OptionSet foldopen open_folds = v:option_new =~# 'undo'
                endif
            endif
        finally
    augroup END
        endtry
enddef

# Whether to open folds on undo/redo.
# Is 1 when 'undo' is in &fdo (see :help 'foldopen').
# default: 1
var open_folds = true

if exists('v:vim_did_enter')
    if !v:vim_did_enter
        autocmd VimEnter * ObserveOptions()
    else
        ObserveOptions()
    endif
else
    autocmd VimEnter * ObserveOptions()
    ObserveOptions()
endif

# Base class for panels.
class Panel
    var bufname = "invalid"

    def SetFocus()
        var winnr = bufwinnr(this.bufname)
        # already focused.
        if winnr == winnr()
            return
        endif
        if winnr == -1
            echoerr "Fatal: window does not exist!"
            return
        endif
        Log("SetFocus() winnr:" .. winnr .. " bufname:" .. this.bufname)
        # wincmd would cause cursor outside window.
        Exec_silent("norm! " .. winnr .. "\<c-w>\<c-w>")
    enddef

    def IsVisible(): bool
        if bufwinnr(this.bufname) != -1
            return true
        else
            return false
        endif
    enddef

    def Hide()
        Log(this.bufname .. " Hide()")
        if !this.IsVisible()
            return
        endif
        this.SetFocus()
        Exec("quit")
    enddef
endclass

# undotree panel class.
# extended from panel.
#

# {rawtree}
#     |
#     | ConvertInput()               {seq2index}--> [seq1:index1]
#     v                                             [seq2:index2] ---+
#  {tree}                                               ...          |
#     |                                    [asciimeta]               |
#     | Render()                                |                    |
#     v                                         v                    |
# [asciitree] --> [" * | SEQ DDMMYY "] <==> [node1{seq, time, ..}]     |
#                 [" |/             "]      [node2{seq, time, ..}] <---+
#                         ...                       ...


# tree node class
class Node
    var seq = -1
    var time = -1
    public var p: list<Node>
endclass

class Undotree extends Panel

    def new()
        this.bufname = "undotree_" .. GetUniqueID()
    enddef

    # Increase to make it unique.
    public var width = g:undotree_SplitWidth
    var opendiff = g:undotree_DiffAutoOpen
    var diffmark = -1 # Marker for the diff view
    var targetid: string
    var targetBufnr = -1
    var rawtree: dict<any>  # data passed from undotree()
    var tree: Node     # data converted to internal format.
    var seq_last = -1
    var save_last = -1
    var save_last_bak = -1

    # seqs
    var seq_cur = -1
    var seq_curhead = -1
    var seq_newhead = -1
    var seq_saved: dict<number> # {saved value -> seq} pair

    # backup, for mark
    var seq_cur_bak = -1
    var seq_curhead_bak = -1
    var seq_newhead_bak = -1

    var asciitree: list<string>     # output data.
    var asciimeta: list<Node>       # meta data behind ascii tree.
    var seq2index: dict<number>     # table used to convert seq to index.
    var showHelp: bool

    def BindKey()
        var map_options = '<nowait><silent><buffer>'
        for i in keymap
            silent exec $'nmap {map_options}{i[1]} <Plug>Undotree{i[0]}'
            silent exec $'nnoremap {map_options}<Plug>Undotree{i[0]} <ScriptCmd>UndotreeAction("{i[0]}")<CR>'
        endfor
        if exists('*g:Undotree_CustomMap')
            g:Undotree_CustomMap()
        endif
    enddef

    def BindAu()
        # Auto exit if it's the last window
        augroup Undotree_Main
            au!
            au BufEnter <buffer> ExitIfLast()
            au BufEnter,BufLeave <buffer> {
                if exists('t:undotree')
                    t:undotree.width = winwidth(winnr())
                endif
            }
            au WinClosed <buffer> {
                if exists('t:undotree')
                    t:undotree.ActionClose()
                endif
            }
            au BufWinLeave <buffer> {
                if exists('t:diffpanel')
                    t:diffpanel.Hide()
                endif
            }
        augroup END
    enddef

    def Action(action: string)
        Log("undotree.Action() " .. action)
        if !this.IsVisible() || !exists('b:isUndotreeBuffer')
            echoerr "Fatal: window does not exist."
            return
        endif
        if action == 'Help'
            this.ActionHelp()
        elseif action == 'FocusTarget'
            this.ActionFocusTarget()
        elseif action == 'Enter'
            this.ActionEnter()
        elseif action == 'Undo'
            this.ActionUndo()
        elseif action == 'Redo'
            this.ActionRedo()
        elseif action == 'PreviousState'
            this.ActionPreviousState()
        elseif action == 'NextState'
            this.ActionNextState()
        elseif action == 'PreviousSavedState'
            this.ActionPreviousSavedState()
        elseif action == 'NextSavedState'
            this.ActionNextSavedState()
        elseif action == 'DiffMark'
            this.ActionDiffMark()
        elseif action == 'ClearDiffMark'
            this.ActionClearDiffMark()
        elseif action == 'DiffToggle'
            this.ActionDiffToggle()
        elseif action == 'TimestampToggle'
            this.ActionTimestampToggle()
        elseif action == 'ClearHistory'
            this.ActionClearHistory()
        elseif action == 'Close'
            this.ActionClose()
        else
            echoerr "Fatal: Action does not exist!"
        endif
    enddef

    # Helper function, do action in target window, and then update itthis.
    def ActionInTarget(cmd: string)
        if !this.SetTargetFocus()
            return
        endif
        # Target should be a normal buffer.
        if (&bt == '' || &bt == 'acwrite') && &modifiable && (mode() == 'n')
            Exec(cmd)
            # Open folds so that the change being undone/redone is visible.
            if open_folds
                Exec('normal! zv')
            endif
            this.Update()
        endif
        # Update not always set current focus.
        this.SetFocus()
    enddef

    def ActionHelp()
        this.showHelp = !this.showHelp
        this.Draw()
        this.MarkSeqs(true)
    enddef

    def ActionFocusTarget()
        this.SetTargetFocus()
    enddef

    def ActionEnter()
        var index = this.Screen2Index(line('.'))
        if index < 0
            return
        endif
        var seq = this.asciimeta[index].seq
        if seq == -1
            return
        endif
        if seq == 0
            this.ActionInTarget('norm 9999u')
            return
        endif
        this.ActionInTarget('u ' .. this.asciimeta[index].seq)
    enddef

    def ActionUndo()
        this.ActionInTarget('undo')
    enddef

    def ActionRedo()
        this.ActionInTarget("redo")
    enddef

    def ActionPreviousState()
        this.ActionInTarget('earlier')
    enddef

    def ActionNextState()
        this.ActionInTarget('later')
    enddef

    def ActionPreviousSavedState()
        this.ActionInTarget('earlier 1f')
    enddef

    def ActionNextSavedState()
        this.ActionInTarget('later 1f')
    enddef

    def ActionDiffMark()
        var index = this.Screen2Index(line('.'))
        if index < 0
            return
        endif
        var seq = this.asciimeta[index].seq
        if seq == -1
            return
        endif
        if seq == this.diffmark
            this.diffmark = -1
        else
            this.diffmark = seq
        endif
        this.UpdateDiff()
        this.Draw()
        this.MarkSeqs(false)
    enddef

    def ActionClearDiffMark()
        this.diffmark = -1
        this.UpdateDiff()
        this.Draw()
        this.MarkSeqs(true)
    enddef

    def ActionDiffToggle()
        this.opendiff = !this.opendiff
        t:diffpanel.Toggle()
        this.UpdateDiff()
    enddef

    def ActionTimestampToggle()
        if !this.SetTargetFocus()
            return
        endif
        g:undotree_RelativeTimestamp = !g:undotree_RelativeTimestamp
        this.targetBufnr = -1 # force update
        this.Update()
        # Update not always set current focus.
        this.SetFocus()
    enddef

    def ActionClearHistory()
        if input("Clear ALL undo history? Type \"YES\" to continue: ") != "YES"
            return
        endif
        if !this.SetTargetFocus()
            return
        endif
        var ul_bak = &undolevels
        var mod_bak = &modified
        &undolevels = -1
        Exec("norm! a \<BS>\<Esc>")
        &undolevels = ul_bak
        &modified = mod_bak
        this.targetBufnr = -1 # force update
        this.Update()
    enddef

    def ActionClose()
        this.Toggle()
    enddef

    def UpdateDiff()
        Log("undotree.UpdateDiff()")
        if !t:diffpanel.IsVisible()
            return
        endif
        t:diffpanel.Update(this.seq_cur, this.targetBufnr, this.targetid, this.diffmark)
    enddef

    # May fail due to target window closed.
    def SetTargetFocus(): bool
        for winnr in range(1, winnr('$')) # winnr starts from 1
            if getwinvar(winnr, 'undotree_id') == this.targetid
                if winnr() != winnr
                    Exec_silent("norm! " .. winnr .. "\<c-w>\<c-w>")
                    return 1
                endif
            endif
        endfor
        return 0
    enddef

    def Toggle()
        # Global auto commands to keep undotree up to date.
        Log(this.bufname .. " Toggle()")
        if this.IsVisible()
            this.Hide()
            t:diffpanel.Hide()
            this.SetTargetFocus()
            augroup Undotree
                autocmd!
            augroup END
        else
            this.Show()
            if !g:undotree_SetFocusWhenToggle
                this.SetTargetFocus()
            endif
            augroup Undotree
                au!
                au BufEnter,InsertLeave,CursorMoved,BufWritePost * UndotreeUpdate()
            augroup END
        endif
    enddef

    def GetStatusLine(): string
        var seq_cur: any
        if this.seq_cur != -1
            seq_cur = this.seq_cur
        else
            seq_cur = 'None'
        endif
        var seq_curhead: any
        if this.seq_curhead != -1
            seq_curhead = this.seq_curhead
        else
            seq_curhead = 'None'
        endif
        return 'current: ' .. seq_cur .. ' redo: ' .. seq_curhead
    enddef

    def Show()
        Log("undotree.Show()")
        if this.IsVisible()
            return
        endif

        this.targetid = w:undotree_id

        # Create undotree window.
        var cmd: string
        if exists("g:undotree_CustomUndotreeCmd")
            cmd = g:undotree_CustomUndotreeCmd .. ' ' .. this.bufname
        elseif g:undotree_WindowLayout == 1 || g:undotree_WindowLayout == 2
            cmd = "topleft vertical :" .. this.width .. ' new ' .. this.bufname
        else
            cmd = "botright vertical :" .. this.width .. ' new ' .. this.bufname
        endif
        Exec("silent keepalt " .. cmd)
        this.SetFocus()

        # We need a way to tell if the buffer is belong to undotree,
        # bufname() is not always reliable.
        b:isUndotreeBuffer = 1

        setlocal winfixwidth
        setlocal noswapfile
        setlocal buftype=nofile
        setlocal bufhidden=delete
        setlocal nowrap
        setlocal nolist
        setlocal foldcolumn=0
        setlocal nobuflisted
        setlocal nospell
        setlocal nonumber
        setlocal norelativenumber
        if g:undotree_CursorLine
            setlocal cursorline
        else
            setlocal nocursorline
        endif
        setlocal nomodifiable
        if g:undotree_StatusLine
            setlocal statusline=%!t:undotree.GetStatusLine()
        endif
        setfiletype undotree

        this.BindKey()
        this.BindAu()

        const ei_bak = &eventignore
        set eventignore=all

        this.SetTargetFocus()
        this.targetBufnr = -1 # force update
        this.Update()

        &eventignore = ei_bak

        if this.opendiff
            t:diffpanel.Show()
            this.UpdateDiff()
        endif
    enddef

    # called outside undotree window
    def Update()
        if !this.IsVisible()
            return
        endif
        # do nothing if we're in the undotree or diff panel
        if exists('b:isUndotreeBuffer')
            return
        endif
        # let the user disable undotree for chosen buftypes
        if index(g:undotree_DisabledBuftypes, &buftype) != -1
            Log("undotree.Update() disabled buftype")
            return
        endif
        # let the user disable undotree for chosen filetypes
        if index(g:undotree_DisabledFiletypes, &filetype) != -1
            Log("undotree.Update() disabled filetype")
            return
        endif
        var emptybuf: bool
        if (&bt != '' && &bt != 'acwrite') || !&modifiable || (mode() != 'n')
            if this.targetBufnr == bufnr('%') && this.targetid == w:undotree_id
                Log("undotree.Update() invalid buffer NOupdate")
                return
            endif
            emptybuf = true # This is not a valid buffer, could be help or something.
            Log("undotree.Update() invalid buffer update")
        else
            emptybuf = false
            # update undotree, set focus
            if this.targetBufnr == bufnr('%')
                this.targetid = w:undotree_id
                var newrawtree = undotree()
                if this.rawtree == newrawtree
                    return
                endif

                # same buffer, but seq changed.
                if newrawtree.seq_last == this.seq_last
                    Log("undotree.Update() update seqs")
                    this.rawtree = newrawtree
                    this.ConvertInput(0) # only update seqs.
                    if (this.seq_cur == this.seq_cur_bak) &&
                            (this.seq_curhead == this.seq_curhead_bak) &&
                            (this.seq_newhead == this.seq_newhead_bak) &&
                            (this.save_last == this.save_last_bak)
                        return
                    endif
                    this.SetFocus()
                    this.MarkSeqs(true)
                    this.UpdateDiff()
                    return
                endif
            endif
        endif
        Log("undotree.Update() update whole tree")

        this.targetBufnr = bufnr('%')
        this.targetid = w:undotree_id
        if emptybuf # Show an empty undo tree instead of do nothing.
            this.rawtree = {'seq_last': 0, 'entries': [], 'time_cur': 0, 'save_last': 0, 'synced': 1, 'save_cur': 0, 'seq_cur': 0}
        else
            this.rawtree = undotree()
        endif
        this.seq_last = this.rawtree.seq_last
        this.seq_cur = -1
        this.seq_curhead = -1
        this.seq_newhead = -1
        this.ConvertInput(1) # update all.
        this.Render()
        this.SetFocus()
        this.Draw()
        this.MarkSeqs(true)
        this.UpdateDiff()
    enddef

    def AppendHelp()
        if this.showHelp
            append(0, '') # empty line
            for i in keymap
                append(0, '# ' .. i[1] .. ' : ' .. i[2])
            endfor
            append(0, helpmore)
        else
            if g:undotree_HelpLine
                append(0, '')
            endif
            append(0, helpless)
        endif
    enddef

    def Index2Screen(index: number): number
        # index starts from zero
        var index_padding = 1
        var empty_line = 1
        var lineNr = index + index_padding + empty_line
        # calculate line number according to the help text.
        # index starts from zero and lineNr starts from 1
        if this.showHelp
            lineNr += len(keymap) + len(helpmore)
        else
            lineNr += len(helpless)
            if !g:undotree_HelpLine
                lineNr -= empty_line
            endif
        endif
        return lineNr
    enddef

    # <0 if index is invalid. e.g. current line is in help text.
    def Screen2Index(line: number): number
        var index_padding = 1
        var empty_line = 1
        var index = line - index_padding - empty_line

        if this.showHelp
            index -= len(keymap) + len(helpmore)
        else
            index -= len(helpless)
            if !g:undotree_HelpLine
                index += empty_line
            endif
        endif
        return index
    enddef

    # Current window must be undotree.
    def Draw()
        # remember the current cursor position.
        var savedview = winsaveview()

        setlocal modifiable
        # Delete text into blackhole register.
        Exec(':1,$ d _')
        append(0, this.asciitree)

        this.AppendHelp()

        # remove the last empty line
        Exec(':$d _')

        # restore previous cursor position.
        winrestview(savedview)

        setlocal nomodifiable
    enddef

    def MarkSeqs(move_cursor: bool)
        Log("bak(cur, curhead, newhead): " ..
            this.seq_cur_bak .. ' ' ..
            this.seq_curhead_bak .. ' ' ..
            this.seq_newhead_bak)
        Log("(cur, curhead, newhead): " ..
            this.seq_cur .. ' ' ..
            this.seq_curhead .. ' ' ..
            this.seq_newhead)
        setlocal modifiable
        # reset bak seq lines.
        if this.seq_cur_bak != -1
            var index = this.seq2index[this.seq_cur_bak]
            setline(this.Index2Screen(index), this.asciitree[index])
        endif
        if this.seq_curhead_bak != -1
            var index = this.seq2index[this.seq_curhead_bak]
            setline(this.Index2Screen(index), this.asciitree[index])
        endif
        if this.seq_newhead_bak != -1
            var index = this.seq2index[this.seq_newhead_bak]
            setline(this.Index2Screen(index), this.asciitree[index])
        endif
        # mark save seqs
        for i in keys(this.seq_saved)
            var index = this.seq2index[this.seq_saved[i]]
            var lineNr = this.Index2Screen(index)
            setline(lineNr, substitute(this.asciitree[index],
                ' \d\+  \zs \ze', 's', ''))
        endfor
        const max_saved_num = max(keys(this.seq_saved)) # return 0 (number) if empty
        if type(max_saved_num) != v:t_number
            var lineNr = this.Index2Screen(this.seq2index[this.seq_saved[max_saved_num]])
            setline(lineNr, substitute(getline(lineNr), 's', 'S', ''))
        endif
        # mark new seqs.
        if this.seq_cur != -1
            var index = this.seq2index[this.seq_cur]
            var lineNr = this.Index2Screen(index)
            setline(lineNr, substitute(getline(lineNr),
                '\zs \(\d\+\) \ze [sS ] ', '>\1<', ''))
            if move_cursor
                # move cursor to that line.
                Exec("normal! " .. lineNr .. "G")
            endif
        endif
        if this.seq_curhead != -1
            var index = this.seq2index[this.seq_curhead]
            var lineNr = this.Index2Screen(index)
            setline(lineNr, substitute(getline(lineNr),
                '\zs \(\d\+\) \ze [sS ] ', '{\1}', ''))
        endif
        if this.seq_newhead != -1
            var index = this.seq2index[this.seq_newhead]
            var lineNr = this.Index2Screen(index)
            setline(lineNr, substitute(getline(lineNr),
                '\zs \(\d\+\) \ze [sS ] ', '[\1]', ''))
        endif
        # mark diff marker
        if this.diffmark != -1
            var index = this.seq2index[this.diffmark]
            var lineNr = this.Index2Screen(index)
            setline(lineNr, substitute(getline(lineNr),
                '\zs \(\d\+\) \ze [sS ]', '=\1=', ''))
        endif
        setlocal nomodifiable
    enddef

    def _parseNode(in: list<dict<any>>, out: Node)
        # type(in) == type([]) && type(out) == type({})
        if empty(in) # empty
            return
        endif
        var curnode = out
        for i in in
            if has_key(i, 'alt')
                this._parseNode(i.alt, curnode)
            endif
            var newnode = Node.new(i.seq, i.time)
            if has_key(i, 'newhead')
                this.seq_newhead = i.seq
            endif
            if has_key(i, 'curhead')
                this.seq_curhead = i.seq
                this.seq_cur = curnode.seq
            endif
            if has_key(i, 'save')
                this.seq_saved[i.save] = i.seq
            endif
            extend(curnode.p, [newnode])
            curnode = newnode
        endfor
    enddef

    # Sample:
    #let s:test={'seq_last': 4, 'entries': [{'seq': 3, 'alt': [{'seq': 1, 'time': 1345131443}, {'seq': 2, 'time': 1345131445}], 'time': 1345131490}, {'seq': 4, 'time': 1345131492, 'newhead': 1}], 'time_cur': 1345131493, 'save_last': 0, 'synced': 0, 'save_cur': 0, 'seq_cur': 4}

    # updatetree: 0: no update, just assign seqs;  1: update and assign seqs.
    def ConvertInput(updatetree: bool)
        # reset seqs
        this.seq_cur_bak = this.seq_cur
        this.seq_curhead_bak = this.seq_curhead
        this.seq_newhead_bak = this.seq_newhead
        this.save_last_bak = this.save_last

        this.seq_cur = -1
        this.seq_curhead = -1
        this.seq_newhead = -1
        this.seq_saved = {}

        # Generate root node
        var root = Node.new(0, 0)

        this._parseNode(this.rawtree.entries, root)

        this.save_last = this.rawtree.save_last
        # Note: Normally, the current node should be the one that seq_cur points to,
        # but in fact it's not. May be bug, bug anyway I found a workaround:
        # first try to find the parent node of 'curhead', if not found, then use
        # seq_cur.
        if this.seq_cur == -1
            this.seq_cur = this.rawtree.seq_cur
        endif
        # undo history is cleared
        if empty(this.rawtree.entries)
            this.seq_cur = 0
        endif
        if updatetree
            this.tree = root
        endif
    enddef

    # Ascii undo tree generator
    #
    # Example:
    # 6 8  7
    # |/   |
    # 2    4
    #  \   |
    #   1  3  5
    #    \ | /
    #      0

    # Tree sieve, p:fork, x:none
    #
    # x         8
    # 8x        | 7
    # 87         \ \
    # x87       6 | |
    # 687       |/ /
    # p7x       | | 5
    # p75       | 4 |
    # p45       | 3 |
    # p35       | |/
    # pp        2 |
    # 2p        1 |
    # 1p        |/
    # p         0
    # 0
    #
    # Data sample:
    #let example = {'seq':0, 'p':[{'seq':1, 'p':[{'seq':2, 'p':[{'seq':6, 'p':[]}, {'seq':8, 'p':[]}]}]}, {'seq':3, 'p':[{'seq':4, 'p':[{'seq':7, 'p':[]}]}]}, {'seq':5, 'p':[]}]}
    #
    # Convert this.tree -> this.asciitree
    def Render()
        # We gonna modify this.tree so we'd better make a copy first.
        # Cannot make a copy because variable nested too deep, gosh.. okay,
        # fine..
        # let tree = deepcopy(this.tree)
        var tree = this.tree
        var slots: list<any> = [tree]
        var out: list<string>
        var outmeta: list<Node>
        var seq2index = {}
        while slots != []
            # find next node
            var foundx = 0 # 1 if x element is found.
            var index = 0 # Next element to be print.

            # Find x element first.
            for i in range(len(slots))
                if type(slots[i]) == v:t_string
                    foundx = 1
                    index = i
                    break
                endif
            endfor

            # Then, find the element with minimum seq.
            var minseq = 99999999
            var minnode: Node
            if foundx == 0
                # assume undo level isn't more than this... of course
                for i in range(len(slots))
                    if type(slots[i]) == v:t_object
                        if slots[i].seq < minseq
                            minseq = slots[i].seq
                            index = i
                            minnode = slots[i]
                            continue
                        endif
                    endif
                    if type(slots[i]) == v:t_list
                        for j in slots[i]
                            if j.seq < minseq
                                minseq = j.seq
                                index = i
                                minnode = j
                                continue
                            endif
                        endfor
                    endif
                endfor
            endif

            # output.
            const onespace = " "
            var newline = onespace
            var newmeta: Node
            var node = slots[index]
            if type(node) == v:t_string
                newmeta = Node.new() # invalid node.
                if index + 1 != len(slots) # not the last one, append '\'
                    for i in range(len(slots))
                        if i < index
                            newline = newline .. g:undotree_TreeVertShape .. ' '
                        endif
                        if i > index
                            newline = newline .. ' ' .. g:undotree_TreeReturnShape
                        endif
                    endfor
                endif
                remove(slots, index)
            endif
            if type(node) == v:t_object
                newmeta = node
                seq2index[node.seq] = len(out)
                for i in range(len(slots))
                    if index == i
                        newline = newline .. g:undotree_TreeNodeShape .. ' '
                    else
                        newline = newline .. g:undotree_TreeVertShape .. ' '
                    endif
                endfor
                newline = $'{newline}   {node.seq}    ({GetTime(node.time)})'
                # update the printed slot to its child.
                if empty(node.p)
                    slots[index] = 'x'
                endif
                if len(node.p) == 1 # only one child.
                    slots[index] = node.p[0]
                endif
                if len(node.p) > 1 # insert p node
                    slots[index] = node.p
                endif
                node.p = [] # cut reference.
            endif
            if type(node) == v:t_list
                newmeta = Node.new() # invalid node.
                for k in range(len(slots))
                    if k < index
                        newline = newline .. g:undotree_TreeVertShape .. " "
                    endif
                    if k == index
                        newline = newline .. g:undotree_TreeVertShape .. g:undotree_TreeSplitShape .. " "
                    endif
                    if k > index
                        newline = newline .. g:undotree_TreeSplitShape .. " "
                    endif
                endfor
                remove(slots, index)
                if len(node) == 2
                    if node[0].seq > node[1].seq
                        insert(slots, node[1], index)
                        insert(slots, node[0], index)
                    else
                        insert(slots, node[0], index)
                        insert(slots, node[1], index)
                    endif
                endif
                # split P to E+P if elements in p > 2
                if len(node) > 2
                    remove(node, index(node, minnode))
                    insert(slots, minnode, index)
                    insert(slots, node, index)
                endif
            endif
            node = null_object
            if newline != onespace
                newline = substitute(newline, '\s*$', '', 'g') # remove trailing space.
                insert(out, newline, 0)
                insert(outmeta, newmeta, 0)
            endif
        endwhile
        this.asciitree = out
        this.asciimeta = outmeta
        # revert index.
        var totallen = len(out)
        for i in keys(seq2index)
            seq2index[i] = totallen - 1 - seq2index[i]
        endfor
        this.seq2index = seq2index
    enddef
endclass

# diff panel
class DiffPanel extends Panel
    var cache = {}
    var changes = {add: 0, del: 0}
    var diffexecutable: number

    def new()
        this.bufname = "diffpanel_" .. GetUniqueID()
        this.diffexecutable = executable(g:undotree_DiffCommand)
        if !this.diffexecutable
            # If the command contains parameters, strip out the executable itthis
            var cmd = matchstr(g:undotree_DiffCommand .. ' ', '.\{-}\ze\s.*')
            this.diffexecutable = executable(cmd)
            if !this.diffexecutable
                echoerr '"' .. cmd .. '" is not executable.'
            endif
        endif
    enddef

    def Update(seq: number, targetBufnr: number, targetid: string, diffmark: number)
        Log($'Diffpanel.Update(), seq:{seq} bufname:{bufname(targetBufnr)} diffmark:{diffmark}')
        if !this.diffexecutable
            return
        endif
        var diffresult: list<string>
        this.changes.add = 0
        this.changes.del = 0

        if seq != 0
            if has_key(this.cache, targetBufnr .. '_' .. seq .. '_' .. diffmark)
                Log("diff cache hit.")
                diffresult = this.cache[targetBufnr .. '_' .. seq .. '_' .. diffmark]
            else
                # Double check the target winnr and bufnr
                var targetWinnr = -1
                for winnr in range(1, winnr('$')) # winnr starts from 1
                    if (getwinvar(winnr, 'undotree_id') == targetid)
                            && winbufnr(winnr) == targetBufnr
                        targetWinnr = winnr
                    endif
                endfor
                if targetWinnr == -1
                    return
                endif

                const ei_bak = &eventignore
                set eventignore=all

                Exec_silent($":{targetWinnr} wincmd w")

                # remember and restore cursor and window position.
                var savedview = winsaveview()

                var new = []
                var old = []
                var diff_dist = 1

                if diffmark != -1
                    diff_dist = seq - diffmark
                    if diff_dist > 0
                        new = getbufline(targetBufnr, 1, '$')
                        execute 'silent earlier ' .. diff_dist
                        old = getbufline(targetBufnr, 1, '$')
                        execute 'silent later ' .. diff_dist
                    else
                        old = getbufline(targetBufnr, 1, '$')
                        execute 'silent later ' .. (-diff_dist)
                        new = getbufline(targetBufnr, 1, '$')
                        execute 'silent earlier ' .. (-diff_dist)
                    endif
                else
                    new = getbufline(targetBufnr, 1, '$')
                    silent undo
                    old = getbufline(targetBufnr, 1, '$')
                    silent redo
                endif

                winrestview(savedview)

                # diff files.
                var tempfile1 = tempname()
                var tempfile2 = tempname()
                if writefile(old, tempfile1) == -1
                    echoerr "Can not write to temp file:" .. tempfile1
                endif
                if writefile(new, tempfile2) == -1
                    echoerr "Can not write to temp file:" .. tempfile2
                endif
                diffresult = split(system(g:undotree_DiffCommand .. ' ' .. tempfile1 .. ' ' .. tempfile2), "\n")
                Log("diffresult: " .. string(diffresult))
                if delete(tempfile1) != 0
                    echoerr "Can not delete temp file:" .. tempfile1
                endif
                if delete(tempfile2) != 0
                    echoerr "Can not delete temp file:" .. tempfile2
                endif
                &eventignore = ei_bak
                # Update cache
                this.cache[targetBufnr .. '_' .. seq .. '_' .. diffmark] = diffresult
            endif
        endif

        this.ParseDiff(diffresult, targetBufnr)

        this.SetFocus()

        setlocal modifiable
        Exec(':1,$ d _')

        append(0, diffresult)
        if diffmark == -1 || seq == diffmark
            append(0, '+ seq: ' .. seq .. ' +')
        elseif seq > diffmark
            append(0, '+ seq: ' .. seq .. ' +')
            append(0, '- seq: ' .. diffmark .. ' -')
        else
            append(0, '+ seq: ' .. diffmark .. ' +')
            append(0, '- seq: ' .. seq .. ' -')
        endif

        # remove the last empty line
        if getline("$") == ""
            Exec(':$d _')
        endif
        Exec('norm! gg') # move cursor to line 1.
        setlocal nomodifiable
        t:undotree.SetFocus()
    enddef

    def ParseDiff(diffresult: list<string>, targetBufnr: number)
        # set target focus first.
        t:undotree.SetTargetFocus()

        # If 'diffresult' is empty then there are no new signs to place. However,
        # we need to ensure any old signs are removed. This is especially important
        # if we are at the very first sequence, otherwise signs get left
        if (exists("w:undotree_diffsigns"))
            while w:undotree_diffsigns > 0
                exe 'sign unplace ' .. signId
                w:undotree_diffsigns -= 1
            endwhile
        endif

        if empty(diffresult)
            return
        endif

        # clear previous highlighted syntax
        # matchadd associates with windows.
        if exists("w:undotree_diffmatches")
            for i in w:undotree_diffmatches
                silent! matchdelete(i)
            endfor
        endif

        w:undotree_diffmatches = []
        w:undotree_diffsigns = 0
        var lineNr = 0
        var lastLine = line('$')
        var matchwhat: string
        for line in diffresult
            var matchnum = matchstr(line, '^[0-9, \, ]*[acd]\zs\d*\ze')
            if !empty(matchnum)
                lineNr = str2nr(matchnum)
                matchwhat = matchstr(line, '^[0-9, \, ]*\zs[acd]\ze\d*')
                if matchwhat ==# 'd'
                    if g:undotree_HighlightChangedWithSign
                        # Normally, for a 'delete' change, the line number we have is always 1 less than the line we
                        # need to place the sign at, hence '+ 1'
                        # However, if the very end of the buffer has been deleted then this is not possible (because
                        # that bit of the buffer no longer exists), so we place a 'special' version of the 'delete'
                        # sign on what is the last available line)
                        exe 'sign place ' .. signId .. ' line=' .. ((lineNr < lastLine) ? lineNr + 1 : lastLine) .. ' name=' .. ((lineNr < lastLine) ? 'UndotreeDel' : 'UndotreeDelEnd') .. ' buffer=' .. targetBufnr
                        w:undotree_diffsigns += 1
                    endif

                    lineNr = 0
                    matchwhat = ''
                endif
                continue
            endif
            if matchstr(line, '^<.*$') != ''
                this.changes.del += 1
            endif

            var matchtext = matchstr(line, '^>\zs .*$')
            if empty(matchtext)
                continue
            endif

            this.changes.add += 1
            if g:undotree_HighlightChangedText
                if matchtext != ' '
                    matchtext = '\%' .. lineNr .. 'l\V' .. escape(matchtext[1 : ], '"\') # remove beginning space.
                    Log("matchadd(" .. matchwhat .. ") ->  " .. matchtext)
                    add(w:undotree_diffmatches, matchadd((matchwhat ==# 'a' ? g:undotree_HighlightSyntaxAdd : g:undotree_HighlightSyntaxChange), matchtext))
                endif
            endif

            if g:undotree_HighlightChangedWithSign
                exe 'sign place ' .. signId .. ' line=' .. lineNr .. ' name=' .. (matchwhat ==# 'a' ? 'UndotreeAdd' : 'UndotreeChg') .. ' buffer=' .. targetBufnr
                w:undotree_diffsigns += 1
            endif

            lineNr = lineNr + 1
        endfor
    enddef

    def GetStatusLine(): string
        var max = winwidth(0) - 4
        var sum = this.changes.add + this.changes.del
        var add: number
        var del: number
        if sum > max
            add = this.changes.add * max / sum + 1
            del = this.changes.del * max / sum + 1
        else
            add = this.changes.add
            del = this.changes.del
        endif
        return string(sum) .. ' ' .. repeat('+', add) .. repeat('-', del)
    enddef

    def Toggle()
        Log(this.bufname .. " Toggle()")
        if this.IsVisible()
            this.Hide()
        else
            this.Show()
        endif
    enddef

    def Show()
        Log("Diffpanel.Show()")
        if this.IsVisible()
            return
        endif
        # Create diffpanel window.
        t:undotree.SetFocus() # can not exist without undotree
        # remember and restore cursor and window position.
        var savedview = winsaveview()

        const ei_bak = &eventignore
        set eventignore=all

        var cmd: string
        if exists("g:undotree_CustomDiffpanelCmd")
            cmd = g:undotree_CustomDiffpanelCmd .. ' ' .. this.bufname
        elseif g:undotree_WindowLayout == 1 || g:undotree_WindowLayout == 3
            cmd = 'belowright :' .. g:undotree_DiffpanelHeight .. 'new ' .. this.bufname
        else
            cmd = 'botright :' .. g:undotree_DiffpanelHeight .. 'new ' .. this.bufname
        endif
        Exec_silent(cmd)

        b:isUndotreeBuffer = 1

        setlocal winfixwidth
        setlocal winfixheight
        setlocal noswapfile
        setlocal buftype=nofile
        setlocal bufhidden=delete
        setlocal nowrap
        setlocal nolist
        setlocal nobuflisted
        setlocal nospell
        setlocal nonumber
        setlocal norelativenumber
        setlocal nocursorline
        setlocal nomodifiable
        if g:undotree_StatusLine
            setlocal statusline=%!t:diffpanel.GetStatusLine()
        endif

        &eventignore = ei_bak

        # syntax need filetype autocommand
        setfiletype diff
        setlocal foldcolumn=0
        setlocal nofoldenable

        this.BindAu()
        t:undotree.SetFocus()
        winrestview(savedview)
    enddef

    def BindAu()
        # Auto exit if it's the last window or undotree closed.
        augroup Undotree_Diff
            au!
            au BufEnter <buffer> ExitIfLast()
            au BufEnter <buffer> if !t:undotree.IsVisible()
                        \|t:diffpanel.Hide() |endif
        augroup end
    enddef

    def CleanUpHighlight()
        Log("CleanUpHighlight()")
        # save current position
        var curwinnr = winnr()
        var savedview = winsaveview()

        # clear w:undotree_diffmatches in all windows.
        var winnum = winnr('$')
        for i in range(1, winnum)
            Exec_silent($":{i}wincmd \<C-W>")
            if exists("w:undotree_diffmatches")
                for j in w:undotree_diffmatches
                    silent! matchdelete(j)
                endfor
                w:undotree_diffmatches = []
            endif
            if (exists("w:undotree_diffsigns"))
                while w:undotree_diffsigns > 0
                    exe 'sign unplace ' .. signId
                    w:undotree_diffsigns -= 1
                endwhile
            endif
        endfor

        # restore position
        Exec_silent($":{curwinnr}wincmd \<C-W>")
        winrestview(savedview)
    enddef

    def Hide()
        Log(this.bufname .. " Hide()")
        if !this.IsVisible()
            return
        endif
        this.SetFocus()
        Exec("quit")
        this.CleanUpHighlight()
    enddef
endclass

# It will set the target of undotree window to the current editing buffer.
def UndotreeAction(action: string)
    Log("UndotreeAction()")
    if !exists('t:undotree')
        echoerr "Fatal: t:undotree does not exist!"
        return
    endif
    t:undotree.Action(action)
enddef

def ExitIfLast()
    var num = 0
    if exists('t:undotree') && t:undotree.IsVisible()
        num = num + 1
    endif
    if exists('t:diffpanel') && t:diffpanel.IsVisible()
        num = num + 1
    endif
    if winnr('$') == num
        if exists('t:undotree')
            t:undotree.Hide()
        endif
        if exists('t:diffpanel')
            t:diffpanel.Hide()
        endif
    endif
enddef

# User command functions
#called outside undotree window
export def UndotreeUpdate()
    if !exists('t:undotree')
        return
    endif
    if !exists('w:undotree_id')
        w:undotree_id = 'id_' .. GetUniqueID()
        Log("Unique window id assigned: " .. w:undotree_id)
    endif
    # assume window layout won't change during updating.
    var thiswinnr = winnr()
    t:undotree.Update()
    # focus moved
    if winnr() != thiswinnr
        Exec("norm! " .. thiswinnr .. "\<c-w>\<c-w>")
    endif
enddef

export def UndotreeToggle()
    try
        Log(">>> UndotreeToggle()")
        if !exists('w:undotree_id')
            w:undotree_id = 'id_' .. GetUniqueID()
            Log("Unique window id assigned: " .. w:undotree_id)
        endif
        if !exists('t:undotree')
            t:undotree = Undotree.new()
        endif
        if !exists('t:diffpanel')
            t:diffpanel = DiffPanel.new()
        endif
        t:undotree.Toggle()
        Log("<<< UndotreeToggle() leave")
    catch /^Vim\%((\a\+)\)\?:E11/
        echohl ErrorMsg
        echom v:exception
        echohl NONE
    endtry
enddef

export def UndotreeIsVisible(): bool
    return (exists('t:undotree') && t:undotree.IsVisible())
enddef

export def UndotreeHide()
    if UndotreeIsVisible()
        try
            UndotreeToggle()
        catch /^Vim\%((\a\+)\)\?:E11/
            echohl ErrorMsg
            echom v:exception
            echohl NONE
        endtry
    endif
enddef

export def UndotreeShow()
    try
        if ! UndotreeIsVisible()
            UndotreeToggle()
        else
            t:undotree.SetFocus()
        endif
    catch /^Vim\%((\a\+)\)\?:E11/
        echohl ErrorMsg
        echom v:exception
        echohl NONE
    endtry
enddef

export def UndotreeFocus()
    if UndotreeIsVisible()
        try
            t:undotree.SetFocus()
        catch /^Vim\%((\a\+)\)\?:E11/
            echohl ErrorMsg
            echom v:exception
            echohl NONE
        endtry
    endif
enddef

export def UndotreePersistUndo(goSetUndofile: bool)
    Log("UndotreePersistUndo(" .. goSetUndofile .. ")")
    if ! &undofile
        if !isdirectory(g:undotree_UndoDir)
            mkdir(g:undotree_UndoDir, 'p', 0700)
            Log(" > [Dir " .. g:undotree_UndoDir .. "] created.")
        endif
        exe "set undodir=" .. fnameescape(g:undotree_UndoDir)
        Log(" > [set undodir=" .. g:undotree_UndoDir .. "] executed.")
        if filereadable(undofile(expand('%'))) || goSetUndofile
            setlocal undofile
            Log(" > [setlocal undofile] executed")
        endif
        if goSetUndofile
            silent! write
            echo "A persistence undo file has been created."
        endif
    else
        Log(" > Undofile has been set. Do nothing.")
    endif
enddef

# vim: set et fdm=marker sts=4 sw=4:

;--- Note: This code include context-senstive hotkeys that can be interpreted
;    as subroutines.  Insert/Include this code AFTER the auto-execution section
;    of a script.
;
;************************
;*                      *
;*    ListManagerGUI    *
;*                      *
;************************
;
;   Description
;   ===========
;   This function displays a window to edit, select from, or display a simple
;   list.
;
;
;   Parameters
;   ==========
;
;       Name            Description
;       ----            -----------
;       p_Owner         Owner of the ListManagerGUI window.  [Optional]  The
;                       default is 1.
;
;                       If a valid Owner window number is derived, the Owner
;                       window is disabled and ownership of the ListManagerGUI
;                       window is assigned to the Owner window.  This makes the
;                       ListManagerGUI window modal which prevents the user from
;                       interacting with the Owner window until the
;                       ListManagerGUI window is closed.
;
;
;       p_List          The list of items to be edited, selected from, or
;                       displayed.  [Optional]  The default is an empty list.
;                       Each item in the list is delimited by the value of the
;                       p_Delimiter parameter (see below) or by the default
;                       delimiter.
;
;                       If p_Mode is "Checklist", each item must be prefixed
;                       with a "1" (checked or selected) or a "0" (not checked
;                       or selected).  For example:
;
;                         0Red|1Green|0Blue
;
;                       ...represents a list of "Red", "Green", and "Blue"
;                       where "Green" is checked or selected and the other items
;                       are not.
;
;                       If p_Mode is "Checklist",check/select flags in the list
;                       may be overridden by one or more of the following:
;
;                         1) Values in the p_DefaultList parameter (if defined)
;                         2) CheckAll option (if enabled and if applicable)
;                         3) SelecteAll option (if enabled and if applicable)
;
;
;       p_DefaultList   A list of items (subset of p_List) that are
;                       checked/selected on startup.  [Optional]  The default is
;                       an empty list.
;
;                       Note: Use the CheckAll or SelectAll options to
;                       check/select all list items.  See the p_ModeOptions
;                       parameter (below) for more information.
;
;
;       p_Delimiter     The character used to delimit each list item.
;                       [Optional]  The default is "|".
;
;                       Note 1:  Since the "Checklist" mode requires that every
;                       item be prefixed with a "1" or a "0", this parameter
;                       should never be set to a "1" or "0" if p_Mode is
;                       "Checklist".
;
;                       Note 2: To help ensure the integrity of the list, the
;                       value of p_Delimiter is automatically removed from
;                       list items on modify and paste.
;
;
;       p_Mode          Mode.  [Optional]  The default is "Edit".
;
;                       This parameter determines how the List Manager
;                       window will be used and what values (if any) will be
;                       returned.  The following values are supported:
;
;                         Mode      Description
;                         ----      -----------
;                         Edit      The List Manager window will be used to edit
;                                   a simple list.  If the return button is
;                                   clicked, the entire list is returned.
;
;                                   The following mode options (listed in
;                                   alphbetical order) are set by default:
;
;                                     +CancelButton
;                                     +Close
;                                     +ConfirmClose
;                                     +ContextMenu
;                                     +Copy
;                                     +Delete
;                                     +EscapeToClose
;                                     +Insert
;                                     +Menu
;                                     +Modify
;                                     +Move
;                                     +Paste
;                                     +ReturnButtonSave
;                                     +Select
;                                     +SelectMulti
;
;                         Checklist The List Manager window will be used to edit
;                                   a simple checklist.  If the Return button is
;                                   clicked, the entire list is returned along
;                                   with the selected/checked value of each
;                                   item.  See the "Return Codes" section for
;                                   more information.
;
;                                   The following mode options (listed in
;                                   alphbetical order) are set by default:
;
;                                     +CancelButton
;                                     +Checkboxes
;                                     +Close
;                                     +ConfirmClose
;                                     +ContextMenu
;                                     +Copy
;                                     +Delete
;                                     +DoubleClick
;                                     +EscapeToClose
;                                     +Insert
;                                     +Menu
;                                     +Modify
;                                     +Move
;                                     +Paste
;                                     +ReturnButtonSave
;                                     +Select
;                                     +SelectMulti
;
;                                   Note: Since the format of list is different
;                                   than the other modes, the "Checklist" mode
;                                   is only recommended when the user is
;                                   expected to maintain the master list as well
;                                   as the selected list.  If the master list is
;                                   static, using the "Select" mode with p_List
;                                   set to the static master list and
;                                   p_DefaultList set to the the currently
;                                   selected list might be easier to maintain.
;
;                         Select    The List Manager window will be used to
;                                   select from a simple list.  Only the
;                                   selected value(s) are returned.
;
;                                   The following mode options (listed in
;                                   alphbetical order) are set by default:
;
;                                     +CancelButton
;                                     +Close
;                                     +Copy
;                                     +DoubleClick
;                                     +EscapeToClose
;                                     +ReturnButtonSelect
;                                     +Select
;                                     +SelectionRequired
;
;                         Display   The List Manger window will be used to
;                                   display a simple list.  Nothing is returned.
;
;                                   The following mode options (listed in
;                                   alphbetical order) are set by default:
;
;                                     +Close
;                                     +EscapeToClose
;                                     +ReturnButtonOK
;
;
;       p_ModeOptions   Mode options.  [Optional]  The defaults are determined
;                       by the value of the p_Mode parameter.
;
;                       This parameter allows the developer to add or remove
;                       options from the selected Mode.  The following options
;                       (listed in alphabetic order) are supported:
;
;                       Options should be preceded with a "+" or "-" character
;                       to indicate whether the option is to be enabled or
;                       disabled.  Example: +AutoTrim
;
;                         Name
;                         ----
;                                   Description
;                                   -----------
;
;                         AutoDeleteChars{ListOfCharacters}
;
;                                   Identifies one or more characters that will
;                                   be automatically removed.
;
;                                   All whitespace characters are supported with
;                                   the following syntax:
;
;                                     Syntax    Description
;                                     ------    -----------
;                                      \s       Space
;                                      \t       Tab
;                                      \n       New line
;                                      \v       Vertical tab
;                                      \f       Form feed
;                                      \r       Return
;
;                                   Example of Use:
;
;                                     +AutoDeleteChars()+-\s
;
;                                   In this example, the "(", ")", "+", "-", and
;                                   space characters are automatically removed
;                                   from every list item.  This option might be
;                                   used if the list contains telephone numbers
;                                   where you don't want extraneous characters
;                                   stored with the number.
;
;                                   Note 1: The value of p_Delimiter is
;                                   automatically removed from every list item
;                                   on modify and paste.  There is no need to
;                                   add the p_Delimiter character to the list of
;                                   characters removed by this option.
;
;                                   Note 2: Since this option may include case
;                                   sensitive string comparisions (see the
;                                   CaseSensitive option below), it is peformed
;                                   after all other Auto{xxx} options.
;
;                         AutoDeleteSpace
;
;                                   All whitespace characters are automatically
;                                   removed.
;
;                                   Note: It's not necessary to use the AutoTrim
;                                   option if this option is enabled.
;
;                         AutoLower
;
;                                   Alpha characters are automatically converted
;                                   to lowercase.
;
;                         AutoSort
;                         AutoSortDesc
;
;                                   The list is automatically sorted in
;                                   ascending/descending order on Start and on
;                                   Save/Select. So that the user does not get
;                                   disoriented, a sort is not performed on
;                                   insert, modify, or paste.
;
;                                   Note: These options are not dependent on the
;                                   Sort option.
;
;                         AutoTrim
;
;                                   Leading and/or trailing whitespace
;                                   characters are automatically removed.
;
;                         AutoUpper
;
;                                   Alpha characters are automatically converted
;                                   to uppercase.
;
;                         AutoUpperT
;
;                                   Title case characters are automatically
;                                   converted to uppercase.
;
;                         CancelButton
;
;                                   Provides a "Cancel" button.
;
;                                   If enabled, this button allows the user to
;                                   cancel the current operation without
;                                   confirmation (if any).
;
;                                   If disabled, the "Cancel" button is not
;                                   displayed.
;
;                         CaseSensitive
;
;                                   String comparisons are case sensitive.
;
;                         CheckAll
;
;                                   Checks (puts a check mark next to) all list
;                                   items on startup.  This option has no effect
;                                   unless the CheckBoxes option is enabled.
;
;                         CheckBoxes
;
;                                   Provides a checkbox at the left side of each
;'                                  list item.
;
;                                   Important: The Select and  MultiSelect
;                                   options have no effect on this option.  If
;                                   enabled, the user will be able check or
;                                   uncheck any/all items in the list.
;
;                         Close
;
;                                   Allow the window to be closed with any of
;                                   the following methods:
;
;                                    1) The Close button on the title bar (if
;                                       defined)
;
;                                    2) Alt+F4
;
;                                    3) Escape key (if EscapeToClose is
;                                       enabled).
;
;                         ConfirmClose
;
;                                   [Edit or Checklist mode]
;                                   If enabled, this option will display a
;                                   confirmation dialog if changes to the list
;                                   were made and the user attempts to close the
;                                   window prematurely by clicking on the Close
;                                   button (if displayed and enabled) or by
;                                   pressing the Escape key (if EscapeToClose is
;                                   enabled).
;
;                                   Note: This option has no effect unless the
;                                   Close option is enabled.
;
;                         ConfirmDelete
;
;                                   If enabled, this option will display a
;                                   confirmation dialog when the user attempts
;                                   to cut or delete one or more items.
;
;                         ContextMenu
;
;                                   Allow a context menu with a list of
;                                   available commands.
;
;                         Copy
;
;                                   Allow checked or selected list item(s) to be
;                                   copied to the clipboard.
;
;                         Delete
;
;                                   Allow list item(s) to be deleted.  This
;                                   option has no effect unless the Select
;                                   option is enabled.
;
;                         DoubleClick
;
;                                   Double-click to check, modify, or select
;                                   list item(s).  Action is as follows and in
;                                   the order of precedence:
;
;                                    -  If Checkboxes are shown (all modes), a
;                                       mouse double-click will check (put a
;                                       check mark in the check box) the
;                                       selected item(s).
;
;                                     - If p_Mode is "Edit" or "Checklist", a
;                                       mouse double-click will modify the list
;                                       item that is focus.
;
;                                     - If p_Mode is "Select", a mouse
;                                       double-click will select and and return
;                                       the selected item(s).  This is the
;                                       equivalent of selecting an item with a
;                                       single mouse click and then clicking on
;                                       the Return button.
;
;                         EditButtons
;
;                                   Buttons for "Up", "Down", "Insert",
;                                   "Modify", "Cut", "Copy", "Paste", and
;                                   "Delete".
;
;                         EscapeToClose
;
;                                   The "Escape" key acts the same as clicking
;                                   on the "Close" button (title bar) or on the
;                                   "Cancel" button (if enabled).
;
;                                   Note: This option has no effect if the
;                                   Close option is disabled.
;
;                         Insert
;
;                                   Allow new list item(s) to be added/inserted.
;
;                                   Note: This option has no effect if the
;                                   Modify or Select options are disabled.
;
;                         Menu
;
;                                   Create a menu bar with a list of available
;                                   commands.
;
;                         Modify
;
;                                   Allow list items to be modified.  This
;                                   option has no effect unless the Select
;                                   option is enabled.
;
;                         Move
;
;                                   Allow list items to be moved (repositioned
;                                   in the list).  This option has no effect
;                                   unless the Select option is enabled.
;
;                         NoBlank
;
;                                   Blank list items are automatically discarded
;                                   on Start and Paste and are disallowed on
;                                   insert and modify.
;
;                                   Note: An item is considered "blank" if it is
;                                   empty (null) or if only contains whitespace
;                                   characters.
;
;                         NoDuplicates
;
;                                   Duplicate list items are automatically
;                                   discarded on Start and paste and are
;                                   disallowed on insert and modify.
;
;                                   Note:  If the CaseSensitive option is
;                                   enabled, only exact duplicates are discarded
;                                   or disallowed.  If applicable, consider
;                                   using one or more of the Auto{xxx} options
;                                   to help improve the integrity of the list.
;
;                         NoDefaults
;
;                                   [Debug or power user option]
;                                   If defined, no default options are used.
;
;                         Paste
;
;                                   Allow list item(s) to be added/inserted from
;                                   the clipboard.  This option has no effect
;                                   unless the Select option is enabled.
;
;                         ReturnButton{Label}
;
;                                   Identifies the label for the button that
;                                   causes the window to return normally.  The
;                                   default labels are as follows:
;
;                                     Mode          Label
;                                     ----          -----
;                                     Edit          Save
;                                     Checklist     Save
;                                     Select        Select
;                                     Display       OK
;
;
;                                   If no label is defined, the Return button is
;                                   not displayed.
;
;                         ReturnListPos
;
;                                   [Select mode]
;                                   The relative positions in the list that are
;                                   checked/selected are returned instead of the
;                                   contents of the list items.
;
;                         Select
;
;                                   Allow list item(s) to be selected.
;
;                                   Note 1: "Select" in this case is not
;                                   necessarily the ability to choose a list
;                                   item but rather the ability to mark a list
;                                   item by clicking on on it and/or by pressing
;                                   the Up or Down key.  Disabling Select is
;                                   sometimes useful when Checkboxes are enabled
;                                   or when using the using the "Display" mode.
;
;                                   Note 2: Without the ability to select (mark)
;                                   a specific list item, disabling this option
;                                   will disallow many options such as Copy,
;                                   Delete, Move, etc.
;
;                         SelectAll
;
;                                   Select all list items on startup.  This
;                                   option has no effect unless the Select and
;                                   SelectMulti options are enabled.
;
;                         SelectMulti
;
;                                   Allow more that one item to be selected at a
;                                   time.  This option has no effect unless the
;                                   Select option is enabled.  See the notes for
;                                   the Select option (above) for more
;                                   information.
;
;                         SelectionRequired
;
;                                   [Select mode]
;                                   If enabled, the user is required to select
;                                   or check (put a check mark in the check box)
;                                   at least one list item before the Return
;                                   button and menu item (usually labeled
;                                   "Select") is enabled.
;
;                                   Important Note:  This option does not stop
;                                   the user from closing the window prematurely
;                                   by clicking on the "Cancel" or "Close"
;                                   button (title bar) or hitting the Escape
;                                   key (EscapeToClose option).  To stop the
;                                   user from closing the window before a
;                                   selection is made, all options that allow
;                                   the window to be closed prematurely must
;                                   also be disabled.  See the Close,
;                                   EscapeToClose, and CancelButton options for
;                                   more information.
;
;                         Size{Size}
;                         Size{Min-Max}
;                         Size{x1,x2,...}
;
;                                   [Future]
;                                   This option limits each list item to a
;                                   specific length, range of lengths, or to a
;                                   list of valid lengths.  Syntax examples:
;
;                                     Option        Description/Limit
;                                     ------        -----------------
;                                     +Size10       Each item must contain 10
;                                                   characters.
;
;                                     +Size1-10     Each item must contain from
;                                                   1 to 10 characters.
;
;                                     +Size10-15    Each item must contain from
;                                                   10 to 15 characters.
;
;                                     +Size7,9,10   Each item must contain 7, 9,
;                                                   or 10 characters.
;
;                                   Important: This option is very restrictive.
;                                   Items that don't fit the size requirements
;                                   are automatically dropped when the list is
;                                   initially loaded and on paste.  Items that
;                                   don't fit the size requirements are
;                                   disallowed on insert and modify.  To improve
;                                   the integrity of the list (and if
;                                   applicable), consider using one or more of
;                                   the Auto{xxx} options and/or the NoBlank
;                                   option.
;
;                         Sort
;
;                                   Allow the list to be sorted on demand.  If
;                                   enabled, the list is sorted when the Sort
;                                   menu items or hotkey(s) are used.
;
;                                   Note: This option is independent of the
;                                   AutoSort/AutoSortDesc options and is not
;                                   dependent on the Move option.
;
;                         Type{DataType}
;
;                                   Classifies the list item as a
;                                   specific data type.  Supported types"
;                                   include the following:
;
;                                     Integer
;                                     Float
;                                     Number
;                                     Digit
;                                     xDigit
;                                     Alpha
;                                     Upper
;                                     Lower
;                                     AlNum
;
;                                   Important: This option is very restrictive.
;                                   Items that don't match the specified type
;                                   are automatically dropped when the list is
;                                   initially loaded and on paste.  Items that
;                                   don't match the specified type are
;                                   disallowed on insert and modify.  To improve
;                                   the integrity of the list (and if
;                                   applicable), consider using one or more of
;                                   the Auto{xxx} options and/or the NoBlank
;                                   option.
;
;                       To use more than one option, include a space between
;                       each option.  For example:
;
;                         "+EditButtons -Insert +AutoTrim"
;
;                       See the "Processing Notes" section for more
;                       information.
;
;
;       p_ListTitle     List title.  [Optional]  The default is blank (no
;                       title).
;
;
;       p_WindowTitle   Window title.  [Optional]  If not defined, the
;                       parameter is set to the following:
;
;                         If p_Mode is      Value
;                         ------------      -----
;                         Edit, Checklist   "Edit %p_ListTitle%"
;                         Select            "Select %p_ListTitle%"
;                         Display           "%p_ListTitle%"
;
;
;       p_ListOptions   List options.  [Optional].  The default is
;                       "w300 h200".
;
;                       These options determine the characteristics of the
;                       list control.  Some common options include the
;                       following (not case sensitive):
;
;                         Option
;                         ------
;                                   Description
;                                   -----------
;
;                         w{pixels}
;
;                                   Determines the initial width (in pixels) of
;                                   of the list control.
;
;                                   [Future]
;                                   This value is automatically adjusted if too
;                                   too small/large.
;
;                         h{pixels}
;
;                                   Determines the initial height (in pixels) of
;                                   the list control.
;
;                                   [Future]
;                                   This value is automatically adjusted if too
;                                   small/large.
;
;                         Background{Color}
;
;                                   Background color of the list control.
;                                   "{Color}" is an HTML color name or a 6-digit
;                                   hex RGB color value.  Example values: Blue,
;                                   F0F0F0, EEAA99.
;
;                                   For more information, see the AutoHotkey
;                                   documentation (Keyword: color names)
;
;                         c{Color}
;
;                                   Font color.  "{Color}" is an HTML color name
;                                   or 6-digit hex RGB color value.  Example
;                                   values: Blue, F0F0F0, EEAA99.
;
;                                   For more information, see the AutoHotkey
;                                   documentation (Keyword: color names)
;
;                                   Note: If used, this option will override any
;                                   any color values defined in the
;                                   p_FontOptions parameter.
;
;                         +Grid
;
;                                   Provides horizontal lines to visually
;                                   indicate the boundaries between the rows.
;
;
;                         +Sort
;                         +SortDesc
;
;                                   These options are NOT supported.  Use
;                                   the AutoSort/AutoSortDesc options of the
;                                   p_ModeOptions parameter (see above) instead.
;
;
;                       To use more than one option, include a space between
;                       each option.  For example:
;
;                         "w500 h500 +Grid"
;
;                       For more information, see the AutoHotkey documentation
;                       (Keyword: ListView controls (GUI),
;                       Section: Options and Styles for...)
;
;
;       p_Font          Font for the list control.  [Optional]  The default is
;                       blank (uses the system default font).
;
;                       For a list of available font names, see the AutoHotkey
;                       documentation (Keyword: Fonts)
;
;
;       p_FontOptions   Font options.  [Optional]  The default is blank (uses
;                       the system defaults).
;
;                       At this writing, the following font options are
;                       currently available (not case sensitive):
;
;                         c{HTML color name or 6-digit hex RGB color value}
;                         s{Font size (in points)}
;                         Bold
;                         Italic
;                         Strike
;                         Underline
;
;                       To use more than one option, include a space between
;                       each option.  For example:
;
;                         "cBlue s10 bold underline"
;
;                       For more information, see the AutoHotkey documentation
;                       (Keyword: GUI, section: Font).
;
;
;       p_GUIOptions    GUI Options.  [Optional]  The default is "-MinimizeBox".
;
;                       Some common options include the the following (not case
;                       sensitive):
;
;                         Option
;                         ------
;                                   Description
;                                   -----------
;
;                         +Border
;
;                                   If used with the"-Caption" option (see
;                                   below), creates a thin border around the
;                                   window.
;
;                         -Border
;
;                                   If used without the "-Caption" option,
;                                   removes the title bar from the window and
;                                   creates a thick border around the window.
;
;                         -Caption
;
;                                   Removes the title bar and borders from the
;                                   window.
;
;                         -MaximizeBox
;
;                                   Disables the maximize button in the title
;                                   bar (if it exists).  This option is commonly
;                                   used with the +Resize option (see below).
;
;                         -MinimizeBox
;
;                                   Disables the minimize button in the title
;                                   bar (if it exists).
;
;                                   Note: To insure that ListManagerGUI window
;                                   is modal, this option is always added to
;                                   this parameter.
;
;                         +Resize
;
;                                   Makes the window resizable and enables the
;                                   maximize button.  See the "-MaximizeBox"
;                                   option (above).
;
;                                   Note:  This function has been programmed to
;                                   to reposition all of the appropriate objects
;                                   if this option is used.
;
;                         -SysMenu
;
;                                   This option removes the following from the
;                                   title bar: system menu, icon, minimize
;                                   button, maximize button, and close button.
;
;                                   Note:  If this option is used, make sure
;                                   that there is another way to close the
;                                   window.  i.e. "Return" button, "Cancel"
;                                   button, EscapeToClose, DoubleClick, etc.
;
;                         +ToolWindow
;
;                                   Creates a narrow title bar and removes the
;                                   Minimize and Maximize buttons (if they
;                                   exist).
;
;                       To use more than one option, include a space between
;                       each option.  For example:
;
;                         "+Resize -MaximizeBox"
;
;                       These options are performed in the order they defined.
;
;                       For more information, see the AutoHotkey documentation
;                       (Keyword: GUI, section: Options)
;
;
;       p_BGColor       Sets the background color of the GUI. [Optional]
;                       The default is blank (uses the system default color).
;
;                       To set, specify one of the 16 primary HTML color names
;                       or a 6-digit hex RGB color value.  Example values: Blue,
;                       F0F0F0, EEAA99, Default.
;
;                       For more information, see the AutoHotkey documentation
;                       (Keyword: color names)
;
;
;   Processing and Usage Notes
;   ==========================
;    o  This function does not return until the user closes the ListManagerGUI
;       window.  If a hotkey is used to trigger a call to this function, that
;       same hotkey cannot be triggered again (if using the system default of
;       #MaxThreadsPerHotkey 1) until the ListManagerGUI window is closed.
;
;    o  Because of the large number of possible values, some of the function
;       parameters are not checked for integrity.  Most of the time, invalid
;       values are simply ignored.  However, invalid values may cause the script
;       to fail.  Be sure to carefully select the parameter values and test
;       your script thoroughly.
;
;   o   This function uses the first GUI window that is available in the p_GUI
;       (usually 54) to 99 range. If an available window cannot be found, an
;       error message is displayed.
;
;   o   Several references to "whitespace" characters are made throughout this
;       script.  Whitespace characters include the following:
;
;         Space
;         Tab
;         Linefeed
;         Return
;         Vertical tab
;         Formfeed
;
;   o   So as to be compatible with other applications, the Copy and Paste
;       options use the new line "`n" character and/or end-of-file as item
;       delimiters.
;
;   o   Unlike standard edit functions, there is no Undo option for the Cut,
;       Delete, or Paste functions.  Use care when performing these functions.
;
;    o  This function was designed to manage small (<500 item) lists.  Although
;       the function should still operate, many operations will appear to be
;       sluggish if a large (>500) number of items are used.  These operations
;       will appear to be very sluggish if a very large (>2000) number of items
;       are used.
;
;
;   Programming Notes
;   =================
;    o  Variables.  In an attempt to easily identify the variables used this
;       function, variable names have been defined using the following syntax:
;
;        -  Function parameters.  Parameter variables are prefixed with "p_".
;           For example: p_ListTitle.
;
;        -  Global variables.  In an attempt to ensure that global variables
;           do not collide with other script variables, global variables are
;           prefixed with the function name.  For example:
;           ListManagerGUI_Command.
;
;        -  Static variables.  Most static variables are prefixed with "s_".
;           For example: s_ListWidthDefault.  Static variables used to represent
;           Win32 constants are named as defined by Microsoft.
;
;        -  Option variables.  For this function, option variables are
;           dynamically created from default and parameter values.  Option
;           variables are prefixed with "o_".  For example: o_EscapeToClose.
;
;           There are two types of option variables: Boolean and Assignment.
;
;           Boolean option variables are either enabled (set to TRUE) or
;           disabled (the variable does not exist (the default) or set to
;           FALSE).  To check to see if these options are enanbled or not, the
;           option variable can be tested by doing a simple boolean test.  For
;           example: "If o_OptionName" or "If not o_OptionName".
;
;           Assignment option variables are either enabled (contain any
;           non-blank value) or disabled (the variable does not exist (the
;           default) or is blank).  Since "0" is possible assignment value, you
;           can't do simple boolean tests to see if these options are enabled or
;           not.  Use StrLen or test for Space type for these options.  For
;           example: "If StrLen(o_AssignmentOption)" or "If o_AssignmentOption
;           is Space".
;
;        -  Local variables.  Local variables that may or may not be used in
;           multiple locations in the script are prefixed with "l_".  For
;           example: l_ReturnList.
;
;        -  Temporary variables.  Temporary local variables are prefixed with
;           "t_".  For example: t_Index.  Temporary variables should be used
;           sparingly.
;
;    o  In several sections of the code, a SendMessage command is used to
;       collect the select status of the first item.  This command is used in
;       lieu of an "if LV_GetNext(0)=1" test.  The SendMessage command "should"
;       be a bit faster than a "LV_GetNext(0)=1" command because only the first
;       item is checked whereas the "LV_GetNext(0)" command keeps looking until
;       it finds a selected item or until end-of-list.
;
;
;   Return Codes
;   ============
;   If p_Mode is "Edit", the entire list is returned.
;
;   If p_Mode is "Checklist", the entire list is returned along with the checked
;   or selected status (TRUE or FALSE) of each item.  The list is returned
;   using the following syntax:
;
;       {Item1Status}{Item1}{Delim}{Item2Status}{Item2}{Delim}...{ItemNStatus}{ItemN}
;
;       Example:  0Blue|0Green|1Red|0Yellow
;
;   If p_Mode is "Select", all checked items (if checkboxes are provided) or all
;   selected items are returned.  EXCEPTION:  If the ReturnListPos option is
;   enabled, the relative positions in the list that are checked/selected are
;   returned instead of the list items.
;
;   If p_Mode is "Display", nothing is returned.
;
;
;   ErrorLevel
;   ==========
;   If the function ends normally, Errorlevel is set to 0.  If the user closes
;   the window prematurely (clicks on the "Cancel button (if displayed), clicks
;   on the title bar Close button (if displayed and enabled), or hits the
;   "Escape" key (if EscapeToClose is enabled)), nothing is returned and
;   ErrorLevel is set to 1.
;
;   If the function is unable to create a ListManagerGUI window for any reason,
;   ErrorLevel is set to the word FAIL.
;
;   Important: ErrorLevel is a system variable and is used by many commands.
;   If you are unable to test ErrorLevel immediate after calling this function,
;   assign the value to another variable so that the return value is retained.
;
;
;   Credit/References
;   =================
;   The ideas and some of the code for sizing and positioning an Edit control
;   in the correct location within a ListView control were extracted from the
;   following:
;
;       Author: Micahs
;       Source: http://www.autohotkey.com/forum/viewtopic.php?t=19929
;
;
;   Calls To Other Functions
;   ========================
;   DisableCloseButton
;       Author:     Skan
;;;;;;       Source:     Included
;       Forum/Site: http://www.autohotkey.com/forum/viewtopic.php?p=62506#62506
;
;   ListManagerGUI_SwapRow
;       Source:     Included
;
;   PopupXY
;;;;;;       Source:     Included
;       Forum/Site: http://www.autohotkey.com/forum/viewtopic.php?t=20885
;
;
;   Customizing
;   ===========
;   This function can be customized in an infinite number of ways.  The quickest
;   and most effective customization is to change the default values for
;   the parameters.  Note that default values were purposely excluded from the
;   the function definition so that the default values would not have to be
;   changed twice -- once in the function definition and again in the
;   "Initialize" section of the code.
;
;-------------------------------------------------------------------------------
ListManagerGUI(p_Owner=""
              ,p_List=""
              ,p_DefaultList=""
              ,p_Delimiter=""
              ,p_Mode=""
              ,p_ModeOptions=""
              ,p_ListTitle=""
              ,p_WindowTitle=""
              ,p_ListOptions=""
              ,p_Font=""
              ,p_FontOptions=""
              ,p_GUIOptions=""
              ,p_BGColor="")
    {
    ;[====================]
    ;[  Global variables  ]
    ;[====================]
    Global ListManagerGUI_Command


    ;[====================]
    ;[  Static variables  ]
    ;[====================]
    Static Dummy423

          ,s_StartGUI:=54
                ;-- Default starting GUI window number for ListManagerGUI
                ;   window.  Change if desired.

          ,s_ActiveGUI
                ;-- This variable stores the currently active GUI.  If this
                ;   function is called while a ListManagerGUI window is still
                ;   active, this variable is used to temporarily disable the
                ;   active ListManagerGUI window so that an error message can be
                ;   displayed and dismissed.

          ,s_ActiveError:=False
                ;-- This variable is set to true if the function is currently
                ;   processing a duplicate-call error message.

          ,s_DataTypeList:="Integer,Float,Number,Digit,xDigit,Alpha,Upper,Lower,AlNum"
                ;-- These data types are supported by AutoHotkey via the
                ;   "If var is [not] type" statement.

          ,s_LVWDefault      :=300
          ,s_LVHDefault      :=200
          ,s_MarginX         :=006
          ,s_MarginY         :=006
          ,s_StartX          :=006 ;-- Should be >= s_MarginX
          ,s_StartY          :=010 ;-- Should be >= s_MarginY
          ,s_ReturnButtonW   :=070 ;-- Also used for the "Cancel" button
          ,s_ReturnButtonH   :=025 ;-- Also used for the "Cancel" button
          ,s_EditButtonW     :=050
          ,s_EditButtonH     :=020
          ,s_ObjectXGap      :=010
          ,s_ObjectYGap      :=010

          ;-- Buttons
          ,s_EditClassNN          :="Edit1"
          ,s_ReturnButtonClassNN  :="Button1"
          ,s_CancelButtonClassNN  :="Button2"
          ,s_GroupBoxClassNN      :="Button3"
          ,s_MoveUpButtonClassNN  :="Button4"
          ,s_MoveDownButtonClassNN:="Button5"
          ,s_InsertButtonClassNN  :="Button6"
          ,s_ModifyButtonClassNN  :="Button7"
          ,s_CutButtonClassNN     :="Button8"
          ,s_CopyButtonClassNN    :="Button9"
          ,s_PasteButtonClassNN   :="Button10"
          ,s_DeleteButtonClassNN  :="Button11"
          ,s_ListViewClassNN      :="SysListView321"
            ;-- Programming note: Static ClassNN names are identified and used
            ;   because many of the GUIControl commands do not work with static
            ;   variable names.

          ;-- Menu
          ,s_MoveUp_MenuItem         :="M&ove Up`tCtrl+Up"
          ,s_MoveDown_MenuItem       :="Move Dow&n`tCtrl+Down"

          ,s_Insert_MenuItem         :="&Insert`tInsert"
          ,s_Modify_MenuItem         :="&Modify`tF2"
          ,s_Cut_MenuItem            :="Cu&t`tCtrl+X"
          ,s_Copy_MenuItem           :="&Copy`tCtrl+C"
          ,s_CopyChecked_MenuItem    :="Copy Checked`tCtrl+Shift+C"
          ,s_Paste_MenuItem          :="&Paste`tCtrl+V"
          ,s_Delete_MenuItem         :="&Delete`tDelete"

          ,s_Uppercase_MenuItem      :="&Uppercase`tCtrl+U"
          ,s_Lowercase_MenuItem      :="&Lowercase`tCtrl+L"
          ,s_Capitalize_MenuItem     :="Capitali&ze`tCtrl+Shift+U"

          ,s_SelectAll_MenuItem      :="Select &All`tCtrl+A"
          ,s_UnselectAll_MenuItem    :="Unselect All`tCtrl+Shift+A"

          ,s_CheckAll_MenuItem       :="Chec&k All`tCtrl+K"
          ,s_UncheckAll_MenuItem     :="U&ncheck All`tCtrl+Shift+K"
          ,s_CheckSelected_MenuItem  :="Check Selected`tEnter"
          ,s_UncheckSelected_MenuItem:="Uncheck Selected`tAlt+Enter"

          ,s_Sort_MenuItem           :="&Sort`tCtrl+T"
          ,s_SortDesc_MenuItem       :="Sort &Descending`tCtrl+Shift+T"

          ,s_FileMenu_MenuItem       :="&File"
          ,s_EditMenu_MenuItem       :="&Edit"
          ,s_CheckMenu_MenuItem      :="&Check"
          ,s_SortMenu_MenuItem       :="&Sort"

          ;-- Edit control constants
          ,EM_SETSEL:=0xB1

          ;-- ListView constants
          ,LVIR_LABEL         :=0x2
          ,LVM_GETITEMSTATE   :=0x102C
          ,LVM_GETSUBITEMRECT :=0x1038  ;-- Gets cell width,height,X,Y
          ,LVIS_SELECTED      :=0x2
          ,LVIS_STATEIMAGEMASK:=0xF000

          ;-- System metrics
          ,SM_CYCAPTION
            ;-- 04. Height of a regular size caption area (title bar), in
            ;   pixels.

          ,SM_CYSMCAPTION
            ;-- 51. Height of a small caption (title bar), in pixels.

          ,SM_CXBORDER
            ;-- 05. Width of a window border, in pixels.

          ,SM_CYBORDER
            ;-- 06  Height of a window border, in pixels.

          ,SM_CYMENU
            ;-- 15. Height of a single-line menu bar, in pixels.

          ,SM_CXFIXEDFRAME
            ;-- 07. The width (in pixels) of the horizontal border for fixed
            ;   window.

          ,SM_CYFIXEDFRAME
            ;-- 08. The height (in pixels) of the horizontal border for fixed
            ;   window.

          ,SM_CXSIZEFRAME
            ;-- 32. The width (in pixels) of the horizontal border for a window
            ;   that can be resized.

          ,SM_CYSIZEFRAME
            ;-- 33. The height (in pixels) of the horizontal border for a window
            ;   that can be resized.

          ,SM_CXVSCROLL
            ;-- 02. Width of a vertical scroll bar, in pixels.


    ;*******************************
    ;*                             *
    ;*    ListManagerGUI window    *
    ;*       already showing?      *
    ;*                             *
    ;*******************************
    IfWinExist ahk_group ListManagerGUI_Group
        {
        if not s_ActiveError
            {
            ;-- Set s_ActiveError
            s_ActiveError:=True

            ;-- Disable active ListManagerGUI window
            gui %s_ActiveGUI%:+Disabled

            ;-- Alert the user.  Wait for a response.
            MsgBox
                ,262160  ;-- 262160=0 (OK button) + 16 (Error icon) + 262144 (AOT)
                ,%A_ThisFunc% Error,
                   (ltrim join`s
                    A %A_ThisFunc% window already exists.  Only one %A_ThisFunc%
                    window can be used at a time.  %A_Space%
                   )

            ;-- Enable and activate active ListManagerGUI window
            gui %s_ActiveGUI%:-Disabled
            gui %s_ActiveGUI%:Show

            ;-- Reset s_ActiveError
            s_ActiveError:=False
            }

        ;-- Return to sender
        Errorlevel=FAIL
        outputdebug,
           (ltrim join`s
            End Func: %A_ThisFunc% (A %A_ThisFunc% window already
            exists.  Errorlevel=FAIL)
           )

        return ""
        }


    ;********************
    ;*                  *
    ;*    Initialize    *
    ;*                  *
    ;********************
    l_ErrorLevel=0
    l_StringCaseSense:=A_StringCaseSense

    ;-- System metrics
    SysGet l_MonitorWorkArea,MonitorWorkArea

    if SM_CYCAPTION is Space
        {
        SysGet SM_CYCAPTION,4
        SysGet SM_CYSMCAPTION,51
        SysGet SM_CXBORDER,5
        SysGet SM_CYBORDER,6
        SysGet SM_CYMENU,15
        SysGet SM_CXFIXEDFRAME,7
        SysGet SM_CYFIXEDFRAME,8
        SysGet SM_CXSIZEFRAME,32
        SysGet SM_CYSIZEFRAME,33
        SysGet SM_CXVSCROLL,2
        }

    ;************************
    ;*                      *
    ;*      Parameters      *
    ;*    (Set defaults)    *
    ;*                      *
    ;************************
    ;[=========]
    ;[  Owner  ]
    ;[=========]
    p_Owner=%p_Owner%  ;-- AutoTrim
    if p_Owner is not Integer
        p_Owner=1
     else
        if p_Owner not between 1 and 99
            p_Owner=1

    ;-- Owner window exist?
    gui %p_Owner%:+LastFoundExist
    IfWinNotExist
        {
        outputdebug Owner window does not exist.  p_Owner=%p_Owner%
        p_Owner=0
        }

    ;[========]
    ;[  List  ]
    ;[========]
    ;(No action)

    ;[=============]
    ;[  Delimiter  ]
    ;[=============]
    if StrLen(p_Delimiter)=0
        p_Delimiter=|

    ;[========]
    ;[  Mode  ]
    ;[========]
    p_Mode=%p_Mode%  ;-- AutoTrim
    StringUpper p_Mode,p_Mode,T  ;-- Converted for display purposes
    if p_Mode not in Edit,Checklist,Select,Display
        p_Mode=Edit

    ;[================]
    ;[  Mode options  ]
    ;[================]
    if p_Mode=Edit
        l_DefaultModeOptions=
           (ltrim join`s
            +CancelButton
            +Close
            +ConfirmClose
            +ContextMenu
            +Copy
            +Delete
            +EscapeToClose
            +Insert
            +Menu
            +Modify
            +Move
            +Paste
            +ReturnButtonSave
            +Select
            +SelectMulti
           )

    if p_Mode=Checklist
        l_DefaultModeOptions=
           (ltrim join`s
            +CancelButton
            +Checkboxes
            +Close
            +ConfirmClose
            +ContextMenu
            +Copy
            +Delete
            +DoubleClick
            +EscapeToClose
            +Insert
            +Menu
            +Modify
            +Move
            +Paste
            +ReturnButtonSave
            +Select
            +SelectMulti
           )

    if p_Mode=Select
        l_DefaultModeOptions=
           (ltrim join`s
            +CancelButton
            +Close
            +Copy
            +DoubleClick
            +EscapeToClose
            +ReturnButtonSelect
            +Select
            +SelectionRequired
           )

    if p_Mode=Display
        l_DefaultModeOptions=
           (ltrim join`s
            +Close
            +EscapeToClose
            +ReturnButtonOK
           )

    if InStr(p_ModeOptions,"NoDefaults")=0
        p_ModeOptions:=l_DefaultModeOptions . A_Space . p_ModeOptions

    ;[==============]
    ;[  List title  ]
    ;[==============]
    p_ListTitle=%p_ListTitle%  ;-- AutoTrim

    ;[================]
    ;[  Window title  ]
    ;[================]
    p_WindowTitle=%p_WindowTitle%  ;-- AutoTrim
    if p_WindowTitle is Space
        {
        if p_Mode in Edit,Checklist
            p_WindowTitle:="Edit " . p_ListTitle

        if p_Mode=Select
            p_WindowTitle:="Select " . p_ListTitle

        if p_Mode=Display
            p_WindowTitle:=p_ListTitle
        }

    ;[================]
    ;[  List options  ]
    ;[================]
    p_ListOptions=%p_ListOptions%  ;-- AutoTrim

    ;-- Add default width/height options if they don't exist
    if not InStr(A_Space . p_ListOptions," w")
        p_ListOptions:=p_ListOptions . " w" . s_LVWDefault
    if not InStr(A_Space . p_ListOptions," h")
        p_ListOptions:=p_ListOptions . " h" . s_LVHDefault

    ;-- Disable sort
    if InStr(A_Space . p_ListOptions . A_Space," Sort ")
    or InStr(A_Space . p_ListOptions . A_Space," +Sort ")
        p_ListOptions:=p_ListOptions . " -Sort"

    if InStr(A_Space . p_ListOptions . A_Space," SortDesc ")
    or InStr(A_Space . p_ListOptions . A_Space," +SortDesc ")
        p_ListOptions:=p_ListOptions . " -SortDesc"

    ;[========]
    ;[  Font  ]
    ;[========]
    p_Font=%p_Font%  ;-- AutoTrim

    ;[================]
    ;[  Font options  ]
    ;[================]
    p_FontOptions=%p_FontOptions%  ;-- AutoTrim

    ;[===============]
    ;[  GUI Options  ]
    ;[===============]
    p_GUIOptions:=p_GUIOptions . " -MinimizeBox"
    p_GUIOptions=%p_GUIOptions%  ;-- AutoTrim

    ;[====================]
    ;[  Background color  ]
    ;[====================]
    p_BGColor=%p_BGColor%  ;-- AutoTrim


    ;********************************
    ;*                              *
    ;*    Extract working values    *
    ;*        from parameters       *
    ;*                              *
    ;********************************
    ;[================]
    ;[  Mode options  ]
    ;[================]
    ;-- Note: If undefined, assume to be OFF
    loop parse,p_ModeOptions,%A_Space%
        {
        ;-- Note: Invalid characters in the list of options may cause the script
        ;       to crash

        ;-- Blank or too short?
        if StrLen(A_LoopField)<2
            continue

        ;-- Break it down
        l_Option:=A_LoopField
        if SubStr(A_LoopField,1,1)="+"
        or SubStr(A_LoopField,1,1)="-"
            StringTrimLeft l_Option,l_Option,1

        ;-- AutoDeleteChars
        if SubStr(l_Option,1,15)="AutoDeleteChars"
            {
            o_AutoDeleteChars:=SubStr(l_Option,16)

            ;-- ASCII 09: Horizontal tab
            StringReplace
                ,o_AutoDeleteChars
                ,o_AutoDeleteChars
                ,\t
                ,`t
                ,All

            ;-- ASCII 10: Line feed (New line)
            StringReplace
                ,o_AutoDeleteChars
                ,o_AutoDeleteChars
                ,\n
                ,`n
                ,All

            ;-- ASCII 11: Vertical tab
            StringReplace
                ,o_AutoDeleteChars
                ,o_AutoDeleteChars
                ,\v
                ,`v
                ,All

            ;-- ASCII 12: Form feed
            StringReplace
                ,o_AutoDeleteChars
                ,o_AutoDeleteChars
                ,\f
                ,`f
                ,All

            ;-- ASCII 13: Return
            StringReplace
                ,o_AutoDeleteChars
                ,o_AutoDeleteChars
                ,\r
                ,`r
                ,All

            ;-- ASCII 32: Space
            StringReplace
                ,o_AutoDeleteChars
                ,o_AutoDeleteChars
                ,\s
                ,%A_Space%
                ,All

            continue
            }

        ;-- Return button
        if SubStr(l_Option,1,12)="ReturnButton"
            {
            o_ReturnButton:=SubStr(l_Option,13)
            continue
            }

        ;-- Data type
        if SubStr(l_Option,1,4)="Type"
            {
            l_DataType:=SubStr(l_Option,5)
            if l_DataType in %s_DataTypeList%
                if SubStr(A_LoopField,1,1)="-"
                    o_DataType:=""
                 else
                    o_DataType:=l_DataType

            continue
            }

        ;-- Regular option
        if SubStr(A_LoopField,1,1)="-"
            o_%l_Option%:=False
         else
            o_%l_Option%:=True
        }

    ;-- Enable format features?
    if (o_Modify and o_Select) and not (o_AutoLower or o_AutoUpper or o_AutoUpperT)
        o_Format:=True

    ;-- Case sensitive
    if o_CaseSensitive
        StringCaseSense On
     else
        StringCaseSense Off

    ;[================]
    ;[  List Options  ]
    ;[================]
    l_ListOptions:=""
    loop parse,p_ListOptions,%A_Space%
        {
        ;-- Note: Invalid values in p_ListOptions may cause the script to crash

        ;-- Blank or too short?
        if StrLen(A_LoopField)<2
            continue

        ;-- Assign to local var
        l_Option:=A_LoopField

        ;-- Width
        if SubStr(l_Option,1,1)="w"
            {
            o_ListWidth:=SubStr(l_Option,2)

            ;-- Determine maximum width
            l_MaxListWidth:=l_MonitorWorkAreaRight
                - (s_StartX
                +  s_MarginX
                + (s_ObjectXGap*2))

            ;---------- Border
            if InStr(p_GUIOptions,"-Caption")
                {
                if InStr(p_GUIOptions,"+Border")
                    l_MaxListWidth:=l_MaxListWidth-(SM_CXBORDER*2)

                if InStr(p_GUIOptions,"+Resize")
                    l_MaxListWidth:=l_MaxListWidth-(SM_CXFIXEDFRAME*2)
                        ;-- Note: "Fixed" border size used in this case
                }
             else
                {
                if InStr(p_GUIOptions,"+Resize")
                    l_MaxListWidth:=l_MaxListWidth-(SM_CXSIZEFRAME*2)
                 else
                    l_MaxListWidth:=l_MaxListWidth-(SM_CXFIXEDFRAME*2)
                }

            ;---------- Edit buttons
            if o_EditButtons
                l_MaxListWidth:=l_MaxListWidth-(s_EditButtonW+s_ObjectXGap)

            ;-- Adjust width?
            if (o_ListWidth>l_MaxListWidth)
                o_ListWidth:=l_MaxListWidth

            l_Option:="w" . o_ListWidth
            }

        ;-- Height
        if SubStr(A_LoopField,1,1)="h"
            {
            o_ListHeight:=SubStr(A_LoopField,2)

            ;-- Determine maximum height
            l_MaxListHeight:=l_MonitorWorkAreaBottom
                - (s_ReturnButtonH
                +  s_StartY
                +  s_MarginY
                + (s_ObjectYGap*4))

            ;---------- Titlebar
             if InStr(p_GUIOptions,"-Caption")=0
            and InStr(p_GUIOptions,"-Border")=0
                {
                if InStr(p_GUIOptions,"+ToolWindow")
                    l_MaxListHeight:=l_MaxListHeight-SM_CYSMCAPTION
                 else
                    l_MaxListHeight:=l_MaxListHeight-SM_CYCAPTION
                }

            ;---------- Border
            if InStr(p_GUIOptions,"-Caption")
                {
                if InStr(p_GUIOptions,"+Border")
                    l_MaxListHeight:=l_MaxListHeight-(SM_CYBORDER*2)

                if InStr(p_GUIOptions,"+Resize")
                    l_MaxListHeight:=l_MaxListHeight-(SM_CYFIXEDFRAME*2)
                        ;-- Note: "Fixed" border size used in this case
                }
             else
                {
                if InStr(p_GUIOptions,"+Resize")
                    l_MaxListHeight:=l_MaxListHeight-(SM_CYSIZEFRAME*2)
                 else
                    l_MaxListHeight:=l_MaxListHeight-(SM_CYFIXEDFRAME*2)
                }

            ;---------- Menu
            if o_Menu
                l_MaxListHeight:=l_MaxListHeight-SM_CYMENU

            ;-- Adjust height?
            if (o_ListHeight>l_MaxListHeight)
                o_ListHeight:=l_MaxListHeight

            l_Option:="h" . o_ListHeight
            }

        ;-- Add to l_ListOptions
        if l_ListOptions is Space
            l_ListOptions:=l_Option
         else
            l_ListOptions:=l_ListOptions . A_Space . l_Option
        }

    ;-- Assign updated options back to p_ListOptions
    p_ListOptions:=l_ListOptions

    ;-- Checkboxes
    if o_CheckBoxes
        p_ListOptions:=p_ListOptions . " +Checked"

    ;-- SelectMulti
    if not o_SelectMulti
        p_ListOptions:=p_ListOptions . " -Multi"


    ;************************************
    ;*                                  *
    ;*        Find available GUI        *
    ;*    (starting with s_StartGUI)    *
    ;*                                  *
    ;************************************
    l_GUI:=s_StartGUI
    loop
        {
        ;-- Window available?
        gui %l_GUI%:+LastFoundExist
        IfWinNotExist
            {
            s_ActiveGUI:=l_GUI
            outputdebug Window number used for %A_ThisFunc%=%l_GUI%
            break
            }

        ;-- Nothing available?
        if l_GUI=99
            {
            MsgBox
                ,262160  ;-- 262160=0 (OK button) + 16 (Error icon) + 262144 (AOT)
                ,%A_ThisFunc% Error,
                   (ltrim join`s
                    Unable to create a %A_ThisFunc% window.  GUI windows
                    %s_StartGUI% to 99 are already in use.  %A_Space%
                   )

            outputdebug,
               (ltrim join`s
                End Func: %A_ThisFunc% (Unable to create %A_ThisFunc%
                window.  Errorlevel=FAIL)
               )
            ErrorLevel=FAIL
            return
            }

        ;-- Increment window
        l_GUI++
        }


    ;*******************
    ;*                 *
    ;*    Build GUI    *
    ;*                 *
    ;*******************
    ;[==============]
    ;[  Build menu  ]
    ;[==============]
    gosub ListManagerGUI_BuildMenu


    ;[==============]
    ;[  Initialize  ]
    ;[==============]
    ;-- Set GUI default
    gui %l_GUI%:Default

    ;----------
    ;-- Owner?
    ;----------
    if p_Owner
        {
        ;-- Disable Owner, give ownership of GUI to Owner
        gui %p_Owner%:+Disabled
        gui +Owner%p_Owner%
            ;-- Note: These commands must be performed first and in this order.
        }

    ;---------------
    ;-- GUI Options
    ;---------------
    gui Margin,%s_MarginX%,%s_MarginY%

    l_MinSizeW:=s_StartX+(s_ReturnButtonW*2)+5+s_MarginY
    l_MinSizeH:=s_StartY+s_ReturnButtonH+s_MarginY
    gui +LabelListManagerGUI_
     || +Delimiter%p_Delimiter%
     || +MinSize%l_MinSizeW%x%l_MinSizeH%
    if p_GUIOptions is not Space
        gui %p_GUIOptions%

    ;------------
    ;-- Menu bar
    ;------------
    if o_Menu and (l_FileMenu or l_EditMenu or l_CheckMenu or l_SortMenu)
        gui Menu,ListManagerGUI_MenuBar

    ;------------------------
    ;-- Set background color
    ;------------------------
    if p_BGColor is not Space
        gui Color,%p_BGColor%

    ;[===================]
    ;[  Primary buttons  ]
    ;[===================]
    ;-- Note: These buttons are created first because they are static.
    ;
    ;-- Calculate YPos
    l_ReturnButtonYPos:=s_StartY+o_ListHeight+(s_ObjectYGap*4)
    if o_EditButtons
        if (o_ListHeight<(s_EditButtonH*9))
            l_ReturnButtonYPos:=s_StartY+(s_EditButtonH*9)+(s_ObjectYGap*4)

    ;-- Return button
    if StrLen(o_ReturnButton)
        {
        l_XPos:=s_StartX
        l_YPos:=l_ReturnButtonYPos
        l_ButtonOptions=

        ;-- Make default?
        if p_Mode=Select
            l_ButtonOptions:="+Default"
        }
     else
        {
        l_XPos=0
        l_YPos=0
        l_ButtonOptions:="+Default +Hidden"
        }

    gui Add
        ,Button
        ,x%l_XPos% y%l_YPos% w%s_ReturnButtonW% h%s_ReturnButtonH%
            || %l_ButtonOptions%
            || hWndListManagerGUI_ReturnButton_hWnd
            || gListManagerGUI_ReturnButton
        ,&%o_ReturnButton%

    ;-- Cancel button
    if o_CancelButton
        {
        if StrLen(o_ReturnButton)
            l_XPos:="+5"
         else
            l_XPos:=s_StartX

        l_YPos:=l_ReturnButtonYPos
        l_ButtonOptions=
        }
     else
        {
        l_XPos=0
        l_YPos=0
        l_ButtonOptions:="+Hidden"
        }

    gui Add
       ,Button
       ,x%l_XPos% y%l_YPos% w%s_ReturnButtonW% h%s_ReturnButtonH%
            || %l_ButtonOptions%
            || hWndListManagerGUI_CancelButton_hWnd
            || gListManagerGUI_CancelButton
       ,&Cancel

    ;-- GroupBox
    l_EditButtonWidth:=o_EditButtons ? s_EditButtonW+s_ObjectXGap : 0
    l_Width:=o_ListWidth+(s_ObjectXGap*2)+l_EditButtonWidth

    l_Height:=o_ListHeight+(s_ObjectYGap*3)
    if o_EditButtons
        if (o_ListHeight<(s_EditButtonH*9))
            l_Height:=(s_EditButtonH*9)+(s_ObjectYGap*3)

    gui Add
        ,GroupBox
        ,x%s_StartX% y%s_StartY% w%l_Width% h%l_Height%
            || hWndListManagerGUI_GroupBox_hWnd
        ,%p_ListTitle%

    ;-- Set font and font options
    gui Font,%p_FontOptions%,%p_Font%

    ;-- Calculate X/Y position for ListView.
    ;
    ;   Note: l_ListViewXPos and l_ListViewYPos also used by the
    ;   ListGUIManager_Modify routine to postion the Edit control.
    ;
    l_ListViewXPos:=s_StartX+s_ObjectXGap
    l_ListViewYPos:=s_StartY+(s_ObjectYGap*2)


    ;-- ListView
    static ListManagerGUI_List
    gui Add
        ,ListView
        ,x%l_ListViewXPos% y%l_ListViewYPos%
            || %p_ListOptions%
            || +AltSubmit
            || -Hdr
            || Count500             ;-- Small list.  Increase if necessary
            || +LV0x8000            ;-- LVS_EX_BORDERSELECT
;;;;;            || +List                ;-- List view (experimental)
;;;;;            || +LV0x100             ;-- Enables flat scroll bars in the list view (Doesn't do anything??)
;;;;;            || +LV0x40              ;-- One click activate (experimental)
;;;;;            || +LV0x8               ;-- Hot-track select (experimental)
;;;;;            || +LV0x80              ;-- Two-click activate (experimental)
            || hWndListManagerGUI_List_hWnd
            || vListManagerGUI_List
            || gListManagerGUI_ListAction
        ,ListView


    ;-- Set font color to default
    gui Font,cDefault

    ;-- Edit control
    gui Add
       ,Edit
;;;;;       ,x%l_ListViewXPos% y%l_ListViewYPos% w0 h0
       ,x%l_ListViewXPos% y%l_ListViewYPos% w100 h0     ;-- Temporary/Experiment
            || +Hide
            || hWndListManagerGUI_Edit_hWnd

    ;-- Restore the font to the system default GUI typeface, size, and color
    gui Font

    ;-- Adjust column width
    LV_ModifyCol(1,o_ListWidth-SM_CXVSCROLL)

    ;-- Edit buttons?
    if o_EditButtons
        {
        l_ButtonOptions:=o_Move and o_Select ? "" : "+Disabled"
        l_XPos:=o_ListWidth+s_StartX+(s_ObjectXGap*2)
        l_YPos:=s_StartY+(s_ObjectYGap*2)
        gui Add
           ,Button
           ,x%l_XPos% y%l_YPos% w%s_EditButtonW% h%s_EditButtonH%
                || %l_ButtonOptions%
                || hWndListManagerGUI_MoveUpButton_hWnd
                || gListManagerGUI_MoveUp
           ,Up

        gui Add
           ,Button
           ,y+0 w%s_EditButtonW% h%s_EditButtonH%
                || %l_ButtonOptions%
                || hWndListManagerGUI_MoveDownButton_hWnd
                || gListManagerGUI_MoveDown
           ,Down

        l_ButtonOptions:=o_Insert and o_Modify and o_Select ? "" : "+Disabled"
        gui Add
           ,Button
           ,y+%s_EditButtonH% w%s_EditButtonW% h%s_EditButtonH%
                || %l_ButtonOptions%
                || hWndListManagerGUI_InsertButton_hWnd
                || gListManagerGUI_Insert
           ,Insert

        l_ButtonOptions:=o_Modify and o_Select ? "" : "+Disabled"
        gui Add
           ,Button
           ,y+0 w%s_EditButtonW% h%s_EditButtonH%
                || %l_ButtonOptions%
                || hWndListManagerGUI_ModifyButton_hWnd
                || gListManagerGUI_Modify
           ,Modify

        l_ButtonOptions:=o_Copy and o_Delete and o_Select ? "" : "+Disabled"
        gui Add
           ,Button
           ,y+0 w%s_EditButtonW% h%s_EditButtonH%
                || %l_ButtonOptions%
                || hWndListManagerGUI_CutButton_hWnd
                || gListManagerGUI_Cut
           ,Cut

        l_ButtonOptions:=o_Copy and o_Select ? "" : "+Disabled"
        gui Add
           ,Button
           ,y+0 w%s_EditButtonW% h%s_EditButtonH%
                || %l_ButtonOptions%
                || hWndListManagerGUI_CopyButton_hWnd
                || gListManagerGUI_CopySelected
           ,Copy

        l_ButtonOptions:=o_Paste and o_Select ? "" : "+Disabled"
        gui Add
           ,Button
           ,y+0 w%s_EditButtonW% h%s_EditButtonH%
                || %l_ButtonOptions%
                || hWndListManagerGUI_PasteButton_hWnd
                || gListManagerGUI_Paste
           ,Paste

        l_ButtonOptions:=o_Delete and o_Select ? "" : "+Disabled"
        gui Add
           ,Button
           ,y+0 w%s_EditButtonW% h%s_EditButtonH%
                || %l_ButtonOptions%
                || hWndListManagerGUI_DeleteButton_hWnd
                || gListManagerGUI_Delete
           ,Delete
        }

    ;[========================]
    ;[  Rebuild default list  ]
    ;[========================]
    l_DefaultList:=p_Delimiter
    loop parse,p_DefaultList,%p_Delimiter%
        {
        l_Text:=A_LoopField

        ;-- Auto conversion
        if o_AutoDeleteSpace
            {
            StringReplace l_Text,l_Text,%A_Space%,,All
            StringReplace l_Text,l_Text,%A_Tab%,,All
            StringReplace l_Text,l_Text,`n,,All
            StringReplace l_Text,l_Text,`r,,All
            StringReplace l_Text,l_Text,`v,,All
            StringReplace l_Text,l_Text,`f,,All
            }

        if o_AutoLower
            StringLower l_Text,l_Text

        if o_AutoTrim
            {
            l_Text=%l_Text%
            l_Text:=RegExReplace(l_Text,"^[ \t\r\n\v\f]+","")  ;-- Leading
            l_Text:=RegExReplace(l_Text,"[ \t\r\n\v\f]+$","")  ;-- Trailing
            }

        if o_AutoUpper
            StringUpper l_Text,l_Text

        if o_AutoUpperT
            StringUpper l_Text,l_Text,T

        if StrLen(o_AutoDeleteChars)
            loop parse,o_AutoDeleteChars
                StringReplace l_Text,l_Text,%A_LoopField%,,All
            ;--
            ;   Note: Since the AutoDeleteChars option may include case
            ;   sensitive comparisons, it must be performed after all other
            ;   "Auto{xxx}" options.

        ;-- Drop blank
        if o_NoBlank
            if l_Text is Space
                continue

        ;-- Drop invalid type
        if o_DataType
            if l_Text is not %o_DataType%
                continue

        ;-- Add to the default list
        l_DefaultList:=l_DefaultList .  l_Text . p_Delimiter
        }

    ;[=============]
    ;[  Load list  ]
    ;[=============]
    l_SaveList=
    l_UniqueList:=p_Delimiter
    loop parse,p_List,%p_Delimiter%
        {
        if p_Mode=Checklist
            l_Text:=SubStr(A_LoopField,2)
         else
            l_Text:=A_LoopField

        ;-- Auto conversion
        if o_AutoDeleteSpace
            {
            StringReplace l_Text,l_Text,%A_Space%,,All
            StringReplace l_Text,l_Text,%A_Tab%,,All
            StringReplace l_Text,l_Text,`n,,All
            StringReplace l_Text,l_Text,`r,,All
            StringReplace l_Text,l_Text,`v,,All
            StringReplace l_Text,l_Text,`f,,All
            }

        if o_AutoLower
            StringLower l_Text,l_Text

        if o_AutoTrim
            {
            l_Text=%l_Text%
            l_Text:=RegExReplace(l_Text,"^[ \t\r\n\v\f]+","")  ;-- Leading
            l_Text:=RegExReplace(l_Text,"[ \t\r\n\v\f]+$","")  ;-- Trailing
            }

        if o_AutoUpper
            StringUpper l_Text,l_Text

        if o_AutoUpperT
            StringUpper l_Text,l_Text,T

        if StrLen(o_AutoDeleteChars)
            loop parse,o_AutoDeleteChars
                StringReplace l_Text,l_Text,%A_LoopField%,,All
            ;--
            ;   Note: Since the AutoDeleteChars option may include case
            ;   sensitive comparisons, it must be performed after all other
            ;   "Auto{xxx}" options.

        ;-- Drop blank
        if o_NoBlank
            if l_Text is Space
                continue

        ;-- Drop duplicates
        if o_NoDuplicates
            if InStr(l_UniqueList,p_Delimiter . l_Text . p_Delimiter,o_CaseSensitive,1)
                continue

        ;-- Drop invalid type
        if o_DataType
            if l_Text is not %o_DataType%
                continue

        ;-- Check/Select item
        l_Options=
        if p_Mode=Checklist
            if SubStr(A_LoopField,1,1)
                if o_Checkboxes
                    l_Options:="+Check"
                 else
                    if o_Select
                        l_Options:="+Select"

        if InStr(l_DefaultList,p_Delimiter . l_Text . p_Delimiter,o_CaseSensitive,1)
            if o_CheckBoxes
                l_Options:="+Check"
             else
                if o_Select
                    l_Options:="+Select"

        ;-- Add to ListView
        LV_Add(l_Options,l_Text)

        ;-- Add to the save list
        if o_ConfirmClose
            {
            if p_Mode=Checklist
                l_SaveText:=SubStr(A_LoopField,1,1) . l_Text
             else
                l_SaveText:=l_Text

            if l_SaveList is Space
                l_SaveList:=l_SaveText
             else
                l_SaveList:=l_SaveList . p_Delimiter . l_SaveText
            }

        ;-- Add to the unique list
        if o_NoDuplicates
            l_UniqueList:=l_UniqueList .  l_Text . p_Delimiter
        }

    ;-- Housekeeping
    l_UniqueList:=""

    ;-- AutoSort
    if o_AutoSort  ;-- Note: o_AutoSort is not dependent on the o_Sort option
        LV_ModifyCol(1,"Sort")

    ;-- AutoSortDesc
    if o_AutoSortDesc  ;-- Note: o_AutoSortDesc is not dependent on the o_Sort option
        LV_ModifyCol(1,"SortDesc")

    ;-- Check all
    if o_CheckAll
        gosub ListManagerGUI_CheckAll

    ;-- Select all
    if o_SelectAll
        gosub ListManagerGUI_SelectAll

    ;-- If anything is selected, set keyboard focus on the first selected row
    if LV_GetCount("Selected")
        LV_Modify(LV_GetNext(0),"+Focus")

    ;-- Update attributes
    gosub ListManagerGUI_UpdateAttributes

    ;-- Move focus to list
    GUIControl Focus,%s_ListViewClassNN%


    ;------------------------------------------------------------ Move this code to the top of this section??
    ;-- Collect GUI hWnd
    gui %l_GUI%:+LastFound
    WinGet ListManagerGUI_hWnd,ID
    GroupAdd ListManagerGUI_Group,ahk_id %ListManagerGUI_hWnd%

    ;-- Disable title bar Close button?
    if not o_Close
        DisableCloseButton(ListManagerGUI_hWnd)
    ;------------------------------------------------------ (End) Move this code to the top of this section??

    ;[==========]
    ;[  Attach  ]
    ;[==========]
    if StrLen(o_ReturnButton)
        Attach(ListManagerGUI_ReturnButton_hWnd,"y")

    if o_CancelButton
        Attach(ListManagerGUI_CancelButton_hWnd,"y")

    Attach(ListManagerGUI_GroupBox_hWnd,"w h")
    Attach(ListManagerGUI_List_hWnd,"w h")
    Attach(ListManagerGUI_Edit_hWnd,"w")

    ;-- Edit buttons?
    if o_EditButtons
        {
        Attach(ListManagerGUI_MoveUpButton_hWnd  ,"x")
        Attach(ListManagerGUI_MoveDownButton_hWnd,"x")
        Attach(ListManagerGUI_InsertButton_hWnd  ,"x")
        Attach(ListManagerGUI_ModifyButton_hWnd  ,"x")
        Attach(ListManagerGUI_CutButton_hWnd     ,"x")
        Attach(ListManagerGUI_CopyButton_hWnd    ,"x")
        Attach(ListManagerGUI_PasteButton_hWnd   ,"x")
        Attach(ListManagerGUI_DeleteButton_hWnd  ,"x")
        }

    ;[===========]
    ;[  Show it  ]
    ;[===========]
    if p_Owner
        {
        ;-- Render but don't show
        gui Show,Hide,%p_WindowTitle%

        ;-- Calculate X/Y and Show it
        PopupXY(p_Owner,l_GUI,PosX,PosY)
        gui Show,x%PosX% y%PosY%
        }
     else
        gui Show,,%p_WindowTitle%

    ;[=====================]
    ;[  Loop until window  ]
    ;[      is closed      ]
    ;[=====================]
    loop
        {
        sleep 50  ;-- Relatively short sleep to support responsive hotkeys

        ;-- Break if window has closed
        IfWinNotExist ahk_id %ListManagerGUI_hWnd%
            break

        ;-- Process command
        if ListManagerGUI_Command
            {
            gosub ListManagerGUI_%ListManagerGUI_Command%
            ListManagerGUI_Command=
            }
        }

    ;[===================]
    ;[  Set GUI default  ]
    ;[   back to Owner   ]
    ;[===================]
    if p_Owner
        gui %p_Owner%:Default

    ;[================]
    ;[  Housekeeping  ]
    ;[================]
    StringCaseSense %l_StringCaseSense%

    ;[====================]
    ;[  Return to sender  ]
    ;[====================]
    ErrorLevel:=l_ErrorLevel
    return l_ReturnList
        ;-- End of ListManagerGUI processing



    ;********************************************
    ;*                                          *
    ;*                                          *
    ;*        ListManagerGUI subroutines        *
    ;*                                          *
    ;*                                          *
    ;********************************************
    ;**************************
    ;*                        *
    ;*       Build menu       *
    ;*    (ListManagerGUI)    *
    ;*                        *
    ;**************************
    ListManagerGUI_BuildMenu:

    ;-- Menu enabled?
     if not o_Menu
    and not o_ContextMenu
        return

    ;[=============]
    ;[  File Menu  ]
    ;[=============]
    ;-- Initialize
    l_FileMenu:=False
    l_Separator:=False

    Menu ListManagerGUI_FileMenu    ;-- Dummy
        ,Add

    Menu ListManagerGUI_FileMenu    ;-- Reset menu
        ,Delete

    ;-- Return for Edit mode
    if p_Mode in Edit,Checklist
        {
        l_Return_MenuItem:="&Save"
        if StrLen(o_ReturnButton)
            l_Return_MenuItem:="&" . o_ReturnButton

        l_Return_MenuItem:=l_Return_MenuItem . "`tCtrl+S"

        Menu ListManagerGUI_FileMenu
            ,Add
            ,%l_Return_MenuItem%
            ,ListManagerGUI_ReturnButton

        l_FileMenu:=True
        l_Separator:=True
        }

    ;-- Return for Select mode
    if p_Mode=Select
        {
        l_Return_MenuItem:="&Select"
        if StrLen(o_ReturnButton)
            l_Return_MenuItem:="&" . o_ReturnButton

        l_Return_MenuItem:=l_Return_MenuItem . "`tCtrl+S"

        Menu ListManagerGUI_FileMenu
            ,Add
            ,%l_Return_MenuItem%
            ,ListManagerGUI_ReturnButton

        l_FileMenu:=True
        l_Separator:=True
        }

    ;-- Close
    if o_Close
        {
        if l_Separator
            Menu ListManagerGUI_FileMenu,Add

        Menu ListManagerGUI_FileMenu
            ,Add
            ,&Close`tAlt+F4
            ,ListManagerGUI_Close

        l_FileMenu:=True
        }

    ;[=============]
    ;[  Edit Menu  ]
    ;[=============]
    ;-- Initialize
    l_EditMenu:=False
    l_Separator:=False

    Menu ListManagerGUI_EditMenu  ;-- Dummy
        ,Add

    Menu ListManagerGUI_EditMenu  ;-- Reset menu
        ,Delete

    ;------------------
    ;-- Edit functions
    ;------------------
    ;-- Separator
    if l_Separator
        Menu ListManagerGUI_EditMenu,Add

    l_Separator:=False

    ;-- Insert
    if o_Insert and o_Modify and o_Select
        {
        Menu ListManagerGUI_EditMenu
            ,Add
            ,%s_Insert_MenuItem%
            ,ListManagerGUI_Insert

        l_Separator:=True
        l_EditMenu:=True
        }

    ;-- Modify
    if o_Modify and o_Select
        {
        Menu ListManagerGUI_EditMenu
            ,Add
            ,%s_Modify_MenuItem%
            ,ListManagerGUI_Modify

        l_EditMenu:=True
        l_Separator:=True
        }

    ;-- Cut
    if o_Copy and o_Delete and o_Select
        {
        Menu ListManagerGUI_EditMenu
            ,Add
            ,%s_Cut_MenuItem%
            ,ListManagerGUI_Cut

        l_EditMenu:=True
        l_Separator:=True
        }

    ;-- Copy
    if o_Copy and o_Select
        {
        Menu ListManagerGUI_EditMenu
            ,Add
            ,%s_Copy_MenuItem%
            ,ListManagerGUI_CopySelected

        l_EditMenu:=True
        l_Separator:=True
        }

    ;-- Copy checked
    if o_Copy and o_Checkboxes
        {
        Menu ListManagerGUI_EditMenu
            ,Add
            ,%s_CopyChecked_MenuItem%
            ,ListManagerGUI_CopyChecked

        l_EditMenu:=True
        l_Separator:=True
        }

    ;-- Paste
    if o_Paste and o_Select
        {
        Menu ListManagerGUI_EditMenu
            ,Add
            ,%s_Paste_MenuItem%
            ,ListManagerGUI_Paste

        l_EditMenu:=True
        l_Separator:=True
        }

    ;-- Delete
    if o_Delete and o_Select
        {
        Menu ListManagerGUI_EditMenu
            ,Add
            ,%s_Delete_MenuItem%
            ,ListManagerGUI_Delete

        l_EditMenu:=True
        l_Separator:=True
        }

    ;---------------------
    ;-- Format operations
    ;---------------------
    if o_Format
        {
        if l_Separator
            Menu ListManagerGUI_EditMenu,Add

        Menu ListManagerGUI_EditMenu
            ,Add
            ,%s_Uppercase_MenuItem%
            ,ListManagerGUI_Uppercase

        Menu ListManagerGUI_EditMenu
            ,Add
            ,%s_Lowercase_MenuItem%
            ,ListManagerGUI_Lowercase

        Menu ListManagerGUI_EditMenu
            ,Add
            ,%s_Capitalize_MenuItem%
            ,ListManagerGUI_Capitalize

        l_EditMenu:=True
        l_Separator:=True
        }

    ;-------------------
    ;-- Move operations
    ;-------------------
    if o_Move and o_Select
        {
        if l_Separator
            Menu ListManagerGUI_EditMenu,Add

        Menu ListManagerGUI_EditMenu
            ,Add
            ,%s_MoveUp_MenuItem%
            ,ListManagerGUI_MoveUp

        Menu ListManagerGUI_EditMenu
            ,Add
            ,%s_MoveDown_MenuItem%
            ,ListManagerGUI_MoveDown

        l_EditMenu:=True
        l_Separator:=True
        }

    ;----------
    ;-- Select
    ;----------
    if o_Select and o_SelectMulti
        {
        if l_Separator
            Menu ListManagerGUI_EditMenu,Add

        Menu ListManagerGUI_EditMenu
            ,Add
            ,%s_SelectAll_MenuItem%
            ,ListManagerGUI_SelectAll

        l_EditMenu:=True
        l_Separator:=True
        }

    ;[==============]
    ;[  Check Menu  ]
    ;[==============]
    ;-- Initialize
    l_CheckMenu:=False

    Menu ListManagerGUI_CheckMenu  ;-- Dummy
        ,Add

    Menu ListManagerGUI_CheckMenu  ;-- Reset menu
        ,Delete

    ;-- Buid menu
    if o_CheckBoxes
        {
        l_CheckMenu:=True

        Menu ListManagerGUI_CheckMenu
            ,Add
            ,%s_CheckAll_MenuItem%
            ,ListManagerGUI_CheckAll

        Menu ListManagerGUI_CheckMenu
            ,Add
            ,%s_UncheckAll_MenuItem%
            ,ListManagerGUI_UncheckAll

        ;-- Check and Select
        if o_Select
            {
            Menu ListManagerGUI_CheckMenu
                ,Add

            Menu ListManagerGUI_CheckMenu
                ,Add
                ,%s_CheckSelected_MenuItem%
                ,ListManagerGUI_CheckSelected

            Menu ListManagerGUI_CheckMenu
                ,Add
                ,%s_UncheckSelected_MenuItem%
                ,ListManagerGUI_UncheckSelected
            }
        }

    ;[=============]
    ;[  Sort Menu  ]
    ;[=============]
    ;-- Initialize
    l_SortMenu:=False

    Menu ListManagerGUI_SortMenu  ;-- Dummy
        ,Add

    Menu ListManagerGUI_SortMenu  ;-- Reset menu
        ,Delete

    ;-- Build menu
    if o_Sort
        {
        l_SortMenu:=True

        Menu ListManagerGUI_SortMenu
            ,Add
            ,%s_Sort_MenuItem%
            ,ListManagerGUI_Sort

        Menu ListManagerGUI_SortMenu
            ,Add
            ,%s_SortDesc_MenuItem%
            ,ListManagerGUI_SortDesc
        }

    ;[===========]
    ;[  MenuBar  ]
    ;[===========]
    ;-- Initialize
    Menu ListManagerGUI_MenuBar  ;-- Dummy
        ,Add

    Menu ListManagerGUI_MenuBar  ;-- Reset menu
        ,Delete

    if l_FileMenu
        Menu ListManagerGUI_MenuBar
            ,Add
            ,%s_FileMenu_MenuItem%
            ,:ListManagerGUI_FileMenu

    if l_EditMenu
        Menu ListManagerGUI_MenuBar
            ,Add
            ,%s_EditMenu_MenuItem%
            ,:ListManagerGUI_EditMenu


    if l_CheckMenu
        Menu ListManagerGUI_MenuBar
            ,Add
            ,%s_CheckMenu_MenuItem%
            ,:ListManagerGUI_CheckMenu


    if l_SortMenu
        Menu ListManagerGUI_MenuBar
            ,Add
            ,%s_SortMenu_MenuItem%
            ,:ListManagerGUI_SortMenu

    ;[================]
    ;[  Context menu  ]
    ;[================]
    ;-- Initialize
    Menu ListManagerGUI_ContextMenu  ;-- Dummy
        ,Add

    Menu ListManagerGUI_ContextMenu  ;-- Reset menu
        ,Delete

    if l_EditMenu
        Menu ListManagerGUI_ContextMenu
            ,Add
            ,%s_EditMenu_MenuItem%
            ,:ListManagerGUI_EditMenu

    if l_CheckMenu
        Menu ListManagerGUI_ContextMenu
            ,Add
            ,%s_CheckMenu_MenuItem%
            ,:ListManagerGUI_CheckMenu

    if l_SortMenu
        Menu ListManagerGUI_ContextMenu
            ,Add
            ,%s_SortMenu_MenuItem%
            ,:ListManagerGUI_SortMenu

    return


    ;**********************
    ;*                    *
    ;*    Context Menu    *
    ;*    (PrimaryGUI)    *
    ;*                    *
    ;**********************
    ListManagerGUI_ContextMenu:

    ;-- ContextMenu enabled?
    if not o_ContextMenu
        return

    ;-- Currently modifying?
    if l_ModifyFlag
        return

    ;-- On list?
    if A_GUIControl=ListManagerGUI_List
        {
        ;-- At least 2 sub-menus defined?
        if (l_EditMenu and l_CheckMenu)
        or (l_EditMenu and l_SortMenu)
        or (l_CheckMenu and l_SortMenu)
           {
            ;-- If the menu bar has been defined and the Edit sub-menu exists,
            ;   only show the Edit sub-menu, otherwise show the full context
            ;   menu
            ;
            if o_Menu and l_EditMenu
                Menu ListManagerGUI_EditMenu,Show,%A_GuiX%,%A_GuiY%
             else
                Menu ListManagerGUI_ContextMenu,Show,%A_GuiX%,%A_GuiY%
           }
         else
            if l_EditMenu
                Menu ListManagerGUI_EditMenu,Show,%A_GuiX%,%A_GuiY%
             else
                if l_CheckMenu
                    Menu ListManagerGUI_CheckMenu,Show,%A_GuiX%,%A_GuiY%
                 else
                    if l_SortMenu
                        Menu ListManagerGUI_SortMenu,Show,%A_GuiX%,%A_GuiY%
        }

    return


    ;**************************
    ;*                        *
    ;*         Resize         *
    ;*    (ListManagerGUI)    *
    ;*                        *
    ;**************************
    ListManagerGUI_Size:

    ;-- Calculate column width
    l_ColumnWidth:=A_GUIWidth
        - (SM_CXVSCROLL+4
        +  s_StartX
        +  s_MarginX
        + (s_ObjectXGap*2))

    if o_EditButtons
        l_ColumnWidth:=l_ColumnWidth-(s_EditButtonW+s_ObjectXGap)

    ;-- Resize ListView column
    LV_ModifyCol(1,l_ColumnWidth)

    ;-- Redraw
    if l_ModifyFlag
        SetTimer ListManagerGUI_Redraw
            ;-- Programming note: Redrawing after resizing fixes a minor
            ;   rendering problem that occurs when resizing while the Edit field
            ;   is showing.

    return


    ;**************************
    ;*                        *
    ;*         Redraw         *
    ;*    (ListManagerGUI)    *
    ;*                        *
    ;**************************
    ListManagerGUI_Redraw:
    SetTimer ListManagerGUI_Redraw,Off
    WinSet Redraw,,ahk_id %ListManagerGUI_hWnd%
    return


    ;**************************
    ;*                        *
    ;*       List action      *
    ;*    (ListManagerGUI)    *
    ;*                        *
    ;**************************
    ListManagerGUI_ListAction:
    Critical
    if A_GUIEvent not in i,DoubleClick
        {
        Critical Off
        return
        }

    ;[===============]
    ;[  Item change  ]
    ;[===============]
    if A_GUIEvent=I
        {
        ;-- Select
        if InStr(ErrorLevel,"S",true,1)
            if not o_Select
                {
                LV_Modify(A_EventInfo,"-Select -Focus")
                Critical Off
                return
                    ;-- This code creates the illusion that the ListView items
                    ;   are not selectable.  As soon as a ListView item is
                    ;   selected, it is immediately unselected.  For most
                    ;   computers, the user cannot tell that the item was ever
                    ;   selected.
                }

        SetTimer ListManagerGUI_UpdateAttributes,-1
        Critical Off
        return
        }

    ;[================]
    ;[  Double-click  ]
    ;[================]
    if A_GUIEvent=DoubleClick
        {
        ;-- Doubleclick enabled?
        if o_DoubleClick
            {
            ;-- Checkboxes
            if o_Checkboxes
                {
                l_Row=0
                loop
                    {
                    l_Row:=LV_GetNext(l_Row)
                    if l_Row=0
                        break

                    if GetKeyState("Alt","P")
                        LV_Modify(l_Row,"-Check")
                     else
                        LV_Modify(l_Row,"+Check")
                    }
                }
             else
                {
                if p_Mode in Edit,Checklist
                    gosub ListManagerGUI_Modify
                 else
                    {
                    if p_Mode=Select
                        {
                        ;-- Anything selected?
                        if LV_GetNext(0)  ;-- Seems like a redundant test but it's not
                            gosub ListManagerGUI_ReturnButton
                        }
                    }
                }
            }
        }

    ;-- Return to sender
    Critical Off
    return


    ;***************************
    ;*                         *
    ;*    Update attributes    *
    ;*     (ListManagerGUI)    *
    ;*                         *
    ;***************************
    ListManagerGUI_UpdateAttributes:

    ;-- Set GUI default (Required for menu and timer threads)
    gui %l_GUI%:Default

    ;[===========]
    ;[  Buttons  ]
    ;[===========]
    ;-- Return button
     if (p_Mode="Select" and o_SelectionRequired)   ;-- Note: Button is auto-enabled for all other conditions
        {
        ;-- Checkboxes
        if o_CheckBoxes
            {
            ;-- Anything checked?
            if LV_GetNext(0,"Checked")
                GUIControl Enable,%s_ReturnButtonClassNN%
             else
                GUIControl Disable,%s_ReturnButtonClassNN%
            }
         else ;-- Regular
            {
            ;-- Anything selected?
            if LV_GetCount("Selected")
                GUIControl Enable,%s_ReturnButtonClassNN%
             else
                GUIControl Disable,%s_ReturnButtonClassNN%
            }
        }

    ;-- Edit buttons
    if o_EditButtons
        {
        ;-- Anything focused?
        if LV_GetNext(0,"Focused")
            {
            if o_Modify and o_Select
                GUIControl Enable,%s_ModifyButtonClassNN%
            }
         else
            {
            if o_Modify and o_Select
                GUIControl Disable,%s_ModifyButtonClassNN%
            }

        ;-- Anything selected?
        if LV_GetCount("Selected")
            {
            ;-- Move buttons
            if o_Move and o_Select
                {
                ;-- Get select status of 1st item
                SendMessage
                    ,LVM_GETITEMSTATE
                    ,0
                    ,LVIS_SELECTED
                    ,%s_ListViewClassNN%
                    ,ahk_id %ListManagerGUI_hWnd%

                ;-- First item selected?
                if (ErrorLevel=LVIS_SELECTED)
                    GUIControl Disable,%s_MoveUpButtonClassNN%
                 else
                    GUIControl Enable,%s_MoveUpButtonClassNN%

                ;-- Last item selected?
                if LV_GetNext(LV_GetCount()-1)=LV_GetCount()
                    GUIControl Disable,%s_MoveDownButtonClassNN%
                 else
                    GUIControl Enable,%s_MoveDownButtonClassNN%
                }

            ;-- And the rest...
            if o_Copy and o_Delete and o_Select
                GUIControl Enable,%s_CutButtonClassNN%

            if o_Copy and o_Select
                GUIControl Enable,%s_CopyButtonClassNN%

            if o_Delete and o_Select
                GUIControl Enable,%s_DeleteButtonClassNN%
            }
         else
            {
            if o_Move and o_Select
                {
                GUIControl Disable,%s_MoveUpButtonClassNN%
                GUIControl Disable,%s_MoveDownButtonClassNN%
                }

            if o_Copy and o_Delete and o_Select
                GUIControl Disable,%s_CutButtonClassNN%

            if o_Copy and o_Select
                GUIControl Disable,%s_CopyButtonClassNN%

            if o_Delete and o_Select
                GUIControl Disable,%s_DeleteButtonClassNN%
            }
        }

    ;[========]
    ;[  Menu  ]
    ;[========]
    if o_Menu or o_ContextMenu
        {
        ;-- Return menu item
         if (p_Mode="Select" and o_SelectionRequired)
                ;-- Note: Menu item is auto-enabled for all other conditions
            {
            ;-- Checkboxes
            if o_CheckBoxes
                {
                ;-- Anything checked?
                if LV_GetNext(0,"Checked")
                    Menu ListManagerGUI_FileMenu
                        ,Enable
                        ,%l_Return_MenuItem%
                 else
                    Menu ListManagerGUI_FileMenu
                        ,Disable
                        ,%l_Return_MenuItem%
                }
             else ;-- Regular
                {
                ;-- Anything selected?
                if LV_GetCount("Selected")
                    Menu ListManagerGUI_FileMenu
                        ,Enable
                        ,%l_Return_MenuItem%
                 else
                    Menu ListManagerGUI_FileMenu
                        ,Disable
                        ,%l_Return_MenuItem%
                }
            }

        ;-- Anything focused?
        if LV_GetNext(0,"Focused")
            {
            if o_Modify and o_Select
                Menu ListManagerGUI_EditMenu
                    ,Enable
                    ,%s_Modify_MenuItem%
            }
         else
            {
            if o_Modify and o_Select
                Menu ListManagerGUI_EditMenu
                    ,Disable
                    ,%s_Modify_MenuItem%
            }

        ;-- Anything selected?
        if LV_GetCount("Selected")
            {
            if o_Move and o_Select
                {
                ;-- Get select status of 1st item
                SendMessage
                    ,LVM_GETITEMSTATE
                    ,0
                    ,LVIS_SELECTED
                    ,%s_ListViewClassNN%
                    ,ahk_id %ListManagerGUI_hWnd%

                ;-- First item selected?
                if (ErrorLevel=LVIS_SELECTED)
                    Menu ListManagerGUI_EditMenu
                        ,Disable
                        ,%s_MoveUp_MenuItem%
                 else
                    Menu ListManagerGUI_EditMenu
                        ,Enable
                        ,%s_MoveUp_MenuItem%

                ;-- Last selected?
                if LV_GetNext(LV_GetCount()-1)=LV_GetCount()
                    Menu ListManagerGUI_EditMenu
                        ,Disable
                        ,%s_MoveDown_MenuItem%
                 else
                    Menu ListManagerGUI_EditMenu
                        ,Enable
                        ,%s_MoveDown_MenuItem%
                }

            if o_Copy and o_Delete and o_Select
                Menu ListManagerGUI_EditMenu
                    ,Enable
                    ,%s_Cut_MenuItem%

            if o_Copy and o_Select
                Menu ListManagerGUI_EditMenu
                    ,Enable
                    ,%s_Copy_MenuItem%

            if o_Delete and o_Select
                Menu ListManagerGUI_EditMenu
                    ,Enable
                    ,%s_Delete_MenuItem%

            if o_Format
                {
                Menu ListManagerGUI_EditMenu
                    ,Enable
                    ,%s_Uppercase_MenuItem%

                Menu ListManagerGUI_EditMenu
                    ,Enable
                    ,%s_Lowercase_MenuItem%

                Menu ListManagerGUI_EditMenu
                    ,Enable
                    ,%s_Capitalize_MenuItem%
                }
            }
         else
            {
            if o_Move and o_Select
                {
                Menu ListManagerGUI_EditMenu
                    ,Disable
                    ,%s_MoveUp_MenuItem%

                Menu ListManagerGUI_EditMenu
                    ,Disable
                    ,%s_MoveDown_MenuItem%
                }

            if o_Copy and o_Delete and o_Select
                Menu ListManagerGUI_EditMenu
                    ,Disable
                    ,%s_Cut_MenuItem%

            if o_Copy and o_Select
                Menu ListManagerGUI_EditMenu
                    ,Disable
                    ,%s_Copy_MenuItem%

            if o_Delete and o_Select
                Menu ListManagerGUI_EditMenu
                    ,Disable
                    ,%s_Delete_MenuItem%

            if o_Format
                {
                Menu ListManagerGUI_EditMenu
                    ,Disable
                    ,%s_Uppercase_MenuItem%

                Menu ListManagerGUI_EditMenu
                    ,Disable
                    ,%s_Lowercase_MenuItem%

                Menu ListManagerGUI_EditMenu
                    ,Disable
                    ,%s_Capitalize_MenuItem%
                }
            }

        ;-- Check menu
        if l_CheckMenu
            {
            ;-- Copy checked
            if o_Copy
                {
                ;-- Anything checked?
                if LV_GetNext(0,"Checked")
                    Menu ListManagerGUI_EditMenu
                        ,Enable
                        ,%s_CopyChecked_MenuItem%
                 else
                    Menu ListManagerGUI_EditMenu
                        ,Disable
                        ,%s_CopyChecked_MenuItem%
                }

            ;-- Check/Uncheck selected
            if o_Select and o_SelectMulti
                {
                ;-- Anything selected
                if LV_GetCount("Selected")
                    {
                    Menu ListManagerGUI_CheckMenu
                        ,Enable
                        ,%s_CheckSelected_MenuItem%

                    Menu ListManagerGUI_CheckMenu
                        ,Enable
                        ,%s_UncheckSelected_MenuItem%
                    }
                 else
                    {
                    Menu ListManagerGUI_CheckMenu
                        ,Disable
                        ,%s_CheckSelected_MenuItem%

                    Menu ListManagerGUI_CheckMenu
                        ,Disable
                        ,%s_UncheckSelected_MenuItem%
                    }
                }
            }
        }

    return


    ;***************************
    ;*                         *
    ;*    Build Return List    *
    ;*     (ListManagerGUI)    *
    ;*                         *
    ;***************************
    ListManagerGUI_BuildReturnList:

    ;[==============]
    ;[  Initialize  ]
    ;[==============]
    l_ReturnList=

    ;[=======================]
    ;[  Edit/Checklist mode  ]
    ;[=======================]
    if p_Mode in Edit,Checklist
        {
        ;-- Initialize
        l_Index=0
        l_Status:=""

        ;-- AutoSort
        if o_AutoSort
            gosub ListManagerGUI_Sort


        ;-- AutoSortDesc
        if o_AutoSortDesc
            gosub ListManagerGUI_SortDesc

        ;-- Return entire list
        loop % LV_GetCount()
            {
            ;-- Get text
            LV_GetText(l_Text,A_Index,1)


            ;-- Define checked/selected status
            l_Status:=""
            if p_Mode=Checklist
                {
                if o_Checkboxes
                    {
                    ;-- Get checked status
                    SendMessage
                        ,LVM_GETITEMSTATE
                        ,A_Index-1
                        ,LVIS_STATEIMAGEMASK
                        ,%s_ListViewClassNN%
                        ,ahk_id %ListManagerGUI_hWnd%

                    l_Status:=(ErrorLevel>>12)-1
                        ;-- Set to TRUE if row is checked or FALSE if not
                    }
                 else
                    {
                    if LV_GetNext(A_Index-1)=A_Index
                        l_Status:=True
                     else
                        l_Status:=False
                    }
                }

            ;-- Add to the list
            l_Index++
            if l_Index=1
                l_ReturnList:=l_Status . l_Text
             else
                l_ReturnList:=l_ReturnList . p_Delimiter . l_Status . l_Text
            }
        }

    ;[===============]
    ;[  Select mode  ]
    ;[===============]
    if p_Mode=Select
        {
        ;-- Selection required?
        if o_SelectionRequired
            {
            if o_CheckBoxes
                {
                if LV_GetNext(0,"Checked")=0
                    return
                }
             else
                {
                if LV_GetCount("Selected")=0
                    return
                }
            }

        ;-- Initialize
        l_Row=0
        l_Index=0

        ;-- AutoSort
        if o_AutoSort
            {
            GUIControl Focus,%s_ListViewClassNN%
            gosub ListManagerGUI_Sort
            }

        ;-- AutoSortDesc
        if o_AutoSortDesc
            {
            GUIControl Focus,%s_ListViewClassNN%
            gosub ListManagerGUI_SortDesc
            }

        ;-- Return checked/selected items
        loop
            {
            ;-- Get next
            l_Row:=LV_GetNext(l_Row,o_CheckBoxes ? "Checked" : "")
            if l_Row=0
                break

            ;-- Get text
            LV_GetText(l_Text,l_Row,1)

            ;-- Add to the list
            l_Index++
            if o_ReturnListPos
                {
                if l_Index=1
                    l_ReturnList:=l_Row
                 else
                    l_ReturnList:=l_ReturnList . p_Delimiter . l_Row
                }
             else
                {
                if l_Index=1
                    l_ReturnList:=l_Text
                 else
                    l_ReturnList:=l_ReturnList . p_Delimiter . l_Text
                }

            ;-- Add to the unique list
            if o_NoDuplicates
                l_UniqueList:=l_UniqueList .  l_Text . p_Delimiter
            }
        }

    return


    ;**************************
    ;*                        *
    ;*      Return button     *
    ;*    (ListManagerGUI)    *
    ;*                        *
    ;**************************
    ListManagerGUI_ReturnButton:

    ;-- Set GUI default (Required for menu)
    gui %l_GUI%:Default

    ;-- Currently modifying?
    if l_ModifyFlag
        return

    ;[=====================]
    ;[  Build return list  ]
    ;[=====================]
    gosub ListManagerGUI_BuildReturnList

    ;-- Modify started?
    if l_ModifyFlag
        return

    ;[==================]
    ;[  OK, we're done  ]
    ;[   Shut it done   ]
    ;[==================]
    gosub ListManagerGUI_Exit
    return


    ;**************************
    ;*                        *
    ;*         Move up        *
    ;*    (ListManagerGUI)    *
    ;*                        *
    ;**************************
    ListManagerGUI_MoveUp:

    ;-- Set GUI default (Required for menu)
    gui %l_GUI%:Default

    ;-- Move allowed?
    if not o_Move
    or not o_Select
        return

    ;-- Currently modifying?
    if l_ModifyFlag
        return

    ;-- Set focus
    GUIControl Focus,%s_ListViewClassNN%

    ;-- Get select status of 1st item
    SendMessage
        ,LVM_GETITEMSTATE
        ,0
        ,LVIS_SELECTED
        ,%s_ListViewClassNN%
        ,ahk_id %ListManagerGUI_hWnd%

    ;-- Not already at the top? (First item not selected)
    if (ErrorLevel<>LVIS_SELECTED)
        {
        ;-- Redraw off
        GUIControl -Redraw,%s_ListViewClassNN%

        ;-- Move 'em
        l_Row=0
        loop
            {
            ;-- Get next selected
            l_Row:=LV_GetNext(l_Row)
            if l_Row=0
                break

            ;-- Move up by 1
            ListManagerGUI_SwapRow(l_Row,l_Row-1)
            }

        ;-- Make sure 1st selected is visable
        LV_Modify(LV_GetNext(0),"+Vis")


        ;-- Redraw on
        GUIControl +Redraw,%s_ListViewClassNN%
        }

    return


    ;**************************
    ;*                        *
    ;*        Move down       *
    ;*    (ListManagerGUI)    *
    ;*                        *
    ;**************************
    ListManagerGUI_MoveDown:

    ;-- Set GUI default (Required for menu)
    gui %l_GUI%:Default

    ;-- Move allowed?
    if not o_Move
    or not o_Select
        return

    ;-- Currently modifying?
    if l_ModifyFlag
        return

    ;-- Set focus
    GUIControl Focus,%s_ListViewClassNN%

    ;-- Not already at the bottom?
    if LV_GetNext(LV_GetCount()-1)<>LV_GetCount()
        {
        ;-- Redraw off
        GUIControl -Redraw,%s_ListViewClassNN%

        ;-- Create selected list
        l_SelectedList=
        l_Row=0
        l_LastSelectedRow:=""
        loop
            {
            l_Row:=LV_GetNext(l_Row)
            if l_Row=0
                break

            l_LastSelectedRow:=l_Row

            ;-- Store list in reverse (LIFO) order
            if l_SelectedList is Space
                l_SelectedList:=l_Row
             else
                l_SelectedList:=l_Row . "|" . l_SelectedList
            }

        ;-- Move 'em
        loop parse,l_SelectedList,|
            ListManagerGUI_SwapRow(A_LoopField,A_LoopField+1)


        ;-- Make sure last selected is visable
        LV_Modify(l_LastSelectedRow,"+Vis")


        ;-- Redraw on
        GUIControl +Redraw,%s_ListViewClassNN%
        }

    return


    ;**************************
    ;*                        *
    ;*         Insert         *
    ;*    (ListManagerGUI)    *
    ;*                        *
    ;**************************
    ListManagerGUI_Insert:

    ;-- Set GUI default (Required for menu)
    gui %l_GUI%:Default

    ;-- Insert allowed?
    if not o_Insert
    or not o_Modify
    or not o_Select
        return

    ;-- Currently modifying?
    if l_ModifyFlag
        return

    ;-- Set focus
    GUIControl Focus,%s_ListViewClassNN%

    ;-- Insert/Add new line
    if LV_GetCount("Selected")
        {
        ;-- Insert in place
        l_Row:=LV_GetNext(0)
        LV_Insert(l_Row,"","-- New --")
        LV_Modify(0,"-Select")                  ;-- Unselect all
        LV_Modify(l_Row,"+Select +Focus +Vis")  ;-- Select new
        }
     else
        ;-- Add to the end
        LV_Add("+Select +Focus +Vis","-- New --")

    ;-- Modify new record
    l_InsertFlag:=True
    gosub ListManagerGUI_Modify
    return


    ;**************************
    ;*                        *
    ;*         Modify         *
    ;*    (ListManagerGUI)    *
    ;*                        *
    ;**************************
    ListManagerGUI_Modify:

    ;-- Modify allowed?
    if not o_Modify
    or not o_Select
        return

    ;-- Already modifying a list item?
    if l_ModifyFlag
        return

    ;-- Set GUI default (Required for menu)
    gui %l_GUI%:Default

    ;-- Any list item focused?
    l_ModifyRow:=LV_GetNext(0,"Focused")
    if not l_ModifyRow
        return

    ;-- Temporarily turn off resizing
    if InStr(p_GUIOptions,"+Resize")
        gui +MinSize

    ;-- Set focus
    GUIControl Focus,%s_ListViewClassNN%

    ;-- Initialize
    l_ModifyFlag:=True

    ;-------------------
    ;-- Disable buttons
    ;-------------------
    ;-- Return button
    if StrLen(o_ReturnButton)
        GUIControl Disable,%s_ReturnButtonClassNN%

    ;-- Cancel button
    if o_CancelButton
        GUIControl Disable,%s_CancelButtonClassNN%

    ;-- Edit buttons
    if o_EditButtons
        {
        if o_Move and o_Select
            {
            GUIControl Disable,%s_MoveUpButtonClassNN%
            GUIControl Disable,%s_MoveDownButtonClassNN%
            }

        if o_Insert and o_Modify and o_Select
            GUIControl Disable,%s_InsertButtonClassNN%

        if o_Modify and o_Select
            GUIControl Disable,%s_ModifyButtonClassNN%

        if o_Copy and o_Delete and o_Select
            GUIControl Disable,%s_CutButtonClassNN%

        if o_Copy and o_Select
            GUIControl Disable,%s_CopyButtonClassNN%

        if o_Paste and o_Select
            GUIControl Disable,%s_PasteButtonClassNN%

        if o_Delete and o_Select
            GUIControl Disable,%s_DeleteButtonClassNN%
        }

    ;----------------------
    ;-- Disable menu items
    ;----------------------
    if o_Menu  ;-- Note: Regular context menu is not avail during modify
        {
        if l_FileMenu
            Menu ListManagerGUI_MenuBar
                ,Disable
                ,%s_FileMenu_MenuItem%

        if l_EditMenu
            Menu ListManagerGUI_MenuBar
                ,Disable
                ,%s_EditMenu_MenuItem%

        if l_CheckMenu
            Menu ListManagerGUI_MenuBar
                ,Disable
                ,%s_CheckMenu_MenuItem%

        if l_SortMenu
            Menu ListManagerGUI_MenuBar
                ,Disable
                ,%s_SortMenu_MenuItem%
        }

    ;----------------
    ;-- Modify setup
    ;----------------

    ;-- Make sure focused row is visable
    LV_Modify(l_ModifyRow,"+Vis")

    ;-- Get text, Update Edit Control
    LV_GetText(l_ModifyOriginalText,l_ModifyRow)
    GUIControl,,%s_EditClassNN%,%l_ModifyOriginalText%

    ;-- Create/Initialize l_RECT
    VarSetCapacity(l_RECT,16,0)
    NumPut(LVIR_LABEL,l_RECT,0)
    NumPut(0,         l_RECT,4)  ;-- Subitem index (only one column???          ############)

    ;-- Get cell coordinates
    SendMessage
        ,LVM_GETSUBITEMRECT
        ,l_ModifyRow-1
        ,&l_RECT
        ,%s_ListViewClassNN%
        ,ahk_id %ListManagerGUI_hWnd%

    ;-------------------------------------------------------
    ;
    ;   Coordinates stored in l_RECT are as follows:
    ;
    ;   Name    Description                         Location
    ;   ----    -----------                         ---------
    ;   Left    x-coordinate of upper-left corner   NumGet(l_RECT,0,4)
    ;   Top     y-coordinate of upper-left corner   NumGet(l_RECT,4,4)
    ;   Right   x-coordinate of lower-right corner  NumGet(l_RECT,8,4)
    ;   Bottom  y-coordinate of lower-right corner  NumGet(l_RECT,12,4)
    ;
    ;
    ;   Additional calculations
    ;   -----------------------
    ;   Width = Right - Left
    ;   Height = Bottom - Top
    ;

    ;-- Disable ListView
    GUIControl Disable,%s_ListViewClassNN%

    ;-- Move/Size Edit control
    GUIControl
        ,Move
        ,%s_EditClassNN%
        ,% " x" .  NumGet(l_RECT,0,4)+l_ListViewXPos+1
         . " y" .  NumGet(l_RECT,4,4)+l_ListViewYPos+1
         . " w" . (NumGet(l_RECT,8,4)+l_ListViewXPos)-(NumGet(l_RECT,0,4)+l_ListViewXPos)  ;+1
         . " h" . (NumGet(l_RECT,12,4)+l_ListViewYPos)-(NumGet(l_RECT, 4,4)+l_ListViewYPos)+3

    ;-- Reset control
    Attach(ListManagerGUI_hWnd)

    ;-- Select All (Edit control)
    SendMessage
        ,EM_SETSEL
        ,0                ;-- Start (Set to 0 for "Select All")
        ,-1               ;-- End   (Set to -1 for "Select All")
        ,
        ,ahk_id %ListManagerGUI_Edit_hWnd%

    ;-- Show/Focus Edit control
    GUIControl Show,%s_EditClassNN%
    GUIControl Focus,%s_EditClassNN%
    return


    ;**************************
    ;*                        *
    ;*       Modify Stop      *
    ;*    (ListManagerGUI)    *
    ;*                        *
    ;**************************
    ListManagerGUI_ModifyStop:

;;;;;    ;-- Set GUI default (Required for menu and timer threads)
;;;;;    gui %l_GUI%:Default

    ;-- Collect text
    GUIControlGet l_Text,,%s_EditClassNN%
    l_OriginalText:=l_Text  ;-- Save for Edit control comparison


     if not l_EscapeFlag
    and not l_CloseFlag
        {
        ;-------------------
        ;-- Auto conversion
        ;-------------------
        StringReplace l_Text,l_Text,%p_Delimiter%,,All

        if o_AutoDeleteSpace
            {
            StringReplace l_Text,l_Text,%A_Space%,,All
            StringReplace l_Text,l_Text,%A_Tab%,,All
            StringReplace l_Text,l_Text,`n,,All
            StringReplace l_Text,l_Text,`r,,All
            StringReplace l_Text,l_Text,`v,,All
            StringReplace l_Text,l_Text,`f,,All
            }

        if o_AutoLower
            StringLower l_Text,l_Text

        if o_AutoTrim
            {
            l_Text=%l_Text%
            l_Text:=RegExReplace(l_Text,"^[ \t\r\n\v\f]+","")  ;-- Leading
            l_Text:=RegExReplace(l_Text,"[ \t\r\n\v\f]+$","")  ;-- Trailing
            }

        if o_AutoUpper
            StringUpper l_Text,l_Text

        if o_AutoUpperT
            StringUpper l_Text,l_Text,T

        if StrLen(o_AutoDeleteChars)
            loop parse,o_AutoDeleteChars
                StringReplace l_Text,l_Text,%A_LoopField%,,All
            ;--
            ;   Note: Since the AutoDeleteChars option may include case
            ;   sensitive comparisons, it must be performed after all other
            ;   "Auto{xxx}" options.

        ;-- Blank?
        if o_NoBlank
            if l_Text is Space
                {
                ;-- Update Edit control if changed
                if (not l_Text==l_OriginalText)
                    GUIControl,,%s_EditClassNN%,%l_Text%

                ;-- Error message
                gui +OwnDialogs
                MsgBox
                    ,16
                    ,Invalid Data
                    ,Item cannot be blank.  %A_Space%

                ;-- Resume Modify
                return
                }

        ;-- Check data integrity
        if o_DataType
            if l_Text is not %o_DataType%
                {
                ;-- Update Edit control if changed
                if (not l_Text==l_OriginalText)
                    GUIControl,,%s_EditClassNN%,%l_Text%

                ;-- Error message
                gui +OwnDialogs
                MsgBox,16,Invalid Data,
                   (ltrim join`s
                    Item must contain "%o_DataType%" type data only.  Please
                    modify.  %A_Space%
                   )

                ;-- Select All (Edit control)
                SendMessage
                    ,EM_SETSEL
                    ,0                ;-- Start (Set to 0 for "Select All")
                    ,-1               ;-- End   (Set to -1 for "Select All")
                    ,%s_EditClassNN%
                    ,ahk_id %ListManagerGUI_hWnd%

                ;-- Resume Modify
                return
                }

        ;-- Duplicate
        if o_NoDuplicates
            {
            ;-- Search for duplicates
            l_DuplicateFound:=False
            loop % LV_GetCount()
                {
                ;-- Skip the current row
                if (A_Index=l_ModifyRow)
                    continue

                ;-- Get text
                LV_GetText(l_DupCandidate,A_Index,1)

                ;-- Match?
                if (l_Text<>l_DupCandidate)
                    continue
                    ;-- Note: The "<>" operator is used to test for duplicates
                    ;   because it obeys StringCaseSense whereas the "="
                    ;   operator does not.

                l_DuplicateFound:=True
                break
                }

            ;-- Duplicate found?
            if l_DuplicateFound
                {
                ;-- Update Edit control if changed
                if (not l_Text==l_OriginalText)
                    GUIControl,,%s_EditClassNN%,%l_Text%

                ;-- Error message
                gui +OwnDialogs
                MsgBox
                    ,16
                    ,Invalid Data
                    ,Duplicate item.  %A_Space%

                ;-- Select All (Edit control)
                SendMessage
                    ,EM_SETSEL
                    ,0                ;-- Start (Set to 0 for "Select All")
                    ,-1               ;-- End   (Set to -1 for "Select All")
                    ,%s_EditClassNN%
                    ,ahk_id %ListManagerGUI_hWnd%

                ;-- Resume Modify
                return
                }
            }

        ;-- Update row if changed
        if (not l_Text==l_ModifyOriginalText)
            LV_Modify(l_ModifyRow,"",l_Text)
        }

    ;---------------
    ;-- Cancel new?
    ;---------------
    if l_InsertFlag and (l_CloseFlag or l_EscapeFlag)
        {
        ;-- Delete new row
        LV_Delete(l_ModifyRow)

        ;-- Select if anything is in focus
        if LV_GetNext(0,"Focused")
            LV_Modify(LV_GetNext(0,"Focused"),"Select")
        }

    ;------------------
    ;-- Enable buttons
    ;------------------
    ;-- Return button
    if StrLen(o_ReturnButton)
        GUIControl Enable,%s_ReturnButtonClassNN%

    ;-- Cacnel button
    if o_CancelButton
        GUIControl Enable,%s_CancelButtonClassNN%

    ;-- Edit buttons
    if o_EditButtons
        {
        if o_Move and o_Select
            {
            GUIControl Enable,%s_MoveUpButtonClassNN%
            GUIControl Enable,%s_MoveDownButtonClassNN%
            }

        if o_Insert and o_Modify and o_Select
            GUIControl Enable,%s_InsertButtonClassNN%

        if o_Modify and o_Select
            GUIControl Enable,%s_ModifyButtonClassNN%

        if o_Copy and o_Delete and o_Select
            GUIControl Enable,%s_CutButtonClassNN%

        if o_Copy and o_Select
            GUIControl Enable,%s_CopyButtonClassNN%

        if o_Paste and o_Select
            GUIControl Enable,%s_PasteButtonClassNN%

        if o_Delete and o_Select
            GUIControl Enable,%s_DeleteButtonClassNN%
        }

    ;---------------------
    ;-- Enable menu items
    ;---------------------
    if o_Menu  ;-- Note: Application context menu is not available during modify
        {
        if l_FileMenu
            Menu ListManagerGUI_MenuBar
                ,Enable
                ,%s_FileMenu_MenuItem%

        if l_EditMenu
            Menu ListManagerGUI_MenuBar
                ,Enable
                ,%s_EditMenu_MenuItem%

        if l_CheckMenu
            Menu ListManagerGUI_MenuBar
                ,Enable
                ,%s_CheckMenu_MenuItem%

        if l_SortMenu
            Menu ListManagerGUI_MenuBar
                ,Enable
                ,%s_SortMenu_MenuItem%
        }

    ;---------------------
    ;-- Hide Edit control
    ;---------------------
    GUIControl Hide,%s_EditClassNN%

    ;--------------------
    ;-- Restore resizing
    ;--------------------
    if InStr(p_GUIOptions,"+Resize")
        gui +MinSize%l_MinSizeW%x%l_MinSizeH%

    ;-------------------------
    ;-- Enable/Focus ListView
    ;-------------------------
    GUIControl Enable,%s_ListViewClassNN%
    GUIControl Focus,%s_ListViewClassNN%


    ;------------------------------
    ;-- Update ContinueInsert flag
    ;------------------------------
    l_ContinueInsertFlag:=False
    if l_InsertFlag and not (l_EscapeFlag or l_CloseFlag)
        l_ContinueInsertFlag:=True

    ;----------------
    ;-- Housekeeping
    ;----------------
    l_InsertFlag:=False
    l_ModifyFlag:=False
    l_EscapeFlag:=False

    ;-----------------------
    ;-- Continue to insert?
    ;-----------------------
    if l_ContinueInsertFlag
        {
        ;-- Identify currently selected row
        l_Row:=LV_GetNext(0)

        ;-- Unselect current row
        LV_Modify(l_Row,"-Select")
            ;-- If at the end of the list, this unselect forces the next record
            ;   to be added to the end of the list.

        ;-- Not at the end of the list?
        if l_Row<>LV_GetCount()
            {
            ;-- Select next row
            LV_Modify(l_Row+1,"+Select")
                ;-- This select forces the new record to be inserted immediately
                ;   after the record that was just inserted.
            }

        ;-- Insert new
        gosub ListManagerGUI_Insert
        }

    return


    ;**************************
    ;*                        *
    ;*         Delete         *
    ;*    (ListManagerGUI)    *
    ;*                        *
    ;**************************
    ListManagerGUI_Delete:

    ;-- Set GUI default (Required for menu)
    gui %l_GUI%:Default

    ;-- Delete allowed?
    if not o_Delete
    or not o_Select
        return

    ;-- Currently modifying?
    if l_ModifyFlag
        return

    ;-- Anything selected?
    if LV_GetCount("Selected")=0
        return

    ;-- Set focus
    GUIControl Focus,%s_ListViewClassNN%

    ;-- Confirm?
    if o_ConfirmDelete
        {
        gui +OwnDialogs
        MsgBox
            ,49
            ,Confirm Delete
            ,All selected items will be deleted.  Press OK to proceed.  %A_Space%

        IfMsgBox Cancel
            return
        }

    ;-- Delete 'em
    gosub ListManagerGUI_DeleteSelected

    ;-- Return to sender
    return


    ;**************************
    ;*                        *
    ;*     Delete selected    *
    ;*    (ListManagerGUI)    *
    ;*                        *
    ;**************************
    ;
    ;   Note: Some of the code in this section may appear to be redundant but
    ;   it's necessary because this routine is called by more than one routine.
    ;
    ListManagerGUI_DeleteSelected:

    ;-- Set GUI default (Required for menu)
    gui %l_GUI%:Default

    ;-- Delete allowed?
    if not o_Delete
    or not o_Select
        return

    ;-- Currently modifying?
    if l_ModifyFlag
        return

    ;-- Set focus
    GUIControl Focus,%s_ListViewClassNN%

    ;-- Disable GUI
    gui %l_GUI%:+Disabled

    ;-- Redraw off
    GUIControl -Redraw,%s_ListViewClassNN%

    ;-- Delete row(s) from list
    loop
        {
        l_Row:=LV_GetNext(0)  ;-- Always restart at the top
        if not l_Row
            break

        ;-- Delete row from ListView
        LV_Delete(l_Row)
        }

    ;-- Select if anything is in focus
    if LV_GetNext(0,"Focused")
        LV_Modify(LV_GetNext(0,"Focused"),"Select")

    ;-- Redraw on
    GUIControl +Redraw,%s_ListViewClassNN%

    ;-- Enable GUI
    gui %l_GUI%:-Disabled
    return


    ;**************************
    ;*                        *
    ;*        Uppercase       *
    ;*    (ListManagerGUI)    *
    ;*                        *
    ;**************************
    ListManagerGUI_Uppercase:

    ;-- Set GUI default (Required for menu)
    gui %l_GUI%:Default

    ;-- Uppercase allowed?
    if not o_Format
        return

    ;-- Currently modifying?
    if l_ModifyFlag
        return

    ;-- List control in focus?
    GUIControlGet l_Control,Focus
    if (l_Control<>s_ListViewClassNN)
        return

    ;-- Disable GUI
    gui %l_GUI%:+Disabled

    ;-- Redraw off
    GUIControl -Redraw,%s_ListViewClassNN%

    ;-- Convert all selected rows (if any)
    l_Row:=LV_GetNext(0)
    loop
        {
        ;-- Are we done yet?
        if l_Row=0
            break

        ;-- Collect text
        LV_GetText(l_OriginalText,l_Row,1)

        ;-- Convert to uppercase
        StringUpper l_ConvertedText,l_OriginalText

        ;-- Update row if changed
        if (not l_OriginalText==l_ConvertedText)
            LV_Modify(l_Row,"",l_ConvertedText)

        ;-- Get next selected row
        l_Row:=LV_GetNext(l_Row)
        }

    ;-- Redraw on
    GUIControl +Redraw,%s_ListViewClassNN%

    ;-- Enable GUI
    gui %l_GUI%:-Disabled
    return


    ;**************************
    ;*                        *
    ;*        Lowercase       *
    ;*    (ListManagerGUI)    *
    ;*                        *
    ;**************************
    ListManagerGUI_Lowercase:

    ;-- Set GUI default (Required for menu)
    gui %l_GUI%:Default

    ;-- Lowercase allowed?
    if not o_Format
        return

    ;-- Currently modifying?
    if l_ModifyFlag
        return

    ;-- List control in focus?
    GUIControlGet l_Control,Focus
    if (l_Control<>s_ListViewClassNN)
        return

    ;-- Disable GUI
    gui %l_GUI%:+Disabled

    ;-- Redraw off
    GUIControl -Redraw,%s_ListViewClassNN%

    ;-- Convert all selected rows (if any)
    l_Row:=LV_GetNext(0)
    loop
        {
        ;-- Are we done yet?
        if l_Row=0
            break

        ;-- Collect text
        LV_GetText(l_OriginalText,l_Row,1)

        ;-- Convert to uppercase
        StringLower l_ConvertedText,l_OriginalText

        ;-- Update row if changed
        if (not l_OriginalText==l_ConvertedText)
            LV_Modify(l_Row,"",l_ConvertedText)

        ;-- Get next selected row
        l_Row:=LV_GetNext(l_Row)
        }

    ;-- Redraw on
    GUIControl +Redraw,%s_ListViewClassNN%

    ;-- Enable GUI
    gui %l_GUI%:-Disabled
    return


    ;**************************
    ;*                        *
    ;*       Capitalize       *
    ;*    (ListManagerGUI)    *
    ;*                        *
    ;**************************
    ListManagerGUI_Capitalize:

    ;-- Set GUI default (Required for menu)
    gui %l_GUI%:Default

    ;-- Uppercase allowed?
    if not o_Format
        return

    ;-- Currently modifying?
    if l_ModifyFlag
        return

    ;-- List control in focus?
    GUIControlGet l_Control,Focus
    if (l_Control<>s_ListViewClassNN)
        return

    ;-- Disable GUI
    gui %l_GUI%:+Disabled

    ;-- Redraw off
    GUIControl -Redraw,%s_ListViewClassNN%

    ;-- Convert all selected rows (if any)
    l_Row:=LV_GetNext(0)
    loop
        {
        ;-- Are we done yet?
        if l_Row=0
            break

        ;-- Collect text
        LV_GetText(l_OriginalText,l_Row,1)

        ;-- Convert to uppercase
        StringUpper l_ConvertedText,l_OriginalText,T

        ;-- Update row if changed
        if (not l_OriginalText==l_ConvertedText)
            LV_Modify(l_Row,"",l_ConvertedText)

        ;-- Get next selected row
        l_Row:=LV_GetNext(l_Row)
        }

    ;-- Redraw on
    GUIControl +Redraw,%s_ListViewClassNN%

    ;-- Enable GUI
    gui %l_GUI%:-Disabled
    return


    ;**************************
    ;*                        *
    ;*        Check all       *
    ;*    (ListManagerGUI)    *
    ;*                        *
    ;**************************
    ListManagerGUI_CheckAll:

    ;-- Set GUI default (Required for menu)
    gui %l_GUI%:Default

    ;-- Checkboxes enabled?
    if not o_Checkboxes
        return

    ;-- Currently modifying?
    if l_ModifyFlag
        return

    ;-- Set focus
    GUIControl Focus,%s_ListViewClassNN%

    ;-- Check all
    LV_Modify(0,"+Check")
    return


    ;**************************
    ;*                        *
    ;*       Uncheck all      *
    ;*    (ListManagerGUI)    *
    ;*                        *
    ;**************************
    ListManagerGUI_UncheckAll:

    ;-- Set GUI default (Required for menu)
    gui %l_GUI%:Default

    ;-- Checkboxes enabled?
    if not o_Checkboxes
        return

    ;-- Currently modifying?
    if l_ModifyFlag
        return

    ;-- Set focus
    GUIControl Focus,%s_ListViewClassNN%

    ;-- Uncheck all
    LV_Modify(0,"-Check")
    return


    ;**************************
    ;*                        *
    ;*        Enter key       *
    ;*    (ListManagerGUI)    *
    ;*                        *
    ;**************************
    ListManagerGUI_EnterKey:

    ;-- Currently modifying?
    if l_ModifyFlag
        gosub ListManagerGUI_ModifyStop
     else
        gosub ListManagerGUI_CheckSelected

    return


    ;**************************
    ;*                        *
    ;*     Check selected     *
    ;*    (ListManagerGUI)    *
    ;*                        *
    ;**************************
    ListManagerGUI_CheckSelected:

    ;-- Set GUI default (Required for menu)
    gui %l_GUI%:Default

    ;-- Checkboxes enabled?
    if not o_Checkboxes
        return

    ;-- Currently modifying?
    if l_ModifyFlag
        return

    ;-- Set focus
    GUIControl Focus,%s_ListViewClassNN%

    ;-- Check 'em
    l_Row=0
    loop
        {
        l_Row:=LV_GetNext(l_Row)
        if l_Row=0
            break

        LV_Modify(l_Row,"+Check")
        }

    return


    ;**************************
    ;*                        *
    ;*    Uncheck selected    *
    ;*    (ListManagerGUI)    *
    ;*                        *
    ;**************************
    ListManagerGUI_UncheckSelected:

    ;-- Set GUI default (Required for menu)
    gui %l_GUI%:Default

    ;-- Checkboxes enabled?
    if not o_Checkboxes
        return

    ;-- Currently modifying?
    if l_ModifyFlag
        return

    ;-- Set focus
    GUIControl Focus,%s_ListViewClassNN%

    ;-- Uncheck 'em
    l_Row=0
    loop
        {
        l_Row:=LV_GetNext(l_Row)
        if l_Row=0
            break

        LV_Modify(l_Row,"-Check")
        }

    return


    ;**************************
    ;*                        *
    ;*       Select all       *
    ;*    (ListManagerGUI)    *
    ;*                        *
    ;**************************
    ListManagerGUI_SelectAll:

    ;-- Set GUI default (Required for menu)
    gui %l_GUI%:Default

    ;-- SelectMulti enabled?
     if not o_Select
    and not o_SelectMulti
        return

    ;-- Currently modifying?
    if l_ModifyFlag
        return

    ;-- Set focus
    GUIControl Focus,%s_ListViewClassNN%

    ;-- Select all
    LV_Modify(0,"+Select")
    return


    ;**************************
    ;*                        *
    ;*      Unselect all      *
    ;*    (ListManagerGUI)    *
    ;*                        *
    ;**************************
    ListManagerGUI_UnselectAll:

    ;-- Set GUI default (Required for menu)
    gui %l_GUI%:Default

    ;-- SelectMulti enabled?
     if not o_Select
    and not o_SelectMulti
        return

    ;-- Currently modifyng a list item?
    if l_ModifyFlag
        return

    ;-- Anything selected?
    if LV_GetCount("Selected")=0
        return

    ;-- Set focus
    GUIControl Focus,%s_ListViewClassNN%

    ;-- Unselect all
    LV_Modify(0,"-Select")
    return


    ;**************************
    ;*                        *
    ;*           Cut          *
    ;*    (ListManagerGUI)    *
    ;*                        *
    ;**************************
    ListManagerGUI_Cut:

    ;-- Set GUI default (Required for menu)
    gui %l_GUI%:Default

    ;-- Copy AND Delete allowed?
    if not o_Copy
    or not o_Delete
    or not o_Select
        return

    ;-- Currently modifying?
    if l_ModifyFlag
        return

    ;-- Anything selected?
    if LV_GetCount("Selected")=0
        return

    ;-- Set focus
    GUIControl Focus,%s_ListViewClassNN%

    ;-- Confirm?
    if o_ConfirmDelete
        {
        gui +OwnDialogs
        MsgBox,49,Confirm Cut,
           (ltrim join`s
            This operation will copy all selected items to the clipboard   `nand
            then delete the items from the list.   `n`nPress OK to
            proceed.  %A_Space%
           )

        IfMsgBox Cancel
            return
        }

    ;-- Copy then Delete.  Note: All other checks are done in these routines.
    gosub ListManagerGUI_CopySelected
    gosub ListManagerGUI_DeleteSelected
    return


    ;**************************
    ;*                        *
    ;*      Copy selected     *
    ;*    (ListManagerGUI)    *
    ;*                        *
    ;**************************
    ListManagerGUI_CopySelected:

    ;-- Set GUI default (Required for menu)
    gui %l_GUI%:Default

    ;-- Copy allowed?
    if not o_Copy
    or not o_Select
        return

    ;-- Currently modifying?
    if l_ModifyFlag
        return

    ;-- Set focus
    GUIControl Focus,%s_ListViewClassNN%

    ;-- Copy to clipboard
    l_Clipboard:=""
    l_Row=0
    loop
        {
        l_Row:=LV_GetNext(l_Row)
        if l_Row=0
            break

        LV_GetText(l_Text,l_Row,1)
        l_Clipboard:=l_Clipboard . l_Text . "`r`n"
        }

    ;-- Update Clipboard?  Blank lines are OK but don't update if null
    if StrLen(l_Clipboard)
        Clipboard:=l_Clipboard

    return


    ;**************************
    ;*                        *
    ;*      Copy checked      *
    ;*    (ListManagerGUI)    *
    ;*                        *
    ;**************************
    ListManagerGUI_CopyChecked:

    ;-- Set GUI default (Required for menu)
    gui %l_GUI%:Default

    ;-- Copy allowed?
    if not o_Copy
        return

    ;-- Currently modifying?
    if l_ModifyFlag
        return

    ;-- Set focus
    GUIControl Focus,%s_ListViewClassNN%

    ;-- Copy to clipboard
    l_Clipboard:=""
    l_Row=0
    loop
        {
        l_Row:=LV_GetNext(l_Row,"Checked")
        if l_Row=0
            break

        LV_GetText(l_Text,l_Row,1)
        l_Clipboard:=l_Clipboard . l_Text . "`r`n"
        }

    ;-- Update clipboard?  Blank lines are OK but don't update if null
    if StrLen(l_Clipboard)
        Clipboard:=l_Clipboard

    return


    ;**************************
    ;*                        *
    ;*          Paste         *
    ;*    (ListManagerGUI)    *
    ;*                        *
    ;**************************
    ListManagerGUI_Paste:

    ;-- Set GUI default (Required for menu)
    gui %l_GUI%:Default

    ;-- Paste allowed?
    if not o_Paste
    or not o_Select
        return

    ;-- Currently modifying?
    if l_ModifyFlag
        return

    ;-- Set focus
    GUIControl Focus,%s_ListViewClassNN%


    ;[============]
    ;[  Paste it  ]
    ;[============]

    ;-- Disable GUI
    gui %l_GUI%:+Disabled

    ;-- Initialize
    l_Clipboard:=Clipboard
    l_DroppedRecord:=False
    l_Add:=False

    ;-- Truncate final CRLF if necessary
    if StrLen(l_Clipboard)>2
        if SubStr(l_Clipboard,-1)="`r`n"
            StringTrimRight l_Clipboard,l_Clipboard,2


    ;-- Initialize unique list
    if o_NoDuplicates
        {
        l_UniqueList:=p_Delimiter
        loop % LV_GetCount()
            {
            LV_GetText(l_Text,A_Index,1)
            l_UniqueList:=l_UniqueList .  l_Text . p_Delimiter
            }
        }

    ;-- Find starting point (if any)
    l_Row:=LV_GetNext(0)
    if l_Row=0
        l_Add:=True

    ;-- Load it up
    loop parse,l_Clipboard,`n,`r
        {
        ;-- Get item
        l_Text:=A_LoopField

        ;-- Auto conversion
        StringReplace l_Text,l_Text,%p_Delimiter%,,All

        if o_AutoDeleteSpace
            {
            StringReplace l_Text,l_Text,%A_Space%,,All
            StringReplace l_Text,l_Text,%A_Tab%,,All
            StringReplace l_Text,l_Text,`n,,All
            StringReplace l_Text,l_Text,`r,,All
            StringReplace l_Text,l_Text,`v,,All
            StringReplace l_Text,l_Text,`f,,All
            }

        if o_AutoLower
            StringLower l_Text,l_Text

        if o_AutoTrim
            {
            l_Text=%l_Text%
            l_Text:=RegExReplace(l_Text,"^[ \t\r\n\v\f]+","")  ;-- Leading
            l_Text:=RegExReplace(l_Text,"[ \t\r\n\v\f]+$","")  ;-- Trailing
            }

        if o_AutoUpper
            StringUpper l_Text,l_Text

        if o_AutoUpperT
            StringUpper l_Text,l_Text,T

        if StrLen(o_AutoDeleteChars)
            loop parse,o_AutoDeleteChars
                StringReplace l_Text,l_Text,%A_LoopField%,,All
            ;--
            ;   Note: Since the AutoDeleteChars option may include case
            ;   sensitive comparisons, it must be performed after all other
            ;   "Auto{xxx}" options.

        ;-- Drop blank
        if o_NoBlank
            if l_Text is Space
                {
                ;-- Note: Don't complain about dropped blank lines.
                continue
                }

        ;-- Drop duplicates
        if o_NoDuplicates
            if InStr(l_UniqueList,p_Delimiter . l_Text . p_Delimiter,o_CaseSensitive,1)
                {
                l_DroppedRecord:=True
                continue
                }

        ;-- Drop invalid type
        if o_DataType
            if l_Text is not %o_DataType%
                {
                l_DroppedRecord:=True
                continue
                }

        ;-- Insert/Add it!
        if l_Row
            {
            LV_Insert(l_Row,"",l_Text)
            l_Row++
            }
         else
            LV_Add("+Select",l_Text)


        ;-- Add to the unique list
        if o_NoDuplicates
            l_UniqueList:=l_UniqueList .  l_Text . p_Delimiter
        }

    ;-- If Add, update focus and visability
    if l_Add
        LV_Modify(LV_GetCount(),"+Focus +Vis")

    ;-- Anything dropped?
    if l_DroppedRecord
        SoundPlay *16  ;-- Hand (Stop/Error)

    ;-- Housekeeping
    l_UniqueList:=""

    ;-- Enable GUI
    gui %l_GUI%:-Disabled
    return


    ;**************************
    ;*                        *
    ;*          Sort          *
    ;*    (ListManagerGUI)    *
    ;*                        *
    ;**************************
    ListManagerGUI_Sort:

    ;-- Set GUI default (Required for menu)
    gui %l_GUI%:Default

    ;-- Sort allowed?
    if not o_Sort
        return

    ;-- Currently modifying?
    if l_ModifyFlag
        return

    ;-- Set focus
    GUIControl Focus,%s_ListViewClassNN%

    ;-- Sort it
    LV_ModifyCol(1,"Sort")

    ;-- Update attributes
    gosub ListManagerGUI_UpdateAttributes
    return


    ;**************************
    ;*                        *
    ;*     Sort descending    *
    ;*    (ListManagerGUI)    *
    ;*                        *
    ;**************************
    ListManagerGUI_SortDesc:

    ;-- Set GUI default (Required for menu)
    gui %l_GUI%:Default

    ;-- Sort allowed?
    if not o_Sort
        return

    ;-- Currently modifying?
    if l_ModifyFlag
        return

    ;-- Set focus
    GUIControl Focus,%s_ListViewClassNN%

    ;-- Sort it
    LV_ModifyCol(1,"SortDesc")

    ;-- Update attributes
    gosub ListManagerGUI_UpdateAttributes
    return


    ;***********************
    ;*                     *
    ;*    Close up shop    *
    ;*                     *
    ;***********************
    ;[==========]
    ;[  Escape  ]
    ;[==========]
    ListManagerGUI_Escape:

    ;-- Currently modifying?
    if l_ModifyFlag
        {
        l_EscapeFlag:=True
        gosub ListManagerGUI_ModifyStop
        return
        }

    ;-- EscapeToClose enabled?
    if not o_EscapeToClose
        return

    ;[=========]
    ;[  Close  ]
    ;[=========]
    ListManagerGUI_Close:

    ;-- Close enabled?
    if not o_Close
        return

    ;-- Confirm close?
    if o_ConfirmClose
        {
        ;-- Currently modifying?
        if l_ModifyFlag
            {
            l_CloseFlag:=True
            gosub ListManagerGUI_ModifyStop
            l_CloseFlag:=False
            }

        ;-- Edit/Checklist mode?
        if p_Mode in Edit,Checklist
            {
            ;-- Build return list to compare
            gosub ListManagerGUI_BuildReturnList


            ;-- Any changes?
            if not (l_SaveList==l_ReturnList)
                {
                ;-- Ask the user to confirm
                gui +OwnDialogs
                MsgBox 35,Confirmation,Save changes?

                IfMsgBox Yes
                    {
                    gosub ListManagerGUI_ReturnButton
                    return
                    }

                IfMsgBox Cancel
                    return
                }
            }
        }


    ;**************************
    ;*                        *
    ;*      Cancel Button     *
    ;*    (ListManagerGUI)    *
    ;*                        *
    ;**************************
    ListManagerGUI_CancelButton:
    l_ReturnList=
    l_ErrorLevel=1


    ;**************************
    ;*                        *
    ;*          Exit          *
    ;*    (ListManagerGUI)    *
    ;*                        *
    ;**************************
    ListManagerGUI_Exit:

    ;-- Enable the Owner window
    if p_Owner
        gui %p_Owner%:-Disabled


    ;-- Destroy the ListManagerGUI window so that the window can be reused
    gui %l_GUI%:destroy

    return
        ;-- End of ListManagerGUI subroutines
        ;-- End of ListManagerGUI function
    }


;**********************************
;*                                *
;*                                *
;*            Functions           *
;*        (ListManagerGUI)        *
;*                                *
;*                                *
;**********************************
;--------------------
;;;;;; Function: DisableCloseButton
;;;;;; Author: Skan
;;;;;; Source: http://www.autohotkey.com/forum/viewtopic.php?p=62506#62506
;;;;;;
;;;;;;
;;;;;; Synopsis
;;;;;; --------
;;;;;; This function is used disable the Close button on the title bar and remove
;;;;;; the "Close" menu item from SysMenu.
;;;;;;
;;;;;; Important: This function does not disable the ALT+F4 option.  The user can
;;;;;; use ALT+F4 to close the window/hide the window unless additional restrictions
;;;;;; have been employed.
;;;;;;
;;;;;;-------------------------------------------------------------------------------
;;;;;DisableCloseButton(hWnd="") {
;;;;; If hWnd=
;;;;;    hWnd:=WinExist("A")
;;;;; hSysMenu:=DllCall("GetSystemMenu","Int",hWnd,"Int",FALSE)
;;;;; nCnt:=DllCall("GetMenuItemCount","Int",hSysMenu)
;;;;; DllCall("RemoveMenu","Int",hSysMenu,"UInt",nCnt-1,"Uint","0x400")
;;;;; DllCall("RemoveMenu","Int",hSysMenu,"UInt",nCnt-2,"Uint","0x400")
;;;;; DllCall("DrawMenuBar","Int",hWnd)
;;;;;Return ""
;;;;;}


;******************
;*                *
;*    Swap Row    *
;*                *
;******************
ListManagerGUI_SwapRow(p_SourceRow,p_TargetRow,p_Focus=True)
    {
    ;-- Note: Set p_Focus to FALSE if focus is automatically moved by a hotkey
    ;   or other method.

    ;-- Get Select
    if LV_GetNext(p_SourceRow-1)=p_SourceRow
        l_SourceOptions:="+Select"
     else
        l_SourceOptions:="-Select"

    if LV_GetNext(p_TargetRow-1)=p_TargetRow
        l_TargetOptions:="+Select"
     else
        l_TargetOptions:="-Select"

    ;-- Get Focus
    if p_Focus
	    {
	    if LV_GetNext(p_SourceRow-1,"Focused")=p_SourceRow
	        l_SourceOptions:=l_SourceOptions . " +Focus"
	     else
	        l_SourceOptions:=l_SourceOptions . " -Focus"

	    if LV_GetNext(p_TargetRow-1,"Focused")=p_TargetRow
	        l_TargetOptions:=l_TargetOptions . " +Focus"
	     else
	        l_TargetOptions:=l_TargetOptions . " -Focus"
	    }

    ;-- Get Check
    if LV_GetNext(p_SourceRow-1,"Checked")=p_SourceRow
        l_SourceOptions:=l_SourceOptions . " +Check"
     else
        l_SourceOptions:=l_SourceOptions . " -Check"

    if LV_GetNext(p_TargetRow-1,"Checked")=p_TargetRow
        l_TargetOptions:=l_TargetOptions . " +Check"
     else
        l_TargetOptions:=l_TargetOptions . " -Check"

    ;-- Get Text
    LV_GetText(l_SourceText,p_SourceRow,1)
    LV_GetText(l_TargetText,p_TargetRow,1)


    ;-- Swap attributes and text
    LV_Modify(p_SourceRow,l_TargetOptions,l_TargetText)
    LV_Modify(p_TargetRow,l_SourceOptions,l_SourceText)
    }


;;;;;;*****************
;;;;;;*               *
;;;;;;*    PopupXY    *
;;;;;;*               *
;;;;;;*****************
;;;;;;
;;;;;;
;;;;;;   Description
;;;;;;   ===========
;;;;;;   When passed a parent and child window, this function calculates the center
;;;;;;   position for the child window relative to the parent window.  If necessary,
;;;;;;   the calculated window positions are adjusted so that the child window will
;;;;;;   fit within the primary monitor work area.
;;;;;;
;;;;;;
;;;;;;
;;;;;;   Parameters
;;;;;;   ==========
;;;;;;
;;;;;;       Parameter           Description
;;;;;;       ---------           -----------
;;;;;;       p_Parent            For the parent window, this parameter can contain
;;;;;;                           either the GUI window number (from 1 to 99) or the
;;;;;;                           window title. [Required]
;;;;;;
;;;;;;                           From the AHK documentation...
;;;;;;                           The title or partial title of the window (the
;;;;;;                           matching behavior is determined by
;;;;;;                           SetTitleMatchMode). To use a window class, specify
;;;;;;                           ahk_class ExactClassName (shown by Window Spy). To
;;;;;;                           use a process identifier (PID), specify ahk_pid
;;;;;;                           %VarContainingPID%. To use a window's unique
;;;;;;                           ID number, specify ahk_id %VarContainingID%.
;;;;;;
;;;;;;
;;;;;;       p_Child             For the child (pop-up) window, this parameter can
;;;;;;                           contain either the GUI window number (from 1 to 99)
;;;;;;                           or the window title. [Required]  See the
;;;;;;                           p_Parent description for more information.
;;;;;;
;;;;;;
;;;;;;       p_ChildX            The calculated "X" position for the child window is
;;;;;;                           returned in this variable. [Required]  This
;;;;;;                           parameter must contain a variable name.
;;;;;;
;;;;;;
;;;;;;       p_ChildY            The calculated "Y" position for the child window is
;;;;;;                           returned in this variable. [Required]  This
;;;;;;                           parameter must contain a variable name.
;;;;;;
;;;;;;
;;;;;;
;;;;;;   Return Codes
;;;;;;   ============
;;;;;;   The function does not return a value but the p_ChildX and p_ChildY variables
;;;;;;   are updated to contain the calculated X/Y values.  If the parent or child
;;;;;;   windows cannot be found, these variables are set to 0.
;;;;;;
;;;;;;
;;;;;;
;;;;;;   Calls To Other Functions
;;;;;;   ========================
;;;;;;   (None)
;;;;;;
;;;;;;
;;;;;;-------------------------------------------------------------------------------
;;;;;PopupXY(p_Parent,p_Child,ByRef p_ChildX,ByRef p_ChildY)
;;;;;    {
;;;;;;;;;;    ;[=========]
;;;;;;;;;;    ;[  Debug  ]
;;;;;;;;;;    ;[=========]
;;;;;;;;;;    outputdebug,
;;;;;;;;;;       (ltrim
;;;;;;;;;;        Function: %A_ThisFunc%
;;;;;;;;;;        `t  Parameters
;;;;;;;;;;        `t  ----------
;;;;;;;;;;        `t  p_Parent: "%p_Parent%"
;;;;;;;;;;        `t  p_Child: "%p_Child%"
;;;;;;;;;;        `t  p_ChildX: "%p_ChildX%"
;;;;;;;;;;        `t  p_ChildY: "%p_ChildY%"
;;;;;;;;;;        `t  ----------
;;;;;;;;;;       )
;;;;;;;;;;
;;;;;;;;;;
;;;;;    ;[===============]
;;;;;    ;[  Environment  ]
;;;;;    ;[===============]
;;;;;    l_DetectHiddenWindows:=A_DetectHiddenWindows
;;;;;    DetectHiddenWindows On
;;;;;    SysGet l_MonitorWorkArea,MonitorWorkArea
;;;;;    p_ChildX=0
;;;;;    p_ChildY=0
;;;;;
;;;;;
;;;;;    ;[=================]
;;;;;    ;[  Parent window  ]
;;;;;    ;[=================]
;;;;;    ;-- If necessary, collect hWnd
;;;;;    if p_Parent is Integer
;;;;;        if p_Parent between 1 and 99
;;;;;            {
;;;;;            gui %p_Parent%:+LastFoundExist
;;;;;            IfWinExist
;;;;;                {
;;;;;                gui %p_Parent%:+LastFound
;;;;;                p_Parent:="ahk_id " . WinExist()
;;;;;                }
;;;;;            }
;;;;;
;;;;;    ;-- Collect position/size
;;;;;    WinGetPos l_ParentX,l_ParentY,l_ParentW,l_ParentH,%p_Parent%
;;;;;    outputdebug,
;;;;;       (ltrim join`s
;;;;;        l_ParentX=%l_ParentX%
;;;;;        l_ParentY=%l_ParentY%
;;;;;        l_ParentW=%l_ParentW%
;;;;;        l_ParentH=%l_ParentH%
;;;;;       )
;;;;;
;;;;;    ;-- Anything found?
;;;;;    if l_ParentX is Space
;;;;;        return
;;;;;
;;;;;
;;;;;    ;[================]
;;;;;    ;[  Child window  ]
;;;;;    ;[================]
;;;;;    ;-- If necessary, collect hWnd
;;;;;    if p_Child is Integer
;;;;;        if p_Child between 1 and 99
;;;;;            {
;;;;;            gui %p_Child%:+LastFoundExist
;;;;;            IfWinExist
;;;;;                {
;;;;;                gui %p_Child%:+LastFound
;;;;;                p_Child:="ahk_id " . WinExist()
;;;;;                }
;;;;;            }
;;;;;
;;;;;
;;;;;    ;-- Collect position/size
;;;;;    WinGetPos,,,l_ChildW,l_ChildH,%p_Child%
;;;;;    outputdebug,
;;;;;       (ltrim join`s
;;;;;        l_ChildW=%l_ChildW%
;;;;;        l_ChildH=%l_ChildH%
;;;;;       )
;;;;;
;;;;;    ;-- Anything found?
;;;;;    if l_ChildW is Space
;;;;;        return
;;;;;
;;;;;
;;;;;    ;[=======================]
;;;;;    ;[  Calculate child X/Y  ]
;;;;;    ;[=======================]
;;;;;    p_ChildX:=round(l_ParentX+((l_ParentW-l_ChildW)/2))
;;;;;    p_ChildY:=round(l_ParentY+((l_ParentH-l_ChildH)/2))
;;;;;
;;;;;    ;-- Adjust if necessary
;;;;;    if (p_ChildX<l_MonitorWorkAreaLeft)
;;;;;        p_ChildX:=l_MonitorWorkAreaLeft
;;;;;
;;;;;    if (p_ChildY<l_MonitorWorkAreaTop)
;;;;;        p_ChildY:=l_MonitorWorkAreaTop
;;;;;
;;;;;    l_MaximumX:=l_MonitorWorkAreaRight-l_ChildW
;;;;;    if (p_ChildX>l_MaximumX)
;;;;;        p_ChildX:=l_MaximumX
;;;;;
;;;;;    l_MaximumY:=l_MonitorWorkAreaBottom-l_ChildH
;;;;;    if (p_ChildY>l_MaximumY)
;;;;;        p_ChildY:=l_MaximumY
;;;;;
;;;;;
;;;;;    ;[=====================]
;;;;;    ;[  Reset environment  ]
;;;;;    ;[=====================]
;;;;;    DetectHiddenWindows %l_DetectHiddenWindows%
;;;;;
;;;;;
;;;;;    ;[====================]
;;;;;    ;[  Return to sender  ]
;;;;;    ;[====================]
;;;;;;;;;;    outputdebug,
;;;;;;;;;;       (ltrim join
;;;;;;;;;;        End Func: %A_ThisFunc% (
;;;;;;;;;;        p_ChildX=%p_ChildX% %A_Space%
;;;;;;;;;;        p_ChildY=%p_ChildY%)
;;;;;;;;;;       )
;;;;;
;;;;;    return
;;;;;    }



;**********************************
;*                                *
;*                                *
;*             Hotkeys            *
;*        (ListManagerGUI)        *
;*                                *
;*                                *
;**********************************
;-- Begin #IfWinActive directive
#IfWinActive ahk_group ListManagerGUI_Group

;[===============]
;[  Enter        ]
;[  Shift+Enter  ]
;[===============]
~Enter::
~NumpadEnter::
~+Enter::
~+NumpadEnter::
ListManagerGUI_Command=EnterKey
return


;[===================]
;[  Alt+Enter        ]
;[  Shift+Alt+Enter  ]
;[===================]
!Enter::
!NumpadEnter::
+!Enter::
+!NumpadEnter::
ListManagerGUI_Command=UncheckSelected
return


;[==========]
;[  Insert  ]
;[==========]
~Insert::
ListManagerGUI_Command=Insert
return


;[==========]
;[  Delete  ]
;[==========]
~Delete::
ListManagerGUI_Command=Delete
return


;[==========]
;[  Ctrl+A  ]
;[==========]
~^a::
ListManagerGUI_Command=SelectAll
return


;[================]
;[  Ctrl+Shift+A  ]
;[================]
;--------- This hotkey/command is not documented
^+a::  ;-- Note: Native NOT enabled here
ListManagerGUI_Command=UnselectAll
return


;[==========]
;[  Ctrl+C  ]
;[==========]
~^c::
ListManagerGUI_Command=CopySelected
return


;[================]
;[  Ctrl+Shift+C  ]
;[================]
^+c::  ;-- Note: Native NOT enabled here
ListManagerGUI_Command=CopyChecked
return


;[==========]
;[  Ctrl+K  ]
;[==========]
~^k::
ListManagerGUI_Command=CheckAll
return


;[================]
;[  Ctrl+Shift+K  ]
;[================]
~^+k::
ListManagerGUI_Command=UncheckAll
return


;[==========]
;[  Ctrl+L  ]
;[==========]
~^l::
ListManagerGUI_Command=Lowercase
return


;[==========]
;[  Ctrl+T  ]
;[==========]
^t::
ListManagerGUI_Command=Sort
return


;[================]
;[  Ctrl+Shift+T  ]
;[================]
^+t::
ListManagerGUI_Command=SortDesc
return


;[==========]
;[  Ctrl+U  ]
;[==========]
~^u::
ListManagerGUI_Command=Uppercase
return


;[================]
;[  Ctrl+Shift+L  ]
;[  Ctrl+Shift+U  ]
;[================]
~^+l::  ;-- This hotkey is not documented (yet)
~^+u::
ListManagerGUI_Command=Capitalize
return


;[==========]
;[  Ctrl+S  ]
;[==========]
~^s::
ListManagerGUI_Command=ReturnButton
return


;[==========]
;[  Ctrl+V  ]
;[==========]
~^v::
ListManagerGUI_Command=Paste
return


;[==========]
;[  Ctrl+X  ]
;[==========]
~^x::
ListManagerGUI_Command=Cut
return


;[===========]
;[  Ctrl+Up  ]
;[===========]
;-- Note: Native is not used here because this key combinations acts differently
;   depending on whether Multi is enabled or not.
^Up::
ListManagerGUI_Command=MoveUp
return


;[=============]
;[  Ctrl+Down  ]
;[=============]
;-- Note: Native is not used here because this key combination acts differently
;   depending on whether Multi is enabled or not.
^Down::
ListManagerGUI_Command=MoveDown
return


;[======]
;[  F2  ]
;[======]
~F2::
ListManagerGUI_Command=Modify
return


;[=======]
;[  F10  ]
;[=======]
F10::
ListManagerGUI_Command=ReturnButton
return


;-- End #IfWinActive directive
#IfWinActive

-- syntax/applescript.lua
-- Language:    AppleScript
-- Maintainer:  Jim Eberle <jim.eberle@fastnlight.com>
-- Last Change: Mar 18, 2010
-- URL:         http://www.fastnlight.com/syntax/applescript.vim
-- Lua conversion for Neovim

if vim.b.current_syntax then
  return
end

-- --- Statement ---
vim.cmd('syn keyword scptStmt get set count copy run global local prop property')
vim.cmd('syn keyword scptStmt close put delete duplicate exists')
vim.cmd('syn keyword scptStmt launch open print quit make move reopen save')
vim.cmd('syn keyword scptStmt saving into')
vim.cmd('hi def link scptStmt Statement')

-- --- Type ---
vim.cmd('syn keyword scptType text string number integer real color date')
vim.cmd('hi def link scptType Type')

-- --- Operator ---
vim.cmd('syn keyword scptOp div mod not and or as')
vim.cmd('syn match   scptOp "[-+*/^&]"')
-- MacRoman single char :- (divide)
vim.cmd('syn match scptOp "' .. vim.fn.nr2char(214) .. '"')
vim.cmd('syn match scptOp "\\<\\(a \\)\\?\\(ref\\( to\\)\\?\\|reference to\\)\\>"')
vim.cmd('hi def link scptOp Operator')

-- Containment
vim.cmd('syn match   scptIN "\\<starts\\? with\\>"')
vim.cmd('syn match   scptIN "\\<begins\\? with\\>"')
vim.cmd('syn match   scptIN "\\<ends\\? with\\>"')
vim.cmd('syn match   scptIN "\\<contains\\>"')
vim.cmd('syn match   scptIN "\\<does not contain\\>"')
vim.cmd('syn match   scptIN "\\<doesn\\'t contain\\>"')
vim.cmd('syn match   scptIN "\\<is in\\>"')
vim.cmd('syn match   scptIN "\\<is contained by\\>"')
vim.cmd('syn match   scptIN "\\<is not in\\>"')
vim.cmd('syn match   scptIN "\\<is not contained by\\>"')
vim.cmd('syn match   scptIN "\\<isn\\'t contained by\\>"')
vim.cmd('hi def link scptIN scptOp')

-- Equals
vim.cmd('syn match   scptEQ "="')
vim.cmd('syn match   scptEQ "\\<equal\\>"')
vim.cmd('syn match   scptEQ "\\<equals\\>"')
vim.cmd('syn match   scptEQ "\\<equal to\\>"')
vim.cmd('syn match   scptEQ "\\<is\\>"')
vim.cmd('syn match   scptEQ "\\<is equal to\\>"')
vim.cmd('hi def link scptEQ scptOp')

-- Not Equals
vim.cmd('syn match   scptNE "\\<does not equal\\>"')
vim.cmd('syn match   scptNE "\\<doesn\\'t equal\\>"')
vim.cmd('syn match   scptNE "\\<is not\\>"')
vim.cmd('syn match   scptNE "\\<is not equal\\( to\\)\\?\\>"')
vim.cmd('syn match   scptNE "\\<isn\\'t\\>"')
vim.cmd('syn match   scptNE "\\<isn\\'t equal\\( to\\)\\?\\>"')
vim.cmd('hi def link scptNE scptOp')
-- MacRoman single char /=
vim.cmd('syn match scptNE "' .. vim.fn.nr2char(173) .. '"')

-- Less Than
vim.cmd('syn match   scptLT "<"')
vim.cmd('syn match   scptLT "\\<comes before\\>"')
vim.cmd('syn match   scptLT "\\(is \\)\\?less than"')
vim.cmd('syn match   scptLT "\\<is not greater than or equal\\( to\\)\\?\\>"')
vim.cmd('syn match   scptLT "\\<isn\\'t greater than or equal\\( to\\)\\?\\>"')
vim.cmd('hi def link scptLT scptOp')

-- Greater Than
vim.cmd('syn match   scptGT ">"')
vim.cmd('syn match   scptGT "\\<comes after\\>"')
vim.cmd('syn match   scptGT "\\(is \\)\\?greater than"')
vim.cmd('syn match   scptGT "\\<is not less than or equal\\( to\\)\\?\\>"')
vim.cmd('syn match   scptGT "\\<isn\\'t less than or equal\\( to\\)\\?\\>"')
vim.cmd('hi def link scptGT scptOp')

-- Less Than or Equals
vim.cmd('syn match   scptLE "<="')
vim.cmd('syn match   scptLE "\\<does not come after\\>"')
vim.cmd('syn match   scptLE "\\<doesn\\'t come after\\>"')
vim.cmd('syn match   scptLE "\\(is \\)\\?less than or equal\\( to\\)\\?"')
vim.cmd('syn match   scptLE "\\<is not greater than\\>"')
vim.cmd('syn match   scptLE "\\<isn\\'t greater than\\>"')
vim.cmd('hi def link scptLE scptOp')
-- MacRoman single char <=
vim.cmd('syn match scptLE "' .. vim.fn.nr2char(178) .. '"')

-- Greater Than or Equals
vim.cmd('syn match   scptGE ">="')
vim.cmd('syn match   scptGE "\\<does not come before\\>"')
vim.cmd('syn match   scptGE "\\<doesn\\'t come before\\>"')
vim.cmd('syn match   scptGE "\\(is \\)\\?greater than or equal\\( to\\)\\?"')
vim.cmd('syn match   scptGE "\\<is not less than\\>"')
vim.cmd('syn match   scptGE "\\<isn\\'t less than\\>"')
vim.cmd('hi def link scptGE scptOp')
-- MacRoman single char >=
vim.cmd('syn match scptGE "' .. vim.fn.nr2char(179) .. '"')

-- --- Constant String ---
vim.cmd('syn region  scptString start=+"+ skip=+\\\\\\\\\\\\\\\\|\\\\\\\\"+ end=+"+')
vim.cmd('hi def link scptString String')

-- --- Constant Number ---
vim.cmd('syn match   scptNumber "\\<-\\?\\d\\+\\>"')
vim.cmd('hi def link scptNumber Number')

-- --- Constant Float ---
vim.cmd('syn match   scptFloat display contained "\\d\\+\\.\\d*\\(e[-+]\\=\\d\\+\\)\\="')
vim.cmd('syn match   scptFloat display contained "\\.\\d\\+\\(e[-+]\\=\\d\\+\\)\\=\\>"')
vim.cmd('syn match   scptFloat display contained "\\d\\+e[-+]\\>"')
vim.cmd('hi def link scptFloat Float')

-- --- Constant Boolean ---
vim.cmd('syn keyword scptBoolean true false yes no ask')
vim.cmd('hi def link scptBoolean Boolean')

-- --- Other Constants ---
vim.cmd('syn keyword scptConst it me version pi result space tab anything')
vim.cmd('syn match   scptConst "\\<missing value\\>"')

-- Considering and Ignoring
vim.cmd('syn match   scptConst "\\<application responses\\>"')
vim.cmd('syn match   scptConst "\\<current application\\>"')
vim.cmd('syn match   scptConst "\\<white space\\>"')
vim.cmd('syn keyword scptConst case diacriticals expansion hyphens punctuation')
vim.cmd('hi def link scptConst Constant')

-- Style
vim.cmd('syn match   scptStyle "\\<all caps\\>"')
vim.cmd('syn match   scptStyle "\\<all lowercase\\>"')
vim.cmd('syn match   scptStyle "\\<small caps\\>"')
vim.cmd('syn keyword scptStyle bold condensed expanded hidden italic outline plain')
vim.cmd('syn keyword scptStyle shadow strikethrough subscript superscript underline')
vim.cmd('hi def link scptStyle scptConst')

-- Day
vim.cmd('syn keyword scptDay Mon Tue Wed Thu Fri Sat Sun')
vim.cmd('syn keyword scptDay Monday Tuesday Wednesday Thursday Friday Saturday Sunday')
vim.cmd('syn keyword scptDay weekday')
vim.cmd('hi def link scptDay scptConst')

-- Month
vim.cmd('syn keyword scptMonth Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec')
vim.cmd('syn keyword scptMonth January February March')
vim.cmd('syn keyword scptMonth April May June')
vim.cmd('syn keyword scptMonth July August September')
vim.cmd('syn keyword scptMonth October November December')
vim.cmd('syn keyword scptMonth month')
vim.cmd('hi def link scptMonth scptConst')

-- Time
vim.cmd('syn keyword scptTime minutes hours days weeks')
vim.cmd('hi def link scptTime scptConst')

-- --- Conditional ---
vim.cmd('syn keyword scptCond if then else')
vim.cmd('syn match   scptCond "\\<end if\\>"')
vim.cmd('hi def link scptCond Conditional')

-- --- Repeat ---
vim.cmd('syn keyword scptRepeat repeat with from to by continue')
vim.cmd('syn match   scptRepeat "\\<repeat while\\>"')
vim.cmd('syn match   scptRepeat "\\<repeat until\\>"')
vim.cmd('syn match   scptRepeat "\\<repeat with\\>"')
vim.cmd('syn match   scptRepeat "\\<end repeat\\>"')
vim.cmd('hi def link scptRepeat Repeat')

-- --- Exception ---
vim.cmd('syn keyword scptException try error')
vim.cmd('syn match   scptException "\\<on error\\>"')
vim.cmd('syn match   scptException "\\<end try\\>"')
vim.cmd('syn match   scptException "\\<end error\\>"')
vim.cmd('hi def link scptException Exception')

-- --- Keyword ---
vim.cmd('syn keyword scptKeyword end tell times exit')
vim.cmd('syn keyword scptKeyword application file alias activate')
vim.cmd('syn keyword scptKeyword script on return without given')
vim.cmd('syn keyword scptKeyword considering ignoring items delimiters')
vim.cmd('syn keyword scptKeyword some each every whose where id index item its')
vim.cmd('syn keyword scptKeyword first second third fourth fifth sixth seventh')
vim.cmd('syn keyword scptKeyword eighth ninth tenth container')
vim.cmd('syn match   scptKeyword "\\d\\+\\(st\\|nd\\|rd\\|th\\)"')
vim.cmd('syn keyword scptKeyword last front back middle named thru through')
vim.cmd('syn keyword scptKeyword before after in of the')
vim.cmd('syn match   scptKeyword "\\<text \\>"')
vim.cmd('syn match   scptKeyword "\\<partial result\\>"')
vim.cmd('syn match   scptKeyword "\\<but ignoring\\>"')
vim.cmd('syn match   scptKeyword "\\<but considering\\>"')
vim.cmd('syn match   scptKeyword "\\<with timeout\\>"')
vim.cmd('syn match   scptKeyword "\\<with transaction\\>"')
vim.cmd('syn match   scptKeyword "\\<do script\\>"')
vim.cmd('syn match   scptKeyword "\\<POSIX path\\>"')
vim.cmd('syn match   scptKeyword "\\<quoted form\\>"')
vim.cmd('syn match   scptKeyword "\\'s"')
vim.cmd('hi def link scptKeyword Keyword')

-- US Units
vim.cmd('syn keyword scptUnitUS quarts gallons ounces pounds inches feet yards miles')
vim.cmd('syn match   scptUnitUS "\\<square feet\\>"')
vim.cmd('syn match   scptUnitUS "\\<square yards\\>"')
vim.cmd('syn match   scptUnitUS "\\<square miles\\>"')
vim.cmd('syn match   scptUnitUS "\\<cubic inches\\>"')
vim.cmd('syn match   scptUnitUS "\\<cubic feet\\>"')
vim.cmd('syn match   scptUnitUS "\\<cubic yards\\>"')
vim.cmd('syn match   scptUnitUS "\\<degrees Fahrenheit\\>"')
vim.cmd('hi def link scptUnitUS scptKeyword')

-- British Units
vim.cmd('syn keyword scptUnitBT litres centimetres metres kilometres')
vim.cmd('syn match   scptUnitBT "\\<square metres\\>"')
vim.cmd('syn match   scptUnitBT "\\<square kilometres\\>"')
vim.cmd('syn match   scptUnitBT "\\<cubic centimetres\\>"')
vim.cmd('syn match   scptUnitBT "\\<cubic metres\\>"')
vim.cmd('hi def link scptUnitBT scptKeyword')

-- Metric Units
vim.cmd('syn keyword scptUnitMT liters centimeters meters kilometers grams kilograms')
vim.cmd('syn match   scptUnitMT "\\<square meters\\>"')
vim.cmd('syn match   scptUnitMT "\\<square kilometers\\>"')
vim.cmd('syn match   scptUnitMT "\\<cubic centimeters\\>"')
vim.cmd('syn match   scptUnitMT "\\<cubic meters\\>"')
vim.cmd('syn match   scptUnitMT "\\<degrees Celsius\\>"')
vim.cmd('syn match   scptUnitMT "\\<degrees Kelvin\\>"')
vim.cmd('hi def link scptUnitMT scptKeyword')

-- --- Comment ---
vim.cmd('syn match   scptComment "--.*"')
vim.cmd('syn match   scptComment "#.*"')
vim.cmd('syn region  scptComment start="(\\*" end="\\*)"')
vim.cmd('hi def link scptComment Comment')

-- --- Todo ---
vim.cmd('syn keyword scptTodo contained TODO FIXME XXX')
vim.cmd('hi def link scptTodo Todo')

vim.b.current_syntax = 'applescript'

vim9script
# File: plugin/undotree.vim
# Description: Manage your undo history in a graph.
# Author: Ming Bai <mbbill@gmail.com>
# Converted To Vim9: Mao-Yining <mao.yining@outlook.com>
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

if get(g:, 'loaded_undotree', false)
    finish
endif
g:loaded_undotree = true

import autoload "../autoload/undotree.vim"

augroup undotreeDetectPersistenceUndo
    au!
    au BufReadPost * undotree.UndotreePersistUndo(false)
augroup END

command! -nargs=0 -bar UndotreeToggle      undotree.UndotreeToggle()
command! -nargs=0 -bar UndotreeHide        undotree.UndotreeHide()
command! -nargs=0 -bar UndotreeShow        undotree.UndotreeShow()
command! -nargs=0 -bar UndotreeFocus       undotree.UndotreeFocus()
command! -nargs=0 -bar UndotreePersistUndo undotree.UndotreePersistUndo(true)

# vim:set et fdm=marker sts=4 sw=4

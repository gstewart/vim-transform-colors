"=============================================================================
" File: transform_colors.vim
" Author: g.stew
" Description: transform the colors
" Version: 1.0
" Last Modified: September 17, 2014
"=============================================================================

if exists('g:loaded_transform_colors')
  finish
endif
let g:loaded_transform_colors = 1

let s:old_cpo = &cpo
set cpo&vim

" matrix definitions {{{
let g:transform_matrices = {
      \   "simple_inverted": {
      \     "description": "simple inverted colors",
      \     "matrix": [
      \       [-1,  0,  0,  0 ],
      \       [ 0, -1,  0,  0 ],
      \       [ 0,  0, -1,  0 ],
      \       [ 1,  1,  1,  1 ]
      \     ]
      \   },
      \   "inverted_1": {
      \     "description": "smart inverted colors 1",
      \     "matrix": [
      \       [ 0.3333333, -0.6666667, -0.6666667,  0.0000000 ],
      \       [-0.6666667,  0.3333333, -0.6666667,  0.0000000 ],
      \       [-0.6666667, -0.6666667,  0.3333333,  0.0000000 ],
      \       [ 1.0000000,  1.0000000,  1.0000000,  1.0000000 ]
      \     ]
      \   },
      \   "inverted_2": {
      \     "description": "smart inverted colors 2",
      \     "matrix": [
      \       [ 1, -1, -1,  0 ],
      \       [-1,  1, -1,  0 ],
      \       [-1, -1,  1,  0 ],
      \       [ 1,  1,  1,  1 ]
      \     ]
      \   },
      \   "inverted_3": {
      \     "description": "smart inverted colors 3",
      \     "matrix": [
      \       [ 0.39, -0.62, -0.62,  0.00 ],
      \       [-1.21, -0.22, -1.22,  0.00 ],
      \       [-0.16, -0.16,  0.84,  0.00 ],
      \       [ 1.00,  1.00,  1.00,  1.00 ]
      \     ]
      \   },
      \   "inverted_4": {
      \     "description": "smart inverted colors 4",
      \     "matrix": [
      \       [ 1.0895080, -0.9326327, -0.9326330,  0.0000000 ],
      \       [-1.8177180,  0.1683074, -1.8416920,  0.0000000 ],
      \       [-0.2445895, -0.2478156,  1.7621850,  0.0000000 ],
      \       [ 1.0000000,  1.0000000,  1.0000000,  1.0000000 ]
      \     ]
      \   },
      \   "inverted_5": {
      \     "description": "smart inveted colors 5",
      \     "matrix": [
      \       [ 0.50, -0.78, -0.78,  0.00 ],
      \       [-0.56,  0.72, -0.56,  0.00 ],
      \       [-0.94, -0.94,  0.34,  0.00 ],
      \       [ 1.00,  1.00,  1.00,  1.00 ]
      \     ]
      \   },
      \   "negative_sepia": {
      \     "description": "negative sepia colors",
      \     "matrix": [
      \       [-0.393, -0.349, -0.272,  0.000 ],
      \       [-0.769, -0.686, -0.534,  0.000 ],
      \       [-0.189, -0.168, -0.131,  0.000 ],
      \       [ 1.351,  1.203,  0.937,  1.000 ]
      \     ]
      \   },
      \   "negative_grayscale": {
      \     "description": "negative grayscale colors",
      \     "matrix": [
      \       [-0.3, -0.3, -0.3,  0.0 ],
      \       [-0.6, -0.6, -0.6,  0.0 ],
      \       [-0.1, -0.1, -0.1,  0.0 ],
      \       [ 1.0,  1.0,  1.0,  1.0 ]
      \     ]
      \   },
      \   "negative_red": {
      \     "description": "negative red colors",
      \     "matrix": [
      \       [-0.3,  0.0,  0.0,  0.0 ],
      \       [-0.6,  0.0,  0.0,  0.0 ],
      \       [-0.1,  0.0,  0.0,  0.0 ],
      \       [ 1.0,  0.0,  0.0,  1.0 ]
      \     ]
      \   },
      \   "red": {
      \     "description": "red colors",
      \     "matrix": [
      \       [0.3,  0.0,  0.0,  0.0 ],
      \       [0.6,  0.0,  0.0,  0.0 ],
      \       [0.1,  0.0,  0.0,  0.0 ],
      \       [0.0,  0.0,  0.0,  1.0 ]
      \     ]
      \   },
      \   "grayscale": {
      \     "description": "grayscale colors",
      \     "matrix": [
      \       [0.3,  0.3,  0.3,  0.0 ],
      \       [0.6,  0.6,  0.6,  0.0 ],
      \       [0.1,  0.1,  0.1,  0.0 ],
      \       [0.0,  0.0,  0.0,  1.0 ]
      \     ]
      \   },
      \ }
"}}}

function! s:replace_with_transform_color() "{{{
  let l:save_cursor = getpos(".")
  let search_pattern = '\v([\#\k]\k*%#\k*)'

  let cursor_color = expand('<cWORD>')

  let transformed_color = transform_colors#get_transformed_color(cursor_color)

  let replace_cmd = 's/' . search_pattern . '/' . transformed_color . '/'

  echomsg printf("[search color: %s] [replace color: %s] [replace command: %s]", cursor_color, transformed_color, replace_cmd)

  " exec replace_cmd

  " echomsg replace_cmd

  call setpos('.', l:save_cursor)
endfunction "}}}

command! TransformColorUnderCursor call <sid>replace_with_transform_color()

noremap <Plug>(transform_colors_transform_color_under_cursor) :TransformColorUnderCursor<cr>




" command to replace hex color value under cursor with transformed color (using default transform matrix)
" command! -nargs=0 ReplaceWithTransformColor call <SID>replace_with_transform_color()

" nnoremap <silent> <Plug>(transform_colors_replace_with_transformed_color) :ReplaceWithTransformColor<CR>



command! -nargs=? -complete=customlist,transform_colors#complete_transform_matrix
      \ TransformAllHighlights call transform_colors#transform_all_highlights(<q-args>)

nnoremap <silent> <Plug>(transform_colors_transform_all_highlights) :TransformAllHighlights<CR>





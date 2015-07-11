"=============================================================================
" File: transform_colors.vim
" Author: g.stew
" Description: transform the colors using a matrix
" Version: 1.0
" Last Modified: September 17, 2014
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim



let s:default_transform_matrix_name = 'inverted_1'
let s:default_transform_matrix = get(g:transform_matrices, s:default_transform_matrix_name).matrix

let s:default_transform_debug_log = 0


" global options "{{{
  let g:transform_color_matrix = get(g:, 'transform_color_matrix', s:default_transform_matrix)
  let g:transform_color_debug_log = get(g:, 'transform_color_debug_log', s:default_transform_debug_log)
"}}}


function transform_colors#complete_transform_matrix(arglead, cmdline, cursorpos) "{{{
  return keys(g:transform_matrices)
endfunction "}}}



function! transform_colors#get_transformed_color(hex_color, ...) "{{{
  try
    let clean_hex_color = s:clean_hex_value(a:hex_color)

    if !s:is_valid_hex_value(clean_hex_color)
      throw printf("transform_colors: error - not a valid hex color value: [input: %s] [clean: %s]", a:hex_color, clean_hex_color)
    endif

    let rgblist = s:hex_to_rgb_list(clean_hex_color)
    let rgbmatrix = s:rgb_list_to_matrix(rgblist)

    let transform_matrix = (a:0 == 1) ? a:1 : g:transform_color_matrix

    let matrix_result = s:multiply_matrix(rgbmatrix, transform_matrix)
    let rgblist_result = s:matrix_to_rgb_list(matrix_result)
    let hex_result = s:rgb_list_to_hex(rgblist_result)

    if g:transform_color_debug_log
      echomsg "Input"
      echomsg repeat('-', 20)
      echomsg printf("hex_color: %s", string(a:hex_color))
      echomsg printf("clean_hex_color: %s", string(clean_hex_color))
      echomsg printf("rgblist: %s", string(rgblist))
      echomsg printf("rgbmatrix: %s", string(rgbmatrix))
      echomsg printf("transform_matrix: %s", string(transform_matrix))
      echomsg repeat('-', 20)
      echomsg "Output"
      echomsg repeat('-', 20)
      echomsg printf("matrix_result: %s", string(matrix_result))
      echomsg printf("rgblist_result: %s", string(rgblist_result))
      echomsg printf("hex_result: %s", string(hex_result))
    endif


    return hex_result
  catch
    echohl WarningMsg | echo "Error finding transformed color" | echohl None
    echohl WarningMsg | echo v:exception | echohl None
    return a:hex_color
  endtry
endfunction "}}}


function! s:multiply_matrix(m1, m2) "{{{
  let n = len(a:m1)
  let p = len(a:m2[0])

  if len(a:m1) != len(a:m2)
    throw "transform_colors: error - matrix sizes do not match"
  endif

  let result = [0, 0, 0, 0]

  let j = 0

  while j < p
    let k = 0
    while k < n
      let result[j] += a:m1[k] * a:m2[k][j]
      let k = k + 1
    endwhile
    let j = j + 1
  endwhile

  " don't return the last item since it's a dummy
  " return result[0:-2]
  return result
endfunction "}}}





function! s:hex_to_rgb_list(hex_color) "{{{

  let red = str2nr(a:hex_color[0].a:hex_color[1], 16)
  let green = str2nr(a:hex_color[2].a:hex_color[3], 16)
  let blue = str2nr(a:hex_color[4].a:hex_color[5], 16)

  return [red, green, blue]
endfunction "}}}


function! s:clean_hex_value(hex_color) "{{{
  " trim the # from hex value
  let hex_color = substitute(a:hex_color, '#\|0x\|0X', '', '')

  " covert 3 char hex to 6 by doubling each character
  if len(hex_color) == 3
    let hex_color = substitute(hex_color, '.', '&&', 'g')
  endif

  " fill hex with leading zeros if it's not 6 characters
  if len(hex_color) < 6
    let hex_color = printf("%06X", "0x" . hex_color)
  endif

  return hex_color
endfunction "}}}


function! s:is_valid_hex_value(hex_color) "{{{
  return a:hex_color =~ '\v^\x{6}$'
endfunction "}}}


function! s:rgb_list_to_matrix(rgb_list) "{{{
  let matrix = map(copy(a:rgb_list), "v:val/255.0")
  let dummy = 1.0

  return add(matrix, dummy) 
endfunction "}}}


function! s:matrix_to_rgb_list(matrix) "{{{
  " convert after removing last item since it's a dummy
  call remove(a:matrix, -1)

  let rgb_list = map(copy(a:matrix), 's:convert_matrix_val(v:val, 255)')

  return rgb_list
endfunction "}}}


function! s:convert_matrix_val(val, max_scale) "{{{
  let cnv_val = float2nr(round(a:val*a:max_scale))

  if cnv_val < 0
    return 0
  elseif cnv_val > 255
    return 255
  else
    return cnv_val
  endif
endfunction "}}}


function! s:rgb_list_to_hex(rgblist) "{{{
  let [red, green, blue] = a:rgblist

  let hex_val = printf("#%02X%02X%02X", red, green, blue)

  return hex_val
endfunction "}}}


function! transform_colors#transform_all_highlights(...) "{{{
  let groups = s:getAllGroups()
  let transform_matrix_name = (a:0 == 1) ? a:1 : s:default_transform_matrix_name

  if has_key(g:transform_matrices, transform_matrix_name)
    for group in s:getAllGroups()
      call transform_colors#transform_hl_group(group, get(g:transform_matrices, transform_matrix_name).matrix)
    endfor
  endif

endfunction "}}}



function! transform_colors#transform_hl_group(group_name, ...) "{{{
  " use the global transform matrix (or default) if a matrix wasn't passed
  let matrix = (a:0 == 1) ? a:1 : g:transform_color_matrix

  for [key, value] in items(s:get_group_colors(a:group_name))
    let out_color = transform_colors#get_transformed_color(value, matrix)
    let hi_cmd = printf("highlight %s %s=%s", a:group_name, key, out_color)

    " echomsg hi_cmd
    execute hi_cmd
  endfor
endfunction "}}}


function! s:get_group_colors(group_name) "{{{
  let color_dict = {}

  let group_hlID = hlID(a:group_name)
  let group_synIDtrans = synIDtrans(group_hlID)

  " if the group uses a link then the colors are not returned since the link will still work
  if group_hlID == group_synIDtrans
    for attr in ['bg', 'fg']
      let attr_val = synIDattr(group_synIDtrans, attr."#")
      if !empty(attr_val) && s:is_valid_hex_value(s:clean_hex_value(attr_val))
        let color_dict["gui".attr] = attr_val
      endif
    endfor
  endif

  return color_dict
endfunction "}}}


function! s:getAllGroups() "{{{
  redir => highlights
  silent hi
  redir END
  let groups = []
  for line in split(highlights, '\n')
      if line =~ '\v^\w*>.+gui(fg|bg)'
        let name = matchstr(line, '^\w*')
        call add(groups, name)
      endif
  endfor
  return groups
endfunc "}}}






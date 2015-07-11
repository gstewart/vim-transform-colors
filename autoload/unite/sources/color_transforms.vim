

let s:save_cpo = &cpo
set cpo&vim

" Options {{{
" }}}

" Variables {{{
" }}}

" Functions {{{

function! unite#sources#color_transforms#define() "{{{
  return [ s:source ]
endfunction "}}}


function! s:get_colorscheme_reset_command()
  return printf("colorscheme %s", s:beforecolor)
endfunction

function! s:get_transform_command(matrix_name)
  let transform_command = printf("TransformAllHighlights %s", a:matrix_name)
  
  return printf("%s | %s", s:get_colorscheme_reset_command(), transform_command)
endfunction

" }}}

" Source {{{
let s:source = {
      \ 'name': 'color_transforms',
      \ 'description' : 'apply different transform matrices to colorscheme',
      \ 'syntax': 'uniteSource__ColorTransforms',
      \ 'hooks': {},
      \ 'action_table': {},
      \ 'default_kind' : 'command',
      \ }

function! s:source.hooks.on_init(args, context) "{{{
  let s:beforecolor = get(g:, 'colors_name', 'default')
endfunction "}}}

function! s:source.hooks.on_syntax(args, context) "{{{
  syntax match uniteSource__ColorTransforms_DescriptionLine
        \ / -- .*$/
        \ contained containedin=uniteSource__ColorTransforms
  syntax match uniteSource__ColorTransforms_Description
        \ /.*$/
        \ contained containedin=uniteSource__ColorTransforms_DescriptionLine
  syntax match uniteSource__ColorTransforms_Marker
        \ / -- /
        \ contained containedin=uniteSource__ColorTransforms_DescriptionLine

  highlight default link uniteSource__ColorTransforms_DescriptionLine Comment
  highlight default link uniteSource__ColorTransforms_Description Type
  highlight default link uniteSource__ColorTransforms_Marker Delimiter
endfunction "}}}

function! s:source.hooks.on_close(args, context) "{{{
  execute s:get_colorscheme_reset_command()
endfunction "}}}



function! s:source.gather_candidates(args, context) "{{{
  return values(map(copy(g:transform_matrices), 'unite#sources#color_transforms#create_matrix_dict(v:key, v:val)'))
endfunction "}}}


function! s:source.complete(args, context, arglead, cmdline, cursorpos)  "{{{
  let candidates = self.gather_candidates(a:args, a:context)
  return map(candidates, "v:val.word")
endfunction "}}}


function! unite#sources#color_transforms#create_matrix_dict(name, data_dict) "{{{
  let dict = {}
  let dict.word = a:name
  let dict.source__description = get(a:data_dict, 'description', a:name . " color transformation" )
  let dict.source__matrix = string(get(a:data_dict, 'matrix', [ [], [], [], [] ] ))
  let dict.action__command = s:get_transform_command(a:name)
  let dict.action__histadd = 0
  let dict.is_multiline = 1

  return dict
endfunction "}}}


" Filters"{{{
function! s:source.source__converter(candidates, context) "{{{
  let separator = ' -- '
  let max_matrix_name = max(map(copy(a:candidates), 'len(v:val.word)'))
  let second_line_prefix = max_matrix_name + len(separator)

  let template = "%-" . max_matrix_name . "s%s%s\n%" . second_line_prefix . "s%s"

  for candidate in a:candidates
    let candidate.abbr = printf(template, candidate.word, separator, candidate.source__description, '', candidate.source__matrix)
  endfor

  return a:candidates
endfunction "}}}


let s:source.converters = s:source.source__converter

" }}}

" Actions"{{{

"   action preview {{{
let s:source.action_table.preview = {
      \ 'description': 'preview {word} color transform',
      \ 'is_quit': 0,
      \ }

function! s:source.action_table.preview.func(candidate) "{{{
  execute a:candidate.action__command
endfunction "}}}
" }}}


" }}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker


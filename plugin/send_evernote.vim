if !has("python")
    finish
endif

:command! -nargs=0 Evernote :call send_evernote#send()

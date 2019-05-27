if system("flake8 --version 2>/dev/null")
    let b:ale_linters = ['flake8']
endif

if system("autopep8 --version 2>/dev/null")
    let b:ale_linters = ['trim_whitespace', 'autopep8']
else
    let b:ale_linters = ['trim_whitespace']
endif

let b:ale_python_flake8_options = '--max-line-length=119'

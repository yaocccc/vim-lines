let s:line_nerdfont_enable = get(g:, 'line_nerdfont_enable', 0)
let s:icons = { 'folderClosed': '', 'folderOpened': '', 'folderSymlink': '', 'file': '', 'fileSymlink': '', 'fileHidden': '﬒', 'excel': '', 'word': '', 'ppt': '', 'stylus': '', 'sass': '', 'html': '', 'xml': '謹', 'ejs': '', 'css': '', 'webpack': 'ﰩ', 'markdown': '', 'json': '', 'javascript': '', 'javascriptreact': '', 'ruby': '', 'php': '', 'python': '', 'coffee': '', 'mustache': '', 'conf': '', 'image': '', 'ico': '', 'twig': '', 'c': '', 'h': '', 'haskell': '', 'lua': '', 'java': '', 'terminal': '', 'ml': 'λ', 'diff': '', 'sql': '', 'clojure': '', 'edn': '', 'scala': '', 'go': '', 'dart': '', 'firefox': '', 'vs': '', 'perl': '', 'rss': '', 'csharp': '', 'fsharp': '', 'rust': '', 'dlang': '', 'erlang': '', 'elixir': '', 'elm': '', 'mix': '', 'vim': '', 'ai': '', 'psd': '', 'psb': '', 'typescript': '', 'typescriptreact': '', 'julia': '', 'puppet': '', 'vue': '﵂', 'swift': '', 'git': '', 'bashrc': '', 'favicon': '', 'docker': '', 'gruntfile': '', 'gulpfile': '', 'dropbox': '', 'license': '', 'procfile': '', 'jquery': '', 'angular': '', 'backbone': '', 'requirejs': '', 'materialize': '', 'mootools': '', 'vagrant': '', 'svg': 'ﰟ', 'font': '', 'text': '', 'archive': '', 'lock': '' }
let s:extensions = { 'styl': 'stylus', 'sass': 'sass', 'scss': 'sass', 'htm': 'html', 'html': 'html', 'slim': 'html', 'xml': 'xml', 'xaml': 'xml', 'ejs': 'ejs', 'css': 'css', 'less': 'css', 'md': 'markdown', 'mdx': 'markdown', 'markdown': 'markdown', 'rmd': 'markdown', 'lock': 'lock', 'json': 'json', 'js': 'javascript', 'cjs': 'javascript', 'mjs': 'javascript', 'es6': 'javascript', 'jsx': 'javascriptreact', 'rb': 'ruby', 'ru': 'ruby', 'php': 'php', 'py': 'python', 'pyc': 'python', 'pyo': 'python', 'pyd': 'python', 'coffee': 'coffee', 'mustache': 'mustache', 'hbs': 'mustache', 'config': 'conf', 'conf': 'conf', 'ini': 'conf', 'yml': 'conf', 'yaml': 'conf', 'toml': 'conf', 'jpg': 'image', 'jpeg': 'image', 'bmp': 'image', 'png': 'image', 'gif': 'image', 'webp': 'image', 'ico': 'ico', 'twig': 'twig', 'cpp': 'c', 'c++': 'c', 'cxx': 'c', 'cc': 'c', 'cp': 'c', 'c': 'c', 'h': 'h', 'hh': 'h', 'hpp': 'h', 'hxx': 'h', 'hs': 'haskell', 'lhs': 'haskell', 'lua': 'lua', 'java': 'java', 'jar': 'java', 'sh': 'terminal', 'fish': 'terminal', 'bash': 'terminal', 'zsh': 'terminal', 'ksh': 'terminal', 'csh': 'terminal', 'awk': 'terminal', 'ps1': 'terminal', 'bat': 'terminal', 'cmd': 'terminal', 'ml': 'ml', 'mli': 'ml', 'diff': 'diff', 'db': 'sql', 'sql': 'sql', 'dump': 'sql', 'accdb': 'sql', 'clj': 'clojure', 'cljc': 'clojure', 'cljs': 'clojure', 'edn': 'edn', 'scala': 'scala', 'go': 'go', 'dart': 'dart', 'xul': 'firefox', 'pl': 'perl', 'pm': 'perl', 't': 'perl', 'rss': 'rss', 'sln': 'vs', 'suo': 'vs', 'csproj': 'vs', 'cs': 'csharp', 'fsscript': 'fsharp', 'fsx': 'fsharp', 'fs': 'fsharp', 'fsi': 'fsharp', 'rs': 'rust', 'rlib': 'rust', 'd': 'dlang', 'erl': 'erlang', 'hrl': 'erlang', 'ex': 'elixir', 'eex': 'elixir', 'exs': 'elixir', 'exx': 'elixir', 'leex': 'elixir', 'vim': 'vim', 'ai': 'ai', 'psd': 'psd', 'psb': 'psd', 'ts': 'typescript', 'tsx': 'javascriptreact', 'jl': 'julia', 'pp': 'puppet', 'vue': 'vue', 'elm': 'elm', 'swift': 'swift', 'xcplayground': 'swift', 'svg': 'svg', 'otf': 'font', 'ttf': 'font', 'fnt': 'font', 'txt': 'text', 'text': 'text', 'zip': 'archive', 'tar': 'archive', 'gz': 'archive', 'gzip': 'archive', 'rar': 'archive', '7z': 'archive', 'iso': 'archive', 'doc': 'word', 'docx': 'word', 'docm': 'word', 'csv': 'excel', 'xls': 'excel', 'xlsx': 'excel', 'xlsm': 'excel', 'ppt': 'ppt', 'pptx': 'ppt', 'pptm': 'ppt' }
let s:patternMatches = [ ['.*jquery.*.js$', 'jquery'], ['.*angular.*.js$', 'angular'], ['.*backbone.*.js$', 'backbone'], ['.*require.*.js$', 'requirejs'], ['.*materialize.*.js$', 'materialize'], ['.*materialize.*.css$', 'materialize'], ['.*mootools.*.js$', 'mootools'] ]
let s:filenames = { 'gruntfile': 'gruntfile', 'gulpfile': 'gulpfile', 'gemfile': 'ruby', 'guardfile': 'ruby', 'capfile': 'ruby', 'rakefile': 'ruby', 'mix': 'mix', 'dropbox': 'dropbox', 'vimrc': 'vim', '.vimrc': 'vim', '.gvimrc': 'vim', '_vimrc': 'vim', '_gvimrc': 'vim', 'license': 'license', 'procfile': 'procfile', 'Vagrantfile': 'vagrant', 'docker-compose.yml': 'docker', '.gitconfig': 'git', '.gitignore': 'git', 'webpack': 'webpack', '.bashrc': 'bashrc', '.zshrc': 'bashrc', '.bashprofile': 'bashrc', 'favicon.ico': 'favicon', 'dockerfile': 'docker', '.dockerignore': 'docker' }

func! nerdfont#get_fileicon(ft, fname)
    if s:line_nerdfont_enable == 0 | return '' | endif
    if a:fname == '' | return '' | endif

    if exists('s:filenames.' . a:fname)
        return s:get_icon(s:filenames[a:fname])
    endif

    for mat in s:patternMatches
        if a:fname =~# mat[0] | return s:get_icon(mat[1]) | endif
    endfor

    if exists('s:extensions.' . fnamemodify(a:fname, ':e'))
        return s:get_icon(s:extensions[fnamemodify(a:fname, ':e')])
    endif

    return s:get_icon(a:ft)
endf

func! nerdfont#get_diricon()
    if s:line_nerdfont_enable == 0 | return '' | endif
    return s:get_icon('folderOpened')
endf

func! s:get_icon(key)
    return get(s:icons, a:key, s:icons['file']) . ' '
endf

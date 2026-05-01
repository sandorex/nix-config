local core = require("core.utils")

-- use shellcheck as makeprg (gcc format as errorformat already exists)
vim.bo.makeprg = "shellcheck -f gcc %"

-- autocomplete pairs
core.map_autopairs({ '""', "''", "()", "[]", "{}", "``" })

-- snippets
local ftype = "sh"
core.snippet2(ftype, "env", "#!/usr/bin/env bash")
core.snippet2(ftype, "shebang", "#!/usr/bin/env bash")
core.snippet2(ftype, "cddir", [[cd "\$(dirname "\${BASH_SOURCE[0]}")" || exit 1]])
core.snippet2(ftype, "dir", [[DIR=\$(realpath "\$(dirname "\${BASH_SOURCE[0]}")")]])
core.snippet2(ftype, "isroot", [[
if [ "\$(id -u)" -ne 0 ]; then
    $0
fi
]])
core.snippet2(ftype, "parseargs", [[
POSITIONAL_ARGS=()
while [ \$# -gt 0 ]; do
    case \$1 in
        --example)
        EXAMPLE=\$1
        shift 2
        ;;
    -*)
        echo "Unknown option \$1"
        exit 1
        ;;
    *)
        # save positional arg
        POSITIONAL_ARGS+=("\$1")
        shift
        ;;
    esac
done

# restore positional parameters
set -- "\${POSITIONAL_ARGS[@]}"
]])


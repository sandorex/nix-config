local core = require("core.utils")

-- use shellcheck as makeprg (gcc format as errorformat already exists)
vim.bo.makeprg = "shellcheck -f gcc %"

-- autocomplete pairs
core.map_autopairs({ '""', "''", "()", "[]", "{}", "``" })

-- snippets
core.snippet("env", "#!/usr/bin/env bash")
core.snippet("shebang", "#!/usr/bin/env bash")
core.snippet("cddir", [[cd "\$(dirname "\${BASH_SOURCE[0]}")" || exit 1]])
core.snippet("dir", [[DIR=\$(realpath "\$(dirname "\${BASH_SOURCE[0]}")")]])
core.snippet("isroot", [[
if [ "\$(id -u)" -ne 0 ]; then
    $0
fi
]])
core.snippet("parseargs", [[
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


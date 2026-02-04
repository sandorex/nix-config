local core = require("core")

-- autocomplete pairs
core.map_autopairs({ '""', "{}", "[]", "()", "<>" })

core.snippet("testmod", [[
#[cfg(tests)]
mod tests {
    #[test]
    fn test_unnamed() {}
}
]])
core.snippet("test", [[
#[test]
fn test_unnamed() {}
]])


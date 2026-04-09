local core = require("core.utils")

-- autocomplete pairs
core.map_autopairs({ '""', "{}", "[]", "()" })

core.snippet("testmod", [[
#[cfg(test)]
mod tests {
    #[test]
    fn test_unnamed() {}
}
]])
core.snippet("test", [[
#[test]
fn test_unnamed() {}
]])


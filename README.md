Example:

```lua
local myDialogue = {
  dialogue  = "Testing dialogue, testing testing one two three four. Should probably actually test what happens when this text becomes too long.",
  targetEnt = PlayerPedId(),
  cb        = onInteract,
  options   = {
    {
      name = "test_opt_a",
      label = "Testing option A.<br>Some test description here."
    },
    {
      name = "test_opt_b",
      label = "Testing option B.<br>Some test description here."
    },
    {
      name = "test_opt_c",
      label = "Testing option C. Some test description here."
    },
    {
      name = "test_opt_d",
      label = "Testing option D. Some test description here."
    },
  }
}

local function onInteract(data)
  if not data then
    return
  end

  print(data.option.name)
end

exports['fivem-dialogue']:Open(myDialogue)```

-- Load common vim settings
vim.cmd('set runtimepath^=~/.vim runtimepath+=~/.vim/after')
vim.o.packpath = vim.o.runtimepath
vim.cmd('source ~/.vim/vimrc')


require("copilot").setup({
  suggestion = {
    auto_trigger = true,
    keymap = {
      accept = "<C-l>",
    }
  }
})

require('avante_lib').load()
require('avante').setup({
  auto_suggestions_provider = "copilot", -- Since auto-suggestions are a high-frequency operation and therefore expensive, it is recommended to specify an inexpensive provider or even a free provider: copilot
  behaviour = {
    auto_apply_diff_after_generation = true,
  },
  mappings = {
    ---@class AvanteConflictMappings
    diff = {
      ours = "<leader>co",
      theirs = "<leader>ct",
      all_theirs = "<leader>ca",
      both = "<leader>cb",
      cursor = "<leader>cc",
      next = "]x",
      prev = "[x",
    },
    files = {
      add_current = "<leader>ab" -- Add current buffer to selected files
    }
  }
})


-- leader mappings
vim.keymap.set("n", "<leader>ac", ":AvanteClear<CR>")

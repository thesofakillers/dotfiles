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
      cursor = "<leader>cu",
      next = "]x",
      prev = "[x",
    },
    files = {
      add_current = "<leader>ab" -- Add current buffer to selected files
    }
  }
})
-- Treat Avante files as markdown
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = "Avante",
  callback = function()
    vim.bo.filetype = "markdown"
  end,
})

-- Disable hard line breaks for AvanteInput files
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = "AvanteInput",
  callback = function()
    vim.bo.textwidth = 0
  end,
})



-- leader mappings
vim.keymap.set("n", "<leader>ac", ":AvanteClear<CR>")

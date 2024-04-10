return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "princejoogie/dir-telescope.nvim",
    "/folke/trouble.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      cond = function()
        return vim.fn.executable("make") == 1
      end,
    },
  },
  config = function()
    local telescope = require("telescope")
    local trouble = require("trouble.providers.telescope")
    local custom_pickers = require("core.telescope-custom-pickers")

    telescope.setup({
      defaults = {
        mappings = {
          i = {
            ["<C-u>"] = false,
            ["<C-d>"] = false,
            ["<C-t>"] = trouble.open_with_trouble,
          },
          n = { ["<C-t>"] = trouble.open_with_trouble },
        },
        wrap_results = false,
      },
      pickers = {
        live_grep = {
          mappings = {
            i = {
              ["<C-f>"] = custom_pickers.actions.set_extension,
              ["<C-l>"] = custom_pickers.actions.set_folders,
            },
          },
        },
      },
    })

    telescope.load_extension("fzf")
    telescope.load_extension("dir")

    local builtin = require("telescope.builtin")
    local themes = require("telescope.themes")

    vim.keymap.set("n", "<leader>/", function()
      builtin.current_buffer_fuzzy_find(themes.get_dropdown({
        winblend = 10,
        previewer = false,
      }))
    end, { desc = "[/] Fuzzily search in current buffer" })

    vim.keymap.set("n", "<C-p>", builtin.git_files, { desc = "Search [G]it [F]iles" })
    vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
    vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
    vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch currend word" })

    vim.keymap.set("n", "<leader>sg", function()
      builtin.live_grep(require("telescope.themes").get_dropdown({
        winblend = 10,
      }))
    end, { desc = "[S]earch by [G]rep" })

    -- dir-telescope maps
    vim.keymap.set("n", "<leader>fd", "<cmd>Telescope dir live_grep<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "<leader>ff", "<cmd>Telescope dir find_files<CR>", { noremap = true, silent = true })
  end,
}

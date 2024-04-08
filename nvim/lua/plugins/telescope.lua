return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-live-grep-args.nvim",
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
    local lga_actions = require("telescope-live-grep-args.actions")
    local trouble = require("trouble.providers.telescope")

    require("telescope").setup({
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
        path_display = { "smart" },
      },
      extensions = {
        live_grep_args = {
          mappings = {
            i = {
              ["<C-k>"] = lga_actions.quote_prompt(),
              ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
            },
          },
        },
      },
    })

    pcall(require("telescope").load_extension, "fzf")
    require("telescope").load_extension("dir")

    vim.keymap.set("n", "<leader>/", function()
      require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
        winblend = 10,
        previewer = false,
      }))
    end, { desc = "[/] Fuzzily search in current buffer" })
    vim.keymap.set("n", "<C-p>", require("telescope.builtin").git_files, { desc = "Search [G]it [F]iles" })
    vim.keymap.set("n", "<leader>sf", require("telescope.builtin").find_files, { desc = "[S]earch [F]iles" })
    vim.keymap.set("n", "<leader>sr", require("telescope.builtin").resume, { desc = "[S]earch [R]esume" })

    -- live_grep_args maps
    local live_grep_args = require("telescope").extensions.live_grep_args.live_grep_args

    vim.keymap.set("n", "<leader>sg", function()
      live_grep_args(require("telescope.themes").get_dropdown({
        winblend = 10,
      }))
    end, { desc = "[S]earch by [G]rep" })

    local lga_shortcuts = require("telescope-live-grep-args.shortcuts")

    vim.keymap.set("n", "<leader>sw", lga_shortcuts.grep_word_under_cursor, { desc = "[S]earch currend word" })

    -- dir-telescope maps
    vim.keymap.set("n", "<leader>fd", "<cmd>Telescope dir live_grep<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "<leader>ff", "<cmd>Telescope dir find_files<CR>", { noremap = true, silent = true })
  end,
}

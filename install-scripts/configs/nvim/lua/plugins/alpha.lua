return {
	"goolord/alpha-nvim",
	dependencies = {
		"echasnovski/mini.icons",
		"nvim-lua/plenary.nvim",
	},
	config = function()
		require("alpha").setup(require("alpha.themes.theta").config)
		-- custom text
		-- local alpha = require("alpha")
		-- local dashboard = require("alpha.themes.startify")
		-- dashboard.section.header.val = {
		-- 	[[]],
		-- }
		-- alpha.setup(dashboard.opts)
	end,
}

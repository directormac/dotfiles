vim.filetype.add({
	extension = {
		mdx = "markdown.mdx",
		postcss = "css",
		pcss = "css",
	},
})

vim.treesitter.language.register("markdown.mdx", "mdx")
vim.treesitter.language.register("css", "postcss")
vim.treesitter.language.register("css", "pcss")

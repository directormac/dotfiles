---@brief
--- Custom filetype detection rules and compound filetypes.
vim.filetype.add({
  extension = {
    mdx = 'markdown.mdx',
    kdl = 'kdl',
    ron = 'ron',
    rasi = 'rasi',
  },
  pattern = {
    ['docker%-compose.*%.ya?ml'] = 'yaml.docker-compose',
    ['compose.*%.ya?ml'] = 'yaml.docker-compose',
    ['%.gitlab%-ci%.ya?ml'] = 'yaml.gitlab',
    ['.*helm.*/values.*%.ya?ml'] = 'yaml.helm-values',
  },
})

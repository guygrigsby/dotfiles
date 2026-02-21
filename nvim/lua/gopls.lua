local lspconfig = require'lspconfig'
lspconfig.gopls.setup{
  on_attach = require'completion'.on_attach;
  settings = {
    gopls =  {
      env = {GOFLAGS="-tags=e2e smoke_test"}
    }
  }
}

include guile.am

DEPENDENCIES =    \
  lsp-server/geiser/utils.scm          \
  lsp-server/geiser/modules.scm        \
  lsp-server/geiser/completion.scm     \
  lsp-server/geiser/doc.scm            \
  lsp-server/geiser/evaluation.scm     \
  lsp-server/geiser/xref.scm

LIBRARY_DEFINITIONS = \
  lsp-server/private/util.sld  \
  lsp-server/private/guile.sld \
  lsp-server/private/diagnostics.sld \
  lsp-server/private/trie.sld       \
  lsp-server/private/compat.sld \
  lsp-server/private/document.sld   \
  lsp-server/private/parse.sld      \
  lsp-server/private/adapter.sld    \
  lsp-server/private/file.sld  \
  lsp-server.sld

SOURCES = \
  lsp-server-impl.scm    \
  lsp-server/private/util-impl.scm    \
  lsp-server/private/guile-impl.scm \
  lsp-server/private/diagnostics-impl.scm   \
  lsp-server/private/trie-impl.scm       \
  lsp-server/private/compat-guile-impl.scm \
  lsp-server/private/document-impl.scm   \
  lsp-server/private/parse-impl.scm      \
  lsp-server/private/adapter-impl.scm    \
  lsp-server/private/file-impl.scm    \
  lsp-server.scm

EXTRA_DIST =            \
  README.md             \
  bootstrap             \
  configure

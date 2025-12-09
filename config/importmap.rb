# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

# Ruby UI animation library
pin "tw-animate-css", to: "https://ga.jspm.io/npm:tw-animate-css@1.2.5/dist/tw-animate.js"
pin "motion", to: "https://cdn.jsdelivr.net/npm/motion@11.11.17/+esm"

pin "tippy.js", to: "https://cdn.jsdelivr.net/npm/tippy.js@6.3.7/+esm"
pin "@popperjs/core", to: "https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.8/+esm"

# Ruby UI component dependencies
pin "@floating-ui/dom", to: "https://cdn.jsdelivr.net/npm/@floating-ui/dom@1.6.12/+esm"
pin "@floating-ui/core", to: "https://cdn.jsdelivr.net/npm/@floating-ui/core@1.6.8/+esm"
pin "@floating-ui/utils", to: "https://cdn.jsdelivr.net/npm/@floating-ui/utils@0.2.8/+esm"
pin "@floating-ui/utils/dom", to: "https://cdn.jsdelivr.net/npm/@floating-ui/utils@0.2.8/dom/+esm"
pin "embla-carousel", to: "https://cdn.jsdelivr.net/npm/embla-carousel@8.5.1/+esm"
pin "mustache", to: "https://cdn.jsdelivr.net/npm/mustache@4.2.0/mustache.mjs"
pin "fuse.js", to: "https://cdn.jsdelivr.net/npm/fuse.js@7.0.0/dist/fuse.mjs"
pin "maska", to: "https://cdn.jsdelivr.net/npm/maska@3.0.4/dist/maska.js"


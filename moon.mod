name = "Luna-Flow/autodiff"

version = "0.2.0"

import {
  "Luna-Flow/luna-generic@0.3.3",
  "Luna-Flow/arithmetic@0.2.1",
  "Luna-Flow/linear-algebra@0.3.0",
  "Luna-Flow/luna-poly@0.2.0",
}

readme = "README.md"

repository = "https://github.com/Luna-Flow/autodiff"

license = "Apache-2.0"

keywords = [ "autodiff", "dual-numbers", "math" ]

description = "Forward-mode automatic differentiation over Luna Flow algebraic and arithmetic structures."

options(
  source: "src",
)

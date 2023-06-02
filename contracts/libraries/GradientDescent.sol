// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {Math} from "@morpho-utils/math/Math.sol";

/// @title Provides functions for maximizing a function given its gradient, according to the gradient descent algorithm.
library GradientDescent {
  function maximize(
    function(int256[] memory) returns (int256) fnc,
    function(int256[] memory) returns (int256[] memory) grad,
    int256[] memory x0
  ) internal returns (int256[] memory x, int256 fx) {
    uint256 dim = x0.length;

    x = new int256[](dim);
    for (uint256 i; i < dim; ++i) x[i] = x0[i];

    fx = fnc(x);

    int256 pfx = fx;
    for (uint256 i; i < 100; ++i) {
      int256[] memory g = grad(x);

      for (uint256 j; j < dim; ++j) x[j] += g[j];

      fx = fnc(x);

      if (Math.abs(pfx - fx) < 1e9 || fx == type(int256).max) break;

      pfx = fx;
    }
  }
}

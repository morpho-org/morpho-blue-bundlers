export const maximize = function (
  fnc: (args: number[]) => number,
  grd: (args: number[]) => number[],
  x0: number[],
  improvement = 1e-8
) {
  const dim = x0.length;

  let x = x0.slice();
  let fx = fnc(x);

  let pfx = fx;
  let best = { x, fx };

  let i = 0;
  for (; i < 10_000; ++i) {
    const g = grd(x);

    for (let j = 0; j < dim; j++) x[j] += g[j];

    fx = fnc(x);

    if (fx > pfx) best = { x: x.slice(), fx };

    if (Math.abs(pfx - fx) < improvement || isNaN(fx) || Math.abs(fx) >= Infinity) break;

    pfx = fx;
  }

  return {
    ...best,
    i,
  };
};

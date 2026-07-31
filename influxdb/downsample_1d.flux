option task = {name: "downsample_1d", every: 1d}

from(bucket: "solar/15m")
  |> range(start: -task.every)
  |> filter(fn: (r) => r._field != "yieldtotal" and r._field != "yieldday")
  |> aggregateWindow(every: 1d, fn: mean, createEmpty: false)
  |> to(bucket: "solar/1d", org: "Haldenweg")

from(bucket: "solar/15m")
  |> range(start: -task.every)
  |> filter(fn: (r) => r._field != "yieldtotal" and r._field != "yieldday")
  |> aggregateWindow(every: 1d, fn: max, createEmpty: false)
  |> map(fn: (r) => ({ r with _field: r._field + "_max" }))
  |> to(bucket: "solar/1d", org: "Haldenweg")

from(bucket: "solar/15m")
  |> range(start: -task.every)
  |> filter(fn: (r) => r._field != "yieldtotal" and r._field != "yieldday")
  |> aggregateWindow(every: 1d, fn: min, createEmpty: false)
  |> map(fn: (r) => ({ r with _field: r._field + "_min" }))
  |> to(bucket: "solar/1d", org: "Haldenweg")

from(bucket: "solar/15m")
  |> range(start: -task.every)
  |> filter(fn: (r) => r._field == "yieldtotal" or r._field == "yieldday")
  |> aggregateWindow(every: 1d, fn: max, createEmpty: false)
  |> to(bucket: "solar/1d", org: "Haldenweg")

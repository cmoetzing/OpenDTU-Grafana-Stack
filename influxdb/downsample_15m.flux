option task = {name: "downsample_15m", every: 15m}

from(bucket: "solar/actual")
  |> range(start: -task.every)
  |> filter(fn: (r) => r._field != "yieldtotal" and r._field != "yieldday")
  |> filter(fn: (r) => exists r._value and r._value > -999999.0 and r._value < 999999.0)
  |> aggregateWindow(every: 15m, fn: mean, createEmpty: false)
  |> to(bucket: "solar/15m", org: "Haldenweg")

from(bucket: "solar/actual")
  |> range(start: -task.every)
  |> filter(fn: (r) => r._field == "yieldtotal" or r._field == "yieldday")
  |> aggregateWindow(every: 15m, fn: max, createEmpty: false)
  |> to(bucket: "solar/15m", org: "Haldenweg")

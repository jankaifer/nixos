#!/usr/bin/env nix-shell
/*
#! nix-shell -p bun -i bun
*/

const vmUrl = Bun.argv[2];

const data = JSON.parse(await Bun.stdin.text())
console.log("We got the following data from speed test:")
console.log(data)
console.log()

const serializeTest = (testData) => ["min", "q1", "median", "q3", "max", "avg"]
  .map(percentile => `cf_speed_test_${testData.test_type.toLowerCase()}_${percentile}{payload_size="${testData.payload_size}"} ${testData[percentile]}`)
  .join("\n")
const metrics = data.map(serializeTest).join("\n")

console.log("Uploading to ", vmUrl)
console.log("Metrics being uploaded:")
console.log(metrics)
console.log()

await fetch(vmUrl, {
    method: 'POST',
    headers: {
        'Content-Type': 'text/plain'
    },
    body: metrics.trim(),
})

console.log("Done")
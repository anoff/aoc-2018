const fs = require('fs')

const input = fs.readFileSync('test.txt', 'utf-8')
const shifts = generateShifts(input)

function generateShifts (input) {
  let currentShift = {}
  let fellAsleep = 0
  const shifts = input.split('\n')
    .reduce((p, c) => {
      const guardId = extractShiftStart(c) // -1 if no shift change
      if (guardId > -1) {
        if (currentShift.guard > 0) p.push(currentShift) // do not push initial guard change
        currentShift = { guard: guardId, asleep: [] }
      }

      if (c.includes('falls asleep')) {
        const min = extractMinute(c)
        const date = extractDate(c)
        currentShift.date = date
        fellAsleep = min
      } else if (c.includes('wakes up')) {
        const min = extractMinute(c)
        const date = extractDate(c)
        for (let i = fellAsleep; i < min; i++) {
          currentShift.asleep.push(i)
        }
        currentShift.date = date
      }
      return p
    }, [])
  shifts.push(currentShift) // add last shift manually because no guard change is detected
  return shifts
}

// return guard ID
function extractShiftStart (line) {
  const match = /.*Guard #([0-9]+) begins shift/.exec(line)
  if (match) {
    return parseInt(match[1])
  } else {
    return -1
  }
}

function extractMinute (line) {
  const match = /^\[[0-9-]+ [0-9]{1,2}:([0-9]{1,2})\].*/.exec(line)
  if (match) {
    return parseInt(match[1])
  } else {
    return -1
  }
}

function extractDate (line) {
  const match = /^\[[0-9]{4}-([0-9]{1,2}-[0-9]{1,2}) [0-9]{1,2}:[0-9]{1,2}\].*/.exec(line)
  if (match) {
    return match[1]
  } else {
    return -1
  }
}
function solution1 () {

}

module.exports = {
  generateShifts,
  extractShiftStart,
  extractMinute,
  extractDate
}

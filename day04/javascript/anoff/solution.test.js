import test from 'ava'
import fs from 'fs'
import * as s from './solution'

const testData = fs.readFileSync('test.txt', 'utf-8')

test('extractShiftStart can parse shift start', t => {
  const guard = s.extractShiftStart('[1518-11-04 00:02] Guard #99 begins shift')
  t.is(guard, 99)
})

test('extractShiftStart should return -1 for invalid shift start', t => {
  const guard = s.extractShiftStart('asdfadsf 2345 asdfasdfasdf')
  t.is(guard, -1)
})

test('extractMinute should extract correct minute value', t => {
  t.is(s.extractMinute('[1518-11-04 00:02] xyz'), 2)
  t.is(s.extractMinute('[1518-11-04 00:42] asdf asdf asd fasdf'), 42)
})

test('extractDate should extract correct value', t => {
  t.is(s.extractDate('[1518-11-04 00:02] xyz'), '11-04')
  t.is(s.extractDate('[1518-2-05 00:42] asdf asdf asd fasdf'), '2-05')
})

test('generateShifts creates the correct number of shifts', t => {
  const shifts = s.generateShifts(testData)
  t.is(shifts.length, 5)
})

test('generateShifts parses example shift correctly', t => {
  const shifts = s.generateShifts(testData)
  const shift = shifts.find(elm => elm.date === '11-03' && elm.guard === 99)
  t.deepEqual(shift.asleep, [24, 25, 26, 27, 28])
})

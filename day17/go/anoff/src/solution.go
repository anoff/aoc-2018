package main

import (
	"fmt"
	"strings"
	"strconv"
	"math"
)
type coord struct {
	x, y int
}
type ground struct {
	lines [][]string
}
func (g *ground) print() {
	for _, line := range g.lines {
		fmt.Println(strings.Join(line, ""))
	}
}
func (g *ground) isFlooding(p coord) bool {
	x := p.x
	y := p.y
	if g.lines[y][x] == "." {
		if y > 0 {
			above := g.lines[y-1][x]
			if above == "+" || above == "|" {
				return true
			}
		}
		if x > 0 {
			left := g.lines[y][x-1]
			if left == "~" || (left == "|" && y+1 < len(g.lines) && (g.lines[y+1][x] == "#" || g.lines[y+1][x] == "~")) {
				return true
			}
		}
		if x + 1 < len(g.lines[0]) - 1 {
			right := g.lines[y][x+1]
			if right == "~" {
				return true
			}
		}
	}
	return false
}
func (g *ground) tick() {
	for y := len(g.lines) - 1; y > 0; y-- {
		for x := 0; x < len(g.lines[0]); x++ {
			if g.isFlooding(coord{x,y}) {
				g.lines[y][x] = "|"
			}
		}
	}
}
func main() {
	input := readInput("../test.txt")
	g := generateMap(input)
	for {
		fmt.Print("\u001b[2J\u001b[H") // clear screen
		g.tick()
		g.print()
		fmt.Scanln()
	}
}

func part1(lines []string) {
	fmt.Println("Solution for part1:", 0)
}

func generateMap(readings []string) ground {
	clay := make(map[coord]bool)
	for _, reading := range readings {
		// x=501, y=3..7
		xy := strings.Split(reading, ", ")
		n23 := strings.Split(xy[1][2:], "..")
		n1, _ := strconv.Atoi(xy[0][2:])
		n2, _ := strconv.Atoi(n23[0])
		n3, _ := strconv.Atoi(n23[1])
		if xy[0][0] == 'x' {
			// x=n1, y=n2..n3
			for y := n2; y <= n3; y++ {
				clay[coord{n1,y}] = true
			}
		} else {
			// y=n1, x=n2..n3
			for x := n2; x <= n3; x++ {
				clay[coord{x,n1}] = true
			}
		}
	}
	min := coord{math.MaxInt32, 0}
	max := coord{}
	for c := range clay {
		if c.x < min.x {
			min.x = c.x
		} else if c.x > max.x {
			max.x = c.x
		}
		if c.y < min.y {
			min.y = c.y
		} else if c.y > max.y {
			max.y = c.y
		}
	}
				
	// generate ground map
	var g ground
	for y := min.y; y <= max.y; y++ {
		var l string
		for x := min.x; x <= max.x; x++ {
			if _, hasClay := clay[coord{x, y}]; hasClay {
				l += "#"
			} else if y == 0 && x == 500 {
				l += "+"
			} else {
				l += "."
			}
		}
		g.lines = append(g.lines, strings.Split(l, ""))
	}
	fmt.Println(min, max)
	return g
}
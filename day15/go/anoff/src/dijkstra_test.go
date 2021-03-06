package main
import (
	"testing"
	"fmt"
)

func TestGrid(t *testing.T) {
	var g grid
	tables := []struct{
		x int
		y int
	}{
		{0, 1},
		{1, 1},
		{0, 0},
		{0, 2},
		{1, 2},
	}
	for _, t := range tables {
		n := newNode(Position{t.x, t.y})
		g.addNode(&n)
	}
	g.nodes[3].distance = 12
	shortN := g.getShortest()
	if shortN.distance != 12 {
		t.Error("Wrong node with shortest distance returned")
	}
	n := newNode(Position{1, 1})
	ns := g.getNeighbors(&n)
	if len(ns) != 2 {
		t.Error("Wrong number of neighbors in grid")
	}
	for _, n := range ns {
		if !n.pos.IsEqual(Position{1, 2}) && !n.pos.IsEqual(Position{0, 1}) {
			t.Error("Invalid neighbor returned")
		}
	}
}

func TestGridRemove(t *testing.T) {
	var g grid
	tables := []struct{
		x int
		y int
	}{
		{0, 1},
		{1, 1},
		{0, 0},
		{0, 2},
		{1, 2},
	}
	for _, t := range tables {
		n := newNode(Position{t.x, t.y})
		g.addNode(&n)
	}
	n := newNode(Position{2, 2})
	g.remove(&n) // should not throw error :shrug:
	if len(g.nodes) != 5 {
		t.Error("Node has been removed Oo")
	}
	n = newNode(Position{0, 2})
	g.remove(&n)
	if len(g.nodes) != 4 {
		t.Error("Node has not been removed :(")
	}
}

func TestDijkstra2DUnobstructed(t *testing.T) {
	var walkable []Position
	for x := 0; x < 10; x++ {
		for y := 0; y < 10; y++ {
			walkable = append(walkable, Position{x, y})
		}
	}
	_, path := Dijkstra2D(walkable, Position{0, 0}, Position{1, 3})
	if len(path) != 4 {
		t.Error("Wrong path length for unobstructed path")
	}
	_, path = Dijkstra2D(walkable, Position{3, 3}, Position{0, 0})
	if path[0].x != 3 || path[1].x != 3 || path[2].x != 3 {
		t.Error("Does not respect reading direction prio, up first", path)
	}

	_, path = Dijkstra2D(walkable, Position{5, 5}, Position{2, 2})
	if path[0].x != 5 || path[1].x != 5 || path[2].x != 5 {
		t.Error("Does not respect reading direction prio, should walk towards 0,0 (y first)", path)
	}
}

func TestDijkstra2DObstructed(t *testing.T) {
	var walkable []Position
	for x := 0; x < 10; x++ {
		for y := 0; y < 10; y++ {
			if y != 0 || x < 2 || x > 5 {
				walkable = append(walkable, Position{x, y})
			}
		}
	}
	/*
	..XXXX....
	..........
	*/
	_, path := Dijkstra2D(walkable, Position{0, 0}, Position{8, 0})
	if len(path) != 10 {
		t.Error("Wrong path length for obstructed path", path)
	}
}

func testDummy() {
	fmt.Println("")
}

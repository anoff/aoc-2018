package main

import (
)

type Path struct {
	sequence string // the NWSE sequence string
	ix int // current step in the sequence
	pos Position // position in the room
	room *Room
}

func NewPath(sequence string, r *Room) Path {
	var p Path
	p.sequence = sequence
	p.room = r
	p.pos = r.origin
	return p
}
// return true while more steps can be made
func (p *Path) step() bool {
	// helper to expand the room if necessary
	// 	also adjust the target position if they are affected
	expandToReach := func (dest Position, intermediate Position) (Position, Position) {
		xdim, ydim := p.room.dim()
		if dest.x <= 0 {
			p.room.expand(-1, 0)
			dest.x = 1
			intermediate.x = 2
		} else if dest.y <= 0 {
			p.room.expand(0, -1)
			dest.y = 1
			intermediate.y = 2
		} else if dest.x > xdim-1 {
			p.room.expand(1, 0)
		} else if dest.y > ydim-1 {
			p.room.expand(0, 1)
		}
		return dest, intermediate
	}
	step := p.sequence[p.ix]
	intermediate := p.pos
	dest := p.pos
	switch step {
		// always step twice to reach an actual room and not the doors
		case 'N':
			dest.y -= 2
			intermediate.y--
		case 'E':
			dest.x += 2
			intermediate.x++
		case 'S':
			dest.y += 2
			intermediate.y++
		case 'W':
			dest.x -= 2
			intermediate.x--
	}
	dest, intermediate = expandToReach(dest, intermediate)
	if p.room.isWall(dest) || p.room.isWall(intermediate) {
		panic("Did not expect to hit a wall")
	}
	// mark the path as discovered
	p.room.markDoor(intermediate)
	p.pos = dest
	p.ix++
	if p.ix >= len(p.sequence) {
		return false
	}
	return true
}

func (p *Path) walk() *Path {
	for {
		notEnded := p.step()
		if !notEnded {
			break
		}
	}
	return p
}
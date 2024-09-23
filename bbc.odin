package bbc

import "core:fmt"

board_square :: enum i32 {
	a8,
	B8,
	c8,
	d8,
	e8,
	f8,
	g8,
	h8,
	a7,
	b7,
	c7,
	d7,
	e7,
	f7,
	g7,
	h7,
	a6,
	b6,
	c6,
	d6,
	e6,
	f6,
	g6,
	h6,
	a5,
	b5,
	c5,
	d5,
	e5,
	f5,
	g5,
	h5,
	a4,
	b4,
	c4,
	d4,
	e4,
	f4,
	g4,
	h4,
	a3,
	b3,
	c3,
	d3,
	e3,
	f3,
	g3,
	h3,
	a2,
	b2,
	c2,
	d2,
	e2,
	f2,
	g2,
	h2,
	a1,
	b1,
	c1,
	d1,
	e1,
	f1,
	g1,
	h1,
	no_sq,
}

get_square :: proc(square: board_square) -> i32 {
	return i32(square)
}

// C ENUM COLORS
white :: 0
black :: 1
both :: 2
// C ENUM PIECE
rook :: 0
bishop :: 1
// C ENUM PIEC
P :: 0
N :: 1
B :: 2
R :: 3
Q :: 4
K :: 5
p :: 6
n :: 7
b :: 8
r :: 9
q :: 10
k :: 11

// CASTLE STATE
wk: i32 : 0b0001 // white king can castle to the king side
wq: i32 : 0b0010 // white king can castle to the queen side
bk: i32 : 0b0100 // black king can castle to the king side
bq: i32 : 0b1000 // black king can castle to the queen side

// PIECES Up Case WHITE, Lower Case BLACK
piece :: enum i32 {
	P,
	N,
	B,
	R,
	Q,
	K,
	p,
	n,
	b,
	r,
	q,
	k,
}


unicode_pieces: [12]string = {
	"♙",
	"♘",
	"♗",
	"♖",
	"♕",
	"♔",
	"♟︎",
	"♞",
	"♝",
	"♜",
	"♛",
	"♚",
}
// USAR: fmt.printf("piece: %s\n", unicode_pieces[piece.P] ) // ♙

square_to_coordinates: []string = {
	"a8",
	"b8",
	"c8",
	"d8",
	"e8",
	"f8",
	"g8",
	"h8",
	"a7",
	"b7",
	"c7",
	"d7",
	"e7",
	"f7",
	"g7",
	"h7",
	"a6",
	"b6",
	"c6",
	"d6",
	"e6",
	"f6",
	"g6",
	"h6",
	"a5",
	"b5",
	"c5",
	"d5",
	"e5",
	"f5",
	"g5",
	"h5",
	"a4",
	"b4",
	"c4",
	"d4",
	"e4",
	"f4",
	"g4",
	"h4",
	"a3",
	"b3",
	"c3",
	"d3",
	"e3",
	"f3",
	"g3",
	"h3",
	"a2",
	"b2",
	"c2",
	"d2",
	"e2",
	"f2",
	"g2",
	"h2",
	"a1",
	"b1",
	"c1",
	"d1",
	"e1",
	"f1",
	"g1",
	"h1",
}

get_bit :: proc(bitboard: u64, square: i32) -> bool {
	return (bitboard & (1 << u32(square))) > 0
}

set_bit :: proc(bitboard: ^u64, square: i32) {
	bitboard^ |= (1 << u32(square))
}

pop_bit :: proc(bitboard: ^u64, square: i32) {
	if get_bit(bitboard^, square) {
		bitboard^ ~= (1 << u32(square))
	}
}

count_bits :: proc(bitboard: u64) -> i32 {
	count: i32
	bb := bitboard

	for bb > 0 {
		count += 1
		bb &= bb - 1
	}
	return count
}

get_ls1b_index :: proc(bitboard: u64) -> i32 {
	if bitboard == 0 {return -1}
	return count_bits((bitboard & -bitboard) - 1)
}

// Attacks
not_a_file: u64 : 18374403900871474942
not_h_file: u64 : 9187201950435737471
not_hg_file: u64 : 4557430888798830399
not_ab_file: u64 : 18229723555195321596

bishop_relevant_bits: [64]i32 = {
	6,
	5,
	5,
	5,
	5,
	5,
	5,
	6,
	5,
	5,
	5,
	5,
	5,
	5,
	5,
	5,
	5,
	5,
	7,
	7,
	7,
	7,
	5,
	5,
	5,
	5,
	7,
	9,
	9,
	7,
	5,
	5,
	5,
	5,
	7,
	9,
	9,
	7,
	5,
	5,
	5,
	5,
	7,
	7,
	7,
	7,
	5,
	5,
	5,
	5,
	5,
	5,
	5,
	5,
	5,
	5,
	6,
	5,
	5,
	5,
	5,
	5,
	5,
	6,
}

rook_relevant_bits: [64]i32 = {
	12,
	11,
	11,
	11,
	11,
	11,
	11,
	12,
	11,
	10,
	10,
	10,
	10,
	10,
	10,
	11,
	11,
	10,
	10,
	10,
	10,
	10,
	10,
	11,
	11,
	10,
	10,
	10,
	10,
	10,
	10,
	11,
	11,
	10,
	10,
	10,
	10,
	10,
	10,
	11,
	11,
	10,
	10,
	10,
	10,
	10,
	10,
	11,
	11,
	10,
	10,
	10,
	10,
	10,
	10,
	11,
	12,
	11,
	11,
	11,
	11,
	11,
	11,
	12,
}

// ATTACKS VARIABLES
pawn_attacks: [2][64]u64
knight_attacks: [64]u64
king_attacks: [64]u64

bishop_masks: [64]u64
bishop_attacks: [64][512]u64

rook_masks: [64]u64
rook_attacks: [64][4096]u64

mask_pawn_attacks :: proc(side: i32, square: i32) -> u64 {
	attacks, bitboard: u64
	set_bit(&bitboard, square)

	if (side == white) {
		if ((bitboard >> 7) & not_a_file) != 0 {attacks |= (bitboard >> 7)}
		if ((bitboard >> 9) & not_h_file) != 0 {attacks |= (bitboard >> 9)}
	} else {
		if ((bitboard << 7) & not_h_file) != 0 {attacks |= (bitboard << 7)}
		if ((bitboard << 9) & not_a_file) != 0 {attacks |= (bitboard << 9)}
	}

	return attacks
}

mask_knight_attacks :: proc(square: i32) -> u64 {
	attacks, bitboard: u64
	set_bit(&bitboard, square)

	if ((bitboard >> 17) & not_h_file) != 0 {attacks |= (bitboard >> 17)}
	if ((bitboard >> 15) & not_a_file) != 0 {attacks |= (bitboard >> 15)}
	if ((bitboard >> 10) & not_hg_file) != 0 {attacks |= (bitboard >> 10)}
	if ((bitboard >> 6) & not_ab_file) != 0 {attacks |= (bitboard >> 6)}

	if ((bitboard << 17) & not_a_file) != 0 {attacks |= (bitboard << 17)}
	if ((bitboard << 15) & not_h_file) != 0 {attacks |= (bitboard << 15)}
	if ((bitboard << 10) & not_ab_file) != 0 {attacks |= (bitboard << 10)}
	if ((bitboard << 6) & not_hg_file) != 0 {attacks |= (bitboard << 6)}

	return attacks
}

mask_king_attacks :: proc(square: i32) -> u64 {
	attacks, bitboard: u64
	set_bit(&bitboard, square)

	if (bitboard >> 8) != 0 {attacks |= (bitboard >> 8)}
	if ((bitboard >> 9) & not_h_file) != 0 {attacks |= (bitboard >> 9)}
	if ((bitboard >> 7) & not_a_file) != 0 {attacks |= (bitboard >> 7)}
	if ((bitboard >> 1) & not_h_file) != 0 {attacks |= (bitboard >> 1)}

	if (bitboard << 8) != 0 {attacks |= (bitboard << 8)}
	if ((bitboard << 9) & not_a_file) != 0 {attacks |= (bitboard << 9)}
	if ((bitboard << 7) & not_h_file) != 0 {attacks |= (bitboard << 7)}
	if ((bitboard << 1) & not_a_file) != 0 {attacks |= (bitboard << 1)}

	return attacks
}

mask_bishop_attacks :: proc(square: i32) -> u64 {
	attacks: u64

	tr := square / 8
	tf := square % 8

	r := tr + 1;f := tf + 1
	for ; r <= 6 && f <= 6; f += 1 {
		attacks |= (1 << u64(r * 8 + f))
		r += 1
	}

	r = tr - 1;f = tf + 1
	for ; r >= 1 && f <= 6; f += 1 {
		attacks |= (1 << u64(r * 8 + f))
		r -= 1
	}

	r = tr + 1;f = tf - 1
	for ; r <= 6 && f >= 1; f -= 1 {
		attacks |= (1 << u64(r * 8 + f))
		r += 1
	}

	r = tr - 1;f = tf - 1
	for ; r >= 1 && f >= 1; f -= 1 {
		attacks |= (1 << u64(r * 8 + f))
		r -= 1
	}
	return attacks
}

bishop_attacks_on_the_fly :: proc(square: i32, block: u64) -> u64 {
	attacks: u64

	tr := square / 8
	tf := square % 8

	//for r,f := tr +1,tf+1 ; r <= 7 && f <= 7 ; r,f = r+1, f+1 {}
	r := tr + 1;f := tf + 1
	for ; r <= 7 && f <= 7; f += 1 {
		attacks |= (1 << u64(r * 8 + f))
		if ((1 << u64(r * 8 + f)) & block) > 0 {break}
		r += 1
	}

	r = tr - 1;f = tf + 1
	for ; r >= 0 && f <= 7; f += 1 {
		attacks |= (1 << u64(r * 8 + f))
		if ((1 << u64(r * 8 + f)) & block) > 0 {break}
		r -= 1
	}

	r = tr + 1;f = tf - 1
	for ; r <= 7 && f >= 0; f -= 1 {
		attacks |= (1 << u64(r * 8 + f))
		if ((1 << u64(r * 8 + f)) & block) > 0 {break}
		r += 1
	}

	r = tr - 1;f = tf - 1
	for ; r >= 0 && f >= 0; f -= 1 {
		attacks |= (1 << u64(r * 8 + f))
		if ((1 << u64(r * 8 + f)) & block) > 0 {break}
		r -= 1
	}

	return attacks
}

mask_rook_attacks :: proc(square: i32) -> u64 {
	attacks: u64

	tr := square / 8
	tf := square % 8

	for r := tr + 1; r <= 6; r += 1 {attacks |= 1 << u64(r * 8 + tf)}
	for r := tr - 1; r >= 1; r -= 1 {attacks |= 1 << u64(r * 8 + tf)}
	for f := tf + 1; f <= 6; f += 1 {attacks |= 1 << u64(tr * 8 + f)}
	for f := tf - 1; f >= 1; f -= 1 {attacks |= 1 << u64(tr * 8 + f)}

	return attacks
}

rook_attacks_on_the_fly :: proc(square: i32, block: u64) -> u64 {
	attacks: u64

	tr := square / 8
	tf := square % 8

	for r := tr + 1; r <= 7; r += 1 {
		attacks |= 1 << u64(r * 8 + tf)
		if ((1 << u64(r * 8 + tf)) & block) > 0 {break}
	}
	for r := tr - 1; r >= 0; r -= 1 {
		attacks |= 1 << u64(r * 8 + tf)
		if ((1 << u64(r * 8 + tf)) & block) > 0 {break}
	}
	for f := tf + 1; f <= 7; f += 1 {
		attacks |= 1 << u64(tr * 8 + f)
		if ((1 << u64(tr * 8 + f)) & block) > 0 {break}
	}
	for f := tf - 1; f >= 0; f -= 1 {
		attacks |= 1 << u64(tr * 8 + f)
		if ((1 << u64(tr * 8 + f)) & block) > 0 {break}
	}
	return attacks
}

init_leapers_attacks :: proc() {
	for square in 0 ..< 64 {
		pawn_attacks[white][square] = mask_pawn_attacks(white, i32(square))
		pawn_attacks[black][square] = mask_pawn_attacks(black, i32(square))
		knight_attacks[square] = mask_knight_attacks(i32(square))
		king_attacks[square] = mask_king_attacks(i32(square))
	}
}

// print bitboard
print_bitboard :: proc(bitboard: u64) {
	for rank in 0 ..< 8 {
		for file in 0 ..< 8 {
			// convert file & rank into square index
			square := rank * 8 + file

			if file == 0 {
				fmt.printf("  %v ", 8 - rank)
			}

			fmt.printf(" %v", get_bit(bitboard, i32(square)) ? 1 : 0)
		}
		fmt.println()
	}
	fmt.print("\n     a b c d e f g h\n")
	fmt.printf("\n     Bitboard: %v\n\n", bitboard)
}

print_board :: proc() {
	fmt.println()
	for rank in 0 ..< 8 {
		for file in 0 ..< 8 {
			square := rank * 8 + file

			if file == 0 {
				fmt.printf("  %v ", 8 - rank)
			}

			piece := -1
			for bb_piece in 0 ..< 12 {
				if get_bit(bitboards[bb_piece], i32(square)) {
					piece = bb_piece
				}
			}

			fmt.printf(" %s", piece == -1 ? "." : unicode_pieces[piece])
		}
		fmt.println()
	}
	fmt.print("\n     a b c d e f g h\n\n")
	fmt.printf("      Side: %s\n", side == white ? "white" : "black")
	fmt.printf(
		" Enpassant: %s\n",
		enpassant != get_square(.no_sq) ? square_to_coordinates[enpassant] : "no",
	)
	fmt.printf(
		"  Castling: %c%c%c%c\n\n",
		castle & wk > 0 ? 'K' : '-',
		castle & wq > 0 ? 'Q' : '-',
		castle & bk > 0 ? 'k' : '-',
		castle & bq > 0 ? 'q' : '-',
	)
}

set_occupancy :: proc(index, bits_in_mask: i32, attack_mask: u64) -> u64 {
	occupancy: u64
	am := attack_mask

	for count in 0 ..< bits_in_mask {
		square := get_ls1b_index(am)
		pop_bit(&am, square)
		if index & (1 << u32(count)) > 0 {
			occupancy |= (1 << u32(square))
		}
	}

	return occupancy
}

init_sliders_attacks :: proc(piece: i32) {
	for square in 0 ..< 64 {
		bishop_masks[square] = mask_bishop_attacks(i32(square))
		rook_masks[square] = mask_rook_attacks(i32(square))

		attack_mask := piece == bishop ? bishop_masks[square] : rook_masks[square]
		relevant_bits_count := count_bits(attack_mask)

		occupancy_indicies := 1 << u32(relevant_bits_count)

		for index in 0 ..< occupancy_indicies {
			if piece == bishop {
				occupancy := set_occupancy(i32(index), relevant_bits_count, attack_mask)
				magic_index :=
					(occupancy * bishop_magic_numbers[square]) >>
					u32(64 - bishop_relevant_bits[square])
				bishop_attacks[square][magic_index] = bishop_attacks_on_the_fly(
					i32(square),
					occupancy,
				)
			} else {
				occupancy := set_occupancy(i32(index), relevant_bits_count, attack_mask)
				magic_index :=
					(occupancy * rook_magic_numbers[square]) >>
					u32(64 - rook_relevant_bits[square])
				rook_attacks[square][magic_index] = rook_attacks_on_the_fly(i32(square), occupancy)

			}
		}
	}
}

get_bishop_attacks :: proc(square: i32, occupancy: u64) -> u64 {
	o := occupancy
	o &= bishop_masks[square]
	o *= bishop_magic_numbers[square]
	o >>= 64 - u32(bishop_relevant_bits[square])

	return bishop_attacks[square][o]
}

get_rook_attacks :: proc(square: i32, occupancy: u64) -> u64 {
	o := occupancy
	o &= rook_masks[square]
	o *= rook_magic_numbers[square]
	o >>= (64 - u32(rook_relevant_bits[square]))

	return rook_attacks[square][o]
}

get_queen_attacks :: proc(square: i32, occupancy: u64) -> u64 {

	bishop_occupancy := occupancy
	bishop_occupancy &= bishop_masks[square]
	bishop_occupancy *= bishop_magic_numbers[square]
	bishop_occupancy >>= (64 - u32(bishop_relevant_bits[square]))
	queen_attacks := bishop_attacks[square][bishop_occupancy]

	rook_occupancy := occupancy
	rook_occupancy &= rook_masks[square]
	rook_occupancy *= rook_magic_numbers[square]
	rook_occupancy >>= (64 - u32(rook_relevant_bits[square]))
	queen_attacks |= rook_attacks[square][rook_occupancy]

	return queen_attacks
}

is_square_attacked :: proc(square, side: i32) -> i32 {
	// attacked by white pawns
	if (side == white) && (pawn_attacks[black][square] & bitboards[piece.P] > 0) {return 1}

	// attacked by black pawns
	if (side == black) && (pawn_attacks[white][square] & bitboards[piece.p] > 0) {return 1}

	// attacked by knight
	if (knight_attacks[square] & ((side == white) ? bitboards[piece.N] : bitboards[piece.n])) >
	   0 {return 1}

	// attacked by bishop
	if (get_bishop_attacks(square, occupancies[both]) &
		   (side == white ? bitboards[piece.B] : bitboards[piece.b])) >
	   0 {return 1}

	// attacked by rook
	if (get_rook_attacks(square, occupancies[both]) &
		   (side == white ? bitboards[piece.R] : bitboards[piece.r])) >
	   0 {return 1}

	// attacked by queen
	if (get_queen_attacks(square, occupancies[both]) &
		   (side == white ? bitboards[piece.Q] : bitboards[piece.q])) >
	   0 {return 1}


	// attack by king
	if (king_attacks[square] & ((side == white) ? bitboards[piece.K] : bitboards[piece.k])) >
	   0 {return 1}

	return 0
}

print_attacked_squares :: proc(side: i32) {
	for rank in 0 ..< 8 {
		for file in 0 ..< 8 {
			square := rank * 8 + file
			if file == 0 {
				fmt.printf("  %d ", 8 - rank)
			}
			fmt.printf(" %c", is_square_attacked(i32(square), side) > 0 ? '*' : '.')
		}
		fmt.println()
	}
	fmt.print("\n     a b c d e f g h\n\n")
}

init_all :: proc() {
	init_leapers_attacks()
	init_sliders_attacks(bishop)
	init_sliders_attacks(rook)
	init_promoted_pieces()
}

// DEFINE BITBOARDS (GAME STRUCT?)
bitboards: [12]u64
occupancies: [3]u64
side: i32
enpassant: i32 = get_square(.no_sq)
castle: i32

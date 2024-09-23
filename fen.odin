package bbc

import "core:fmt"

// FEN debug positions
empty_board :: "8/8/8/8/8/8/8/8 w - - "
start_position :: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1 "
tricky_position :: "r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 1 "
killer_position :: "rnbqkb1r/pp1p1pPp/8/2p1pP2/1P1P4/3P3P/P1P1P3/RNBQKBNR w KQkq e6 0 1"
cmk_position :: "r2q1rk1/ppp2ppp/2n1bn2/2b1p3/3pP3/3P1NPP/PPP1NPB1/R1BQ1RK1 b - - 0 9 "

// piece :: enum i32 { P,N,B,R,Q,K,p,n,b,r,q,k }
char_pieces: map[u8]piece = {
	'P' = piece.P,
	'N' = piece.N,
	'B' = piece.B,
	'R' = piece.R,
	'Q' = piece.Q,
	'K' = piece.K,
	'p' = piece.p,
	'n' = piece.n,
	'b' = piece.b,
	'r' = piece.r,
	'q' = piece.q,
	'k' = piece.k,
}

parse_fen :: proc(fen: string) {
	// RESET boards
	bitboards = {}
	occupancies = {}
	side = 0
	enpassant = get_square(.no_sq)
	castle = 0

	index := 0
	fen_str := transmute([]u8)fen
	fen_char := fen_str[index]

	for rank in 0 ..< 8 {
		for file := 0; file < 8; file += 1 {
			square := rank * 8 + file

			// match pieces
			if (fen_char >= 'a' && fen_char <= 'z') || (fen_char >= 'A' && fen_char <= 'Z') {
				piece := char_pieces[fen_char]
				set_bit(&bitboards[piece], i32(square))

				index += 1
				fen_char = fen_str[index]
			}

			// match empty square number
			if fen_char >= '0' && fen_char <= '9' {
				offset := fen_char - '0'

				piece := -1
				for bb_piece in 0 ..< 12 {
					if get_bit(bitboards[bb_piece], i32(square)) {
						piece = bb_piece
					}
				}
				if piece == -1 {
					file -= 1
				}

				file += int(offset)

				index += 1
				fen_char = fen_str[index]
			}

			// match rank separator
			if fen_char == '/' {
				index += 1
				fen_char = fen_str[index]
			}
		}
	}

	// skip space
	index += 1
	fen_char = fen_str[index]

	// parse side
	if fen_char == 'w' {
		side = white
	} else {
		side = black
	}
	//skip side and space
	index += 2
	fen_char = fen_str[index]

	for fen_char != ' ' {
		switch fen_char {
		case 'K':
			castle |= wk
		case 'Q':
			castle |= wq
		case 'k':
			castle |= bk
		case 'q':
			castle |= bq
		case '-':
		}
		index += 1
		fen_char = fen_str[index]
	}

	// skip space
	index += 1
	fen_char = fen_str[index]

	if fen_char != '-' {
		file := fen_char - 'a'
		rank := 8 - (fen_str[index + 1] - '0')

		enpassant = i32(rank * 8 + file)
	}

	// white pieces
	for piece in 0 ..< 6 {
		occupancies[white] |= bitboards[piece]
	}

	// black pieces
	for piece in 6 ..< 12 {
		occupancies[black] |= bitboards[piece]
	}

	occupancies[both] |= occupancies[white]
	occupancies[both] |= occupancies[black]
	//fmt.printf("fen: '%s'\n\n\n", fen_str[index:])
}

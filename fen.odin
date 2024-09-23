package bbc

import "core:fmt"

// piece :: enum i32 { P,N,B,R,Q,K,p,n,b,r,q,k }
char_pieces: map[u8]Piece = {
	'P' = Piece.P,
	'N' = Piece.N,
	'B' = Piece.B,
	'R' = Piece.R,
	'Q' = Piece.Q,
	'K' = Piece.K,
	'p' = Piece.p,
	'n' = Piece.n,
	'b' = Piece.b,
	'r' = Piece.r,
	'q' = Piece.q,
	'k' = Piece.k,
}

parse_fen :: proc(fen: string) {
	// RESET boards
	bitboards = {}
	occupancies = {}
	side = 0
	enpassant = i32(board_square.no_sq)
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
	} else {
		enpassant = i32(board_square.no_sq)
	}

	// white pieces
	for piece in i32(Piece.P) ..= i32(Piece.K) {
		occupancies[white] |= bitboards[piece]
	}

	// black pieces
	for piece in i32(Piece.p) ..= i32(Piece.k) {
		occupancies[black] |= bitboards[piece]
	}

	occupancies[both] |= occupancies[white]
	occupancies[both] |= occupancies[black]
	//fmt.printf("fen: '%s'\n\n\n", fen_str[index:])
}

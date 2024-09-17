package bbc

import "core:fmt"

// Move Generation

generate_moves :: proc() {
    source_square, target_square : i32
    bitboard, attacks : u64

    for piece in 0..<12 {
        bitboard = bitboards[piece]
        
        // pawns and king castling
        if side == white {

        } else {

        }

        // knight
        // bishop
        // rook
        // queen
        // king
    }
}
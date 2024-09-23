package bbc

import "core:fmt"

// DEFINE BITBOARDS (GAME STRUCT?)
bitboards: [12]u64
occupancies: [3]u64
side: i32
enpassant: i32 = i32(board_square.no_sq)
castle: i32

// COPY BITBOARDS 
bitboards_copy : [12]u64
occupancies_copy : [3]u64
side_copy : i32
enpassant_copy : i32
castle_copy : i32

copy_board :: proc() {
    bitboards_copy = bitboards
    occupancies_copy = occupancies
    side_copy = side
    enpassant_copy = enpassant
    castle_copy = castle
}

take_back :: proc() {
    bitboards = bitboards_copy
    occupancies = occupancies_copy
    side = side_copy
    enpassant = enpassant_copy
    castle = castle_copy
}
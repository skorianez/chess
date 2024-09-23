package bbc

import "core:fmt"

/*
0000 0000 0000 0000 0011 1111 - source square    - 0x00_003f
0000 0000 0000 1111 1100 0000 - target square    - 0x00_0fc0
0000 0000 1111 0000 0000 0000 - piece            - 0x00_f000
0000 1111 0000 0000 0000 0000 - promoted piece   - 0x0f_0000
0001 0000 0000 0000 0000 0000 - capture flag     - 0x10_0000
0010 0000 0000 0000 0000 0000 - double push flag - 0x20_0000
0100 0000 0000 0000 0000 0000 - enpassant flag   - 0x40_0000
1000 0000 0000 0000 0000 0000 - castling flag    - 0x80_0000

square = 63 -> 0b11_1111
piece  = 12 -> 0b1011 -> 0b1111
*/

encode_move :: proc(source, target, piece, promoted, capture, double, enpassant, castling: i32) -> i32 {
    return source | (target << 6) | (piece << 12) | (promoted << 16) |
     (capture << 20) | (double << 21) | (enpassant << 22) | (castling << 23)
}

get_move_source    :: proc(move :i32) -> i32 { return move & 0x3f }
get_move_target    :: proc(move :i32) -> i32 { return (move & 0x00_0fc0) >> 6 }
get_move_piece     :: proc(move :i32) -> i32 { return (move & 0x00_f000) >> 12 }
get_move_promoted  :: proc(move :i32) -> i32 { return (move & 0x0f_0000) >> 16 }
get_move_capture   :: proc(move :i32) -> i32 { return (move & 0x10_0000) >> 20 }
get_move_double    :: proc(move :i32) -> i32 { return (move & 0x20_0000) >> 21 }
get_move_enpassant :: proc(move :i32) -> i32 { return (move & 0x40_0000) >> 22 }
get_move_castling  :: proc(move :i32) -> i32 { return (move & 0x80_0000) >> 23 }


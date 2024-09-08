package bbc

import "core:fmt"

board_square :: enum {
    a8, b8, c8, d8, e8, f8, g8, h8,
    a7, b7, c7, d7, e7, f7, g7, h7,
    a6, b6, c6, d6, e6, f6, g6, h6,
    a5, b5, c5, d5, e5, f5, g5, h5,
    a4, b4, c4, d4, e4, f4, g4, h4,
    a3, b3, c3, d3, e3, f3, g3, h3,
    a2, b2, c2, d2, e2, f2, g2, h2,
    a1, b1, c1, d1, e1, f1, g1, h1,
}

/*
board_square2 :: enum {
    "a8", "b8", "c8", "d8", "e8", "f8", "g8", "h8",
    "a7", "b7", "c7", "d7", "e7", "f7", "g7", "h7",
    "a6", "b6", "c6", "d6", "e6", "f6", "g6", "h6",
    "a5", "b5", "c5", "d5", "e5", "f5", "g5", "h5",
    "a4", "b4", "c4", "d4", "e4", "f4", "g4", "h4",
    "a3", "b3", "c3", "d3", "e3", "f3", "g3", "h3",
    "a2", "b2", "c2", "d2", "e2", "f2", "g2", "h2",
    "a1", "b1", "c1", "d1", "e1", "f1", "g1", "h1",
}
*/

get_bit :: proc(bitboard, square: u64) -> bool {
    return (bitboard & (1 << square)) > 0
}

set_bit :: proc( bitboard: ^u64, square: board_square ) {
     bitboard^ |= ( 1 << u64(square) )
}

pop_bit :: proc( bitboard: ^u64, square: board_square ) {
    if get_bit(bitboard^, u64(square))  {
        bitboard^ ~= (1 << u64(square))
    }
}

// print bitboard
print_bitboard :: proc(bitboard: u64) {
    for rank := 0; rank < 8 ; rank += 1 {
        for file := 0; file < 8 ; file += 1 {
            // convert file & rank into square index
            square := rank * 8 + file

            if file == 0 {
                fmt.printf("  %v ", 8 - rank )
            }

            fmt.printf(" %v", get_bit(bitboard, u64(square) ) ? 1 : 0 )
        }
        fmt.println()
    }
    fmt.print ("\n     a b c d e f g h\n")
    fmt.printf("\n     Bitboard: %v\n\n", bitboard)
}


main :: proc() {

    bitboard: u64
    set_bit( &bitboard, .e4 )
    set_bit( &bitboard, .c3 )
    set_bit( &bitboard, .f2 )

    print_bitboard(bitboard)

    pop_bit( &bitboard, .e4 )
    pop_bit( &bitboard, .f2 )
    pop_bit( &bitboard, .f2 )
    print_bitboard(bitboard)

}

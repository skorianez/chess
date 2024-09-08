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

get_square :: proc( square : board_square) -> u64 {
    return u64(square)
}

white :: 0
black :: 1

square_to_coordinates : []string = {
    "a8", "b8", "c8", "d8", "e8", "f8", "g8", "h8",
    "a7", "b7", "c7", "d7", "e7", "f7", "g7", "h7",
    "a6", "b6", "c6", "d6", "e6", "f6", "g6", "h6",
    "a5", "b5", "c5", "d5", "e5", "f5", "g5", "h5",
    "a4", "b4", "c4", "d4", "e4", "f4", "g4", "h4",
    "a3", "b3", "c3", "d3", "e3", "f3", "g3", "h3",
    "a2", "b2", "c2", "d2", "e2", "f2", "g2", "h2",
    "a1", "b1", "c1", "d1", "e1", "f1", "g1", "h1",
}


get_bit :: proc(bitboard, square: u64) -> bool {
    return (bitboard & (1 << square)) > 0
}

set_bit :: proc( bitboard: ^u64, square: u64 ) {
     bitboard^ |= ( 1 << square )
}

pop_bit :: proc( bitboard: ^u64, square: u64 ) {
    if get_bit(bitboard^, square)  {
        bitboard^ ~= (1 << square)
    }
}

count_bits :: proc(bitboard: u64) -> uint {
    count: uint
    bb := bitboard

    for ; bb > 0 ; {
        count += 1
        bb &= bb - 1
    }
    return count
}

get_ls1b_index :: proc(bitboard: u64) -> int {
    if bitboard == 0 { return -1 }
    return int(count_bits((bitboard & -bitboard) - 1 ))
}

// Attacks
not_a_file  :u64: 18374403900871474942
not_h_file  :u64: 9187201950435737471
not_hg_file :u64: 4557430888798830399
not_ab_file :u64: 18229723555195321596

pawn_attacks: [2][64]u64
knight_attacks: [64]u64
king_attacks: [64]u64

mask_pawn_attacks :: proc(side: int, square: u64 ) -> u64 {
    attacks, bitboard : u64
    set_bit( &bitboard, square)

    if( side == white ) {
        if ((bitboard >> 7) & not_a_file) != 0 { attacks |= (bitboard >> 7) }
        if ((bitboard >> 9) & not_h_file) != 0 { attacks |= (bitboard >> 9) }
    } else {
        if ((bitboard << 7) & not_h_file) != 0 { attacks |= (bitboard << 7) }
        if ((bitboard << 9) & not_a_file) != 0 { attacks |= (bitboard << 9) }
    }

    return attacks
}

mask_knight_attacks :: proc(square: u64) -> u64 {
    attacks, bitboard : u64
    set_bit( &bitboard, square)

    if ((bitboard >> 17) & not_h_file) != 0 { attacks |= (bitboard >> 17) }
    if ((bitboard >> 15) & not_a_file) != 0 { attacks |= (bitboard >> 15) }
    if ((bitboard >> 10) & not_hg_file) != 0 { attacks |= (bitboard >> 10) }
    if ((bitboard >> 6) & not_ab_file) != 0 { attacks |= (bitboard >> 6) }

    if ((bitboard << 17) & not_a_file) != 0 { attacks |= (bitboard << 17) }
    if ((bitboard << 15) & not_h_file) != 0 { attacks |= (bitboard << 15) }
    if ((bitboard << 10) & not_ab_file) != 0 { attacks |= (bitboard << 10) }
    if ((bitboard << 6) & not_hg_file) != 0 { attacks |= (bitboard << 6) }

    return attacks
}

mask_king_attacks :: proc(square: u64) -> u64 {
    attacks, bitboard : u64
    set_bit( &bitboard, square)

    if (bitboard >> 8) != 0 { attacks |= (bitboard >> 8) }
    if ((bitboard >> 9) & not_h_file) != 0 { attacks |= (bitboard >> 9) }
    if ((bitboard >> 7) & not_a_file) != 0 { attacks |= (bitboard >> 7) }
    if ((bitboard >> 1) & not_h_file) != 0 { attacks |= (bitboard >> 1) }

    if (bitboard << 8) != 0 { attacks |= (bitboard << 8) }
    if ((bitboard << 9) & not_a_file) != 0 { attacks |= (bitboard << 9) }
    if ((bitboard << 7) & not_h_file) != 0 { attacks |= (bitboard << 7) }
    if ((bitboard << 1) & not_a_file) != 0 { attacks |= (bitboard << 1) }

    return attacks
}

mask_bishop_attacks :: proc(square: u64) -> u64 {
    attacks: u64

    tr :int = int(square) / 8
    tf :int = int(square) % 8

    r := tr + 1; f := tf + 1
    for ; r <= 6 && f <= 6 ; f +=1 {
        attacks |= (1 << u64(r * 8 + f))
        r +=1
    }

    r = tr - 1; f = tf + 1
    for ; r >= 1 && f <= 6 ; f +=1 {
        attacks |= (1 << u64(r * 8 + f))
        r -=1
    }

    r = tr + 1; f = tf - 1
    for ; r <= 6 && f >= 1 ; f -=1 {
        attacks |= (1 << u64(r * 8 + f))
        r +=1
    }

    r = tr - 1; f = tf - 1
    for ; r >= 1 && f >= 1 ; f -=1 {
        attacks |= (1 << u64(r * 8 + f))
        r -=1
    }

    return attacks
}

bishop_attacks_on_the_fly :: proc(square, block: u64) -> u64 {
    attacks: u64

    tr :int = int(square) / 8
    tf :int = int(square) % 8

    r := tr + 1; f := tf + 1
    for ; r <= 7 && f <= 7 ; f +=1 {
        attacks |= (1 << u64(r * 8 + f))
        if ((1 << u64(r * 8 + f)) & block) > 0 { break }
        r +=1
    }

    r = tr - 1; f = tf + 1
    for ; r >= 0 && f <= 7 ; f +=1 {
        attacks |= (1 << u64(r * 8 + f))
        if ((1 << u64(r * 8 + f)) & block) > 0 { break }
        r -=1
    }

    r = tr + 1; f = tf - 1
    for ; r <= 7 && f >= 0 ; f -=1 {
        attacks |= (1 << u64(r * 8 + f))
        if ((1 << u64(r * 8 + f)) & block) > 0 { break }
        r +=1
    }

    r = tr - 1; f = tf - 1
    for ; r >= 0 && f >= 0 ; f -=1 {
        attacks |= (1 << u64(r * 8 + f))
        if ((1 << u64(r * 8 + f)) & block) > 0 { break }
        r -=1
    }

    return attacks
}

mask_rook_attacks :: proc(square: u64) -> u64 {
    attacks: u64

    tr :int = int(square) / 8
    tf :int = int(square) % 8

    for r := tr + 1 ; r <= 6; r += 1 { attacks |= 1 << u64(r * 8 + tf) }
    for r := tr - 1 ; r >= 1; r -= 1 { attacks |= 1 << u64(r * 8 + tf) }
    for f := tf + 1 ; f <= 6; f += 1 { attacks |= 1 << u64(tr * 8 + f) }
    for f := tf - 1 ; f >= 1; f -= 1 { attacks |= 1 << u64(tr * 8 + f) }

    return attacks
}

rook_attacks_on_the_fly :: proc(square, block: u64) -> u64 {
    attacks: u64

    tr :int = int(square) / 8
    tf :int = int(square) % 8

    for r := tr + 0 ; r <= 7; r += 1 {
        attacks |= 1 << u64(r * 8 + tf)
        if ((1 << u64(r * 8 + tf)) & block) > 0 { break }
    }
    for r := tr - 0 ; r >= 0; r -= 1 {
        attacks |= 1 << u64(r * 8 + tf)
        if ((1 << u64(r * 8 + tf)) & block) > 0 { break }
    }
    for f := tf + 0 ; f <= 7; f += 1 {
        attacks |= 1 << u64(tr * 8 + f)
        if ((1 << u64(tr * 8 + f)) & block) > 0 { break }
    }
    for f := tf - 0 ; f >= 0; f -= 1 {
        attacks |= 1 << u64(tr * 8 + f)
        if ((1 << u64(tr * 8 + f)) & block) > 0 { break }
    }

    return attacks
}


init_leapers_attacks :: proc() {
    for square := 0; square < 64 ; square += 1 {
        pawn_attacks[white][square] = mask_pawn_attacks(white, u64(square))
        pawn_attacks[black][square] = mask_pawn_attacks(black, u64(square))
        knight_attacks[square] = mask_knight_attacks(u64(square))
        king_attacks[square] = mask_king_attacks(u64(square))
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


set_occupancy :: proc(index, bits_in_mask :uint, attack_mask :u64) -> u64 {
    occupancy : u64
    am := attack_mask

    for count :uint= 0; count < bits_in_mask ; count += 1 {
        square := u64(get_ls1b_index(am))
        pop_bit( &am , square )
        if index & (1 << count) > 0 {
            occupancy |= (1 << square)
        }
    }

    return occupancy
}

main :: proc() {
    init_leapers_attacks()

    attack_mask := mask_rook_attacks( get_square(.a1))
    occupancy := set_occupancy( 4095, count_bits(attack_mask),attack_mask)

    print_bitboard(occupancy)
   // fmt.printf("coord: %v\n",  square_to_coordinates[ get_ls1b_index(block) ] )

}

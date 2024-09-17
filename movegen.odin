package bbc

import "core:fmt"

// Move Generation

generate_moves :: proc() {
    source_square, target_square : i32
    bitboard, attacks : u64

    for piece in P..<k {
        bitboard = bitboards[piece]
        
        // pawns and king castling
        if side == white {
            if piece == P {
                for bitboard > 0 {
                    source_square = get_ls1b_index(bitboard)
                    target_square = source_square - 8

                    if !(target_square < i32(board_square.a8)) && !get_bit(occupancies[both], target_square ) {
                        // pawn promotion
                        if source_square >= i32(board_square.a7)  && source_square <= i32(board_square.h7) {
                            fmt.printf("pawn promo: %s->%s\n", square_to_coordinates[source_square], square_to_coordinates[target_square])
                        } else {
                            // one square ahead
                            fmt.printf("pawn push: %s->%s\n", square_to_coordinates[source_square], square_to_coordinates[target_square])
                            // two square ahead
                            if (source_square >= i32(board_square.a2) && source_square <= i32(board_square.h2))  &&
                                !get_bit(occupancies[both], target_square - 8)                             {
                                
                                    fmt.printf("pawn double push: %s->%s\n", square_to_coordinates[source_square], square_to_coordinates[target_square -8 ])
                            }
                        }
                    }

                    pop_bit(&bitboard, source_square)
                }
            }
        } else {
            if piece == p {
                for bitboard > 0 {
                    source_square = get_ls1b_index(bitboard)
                    target_square = source_square + 8

                    if !(target_square > i32(board_square.h1)) && !get_bit(occupancies[both], target_square ) {
                        // pawn promotion
                        if source_square >= i32(board_square.a2)  && source_square <= i32(board_square.h2) {
                            fmt.printf("pawn promo: %s->%s\n", square_to_coordinates[source_square], square_to_coordinates[target_square])
                        } else {
                            // one square ahead
                            fmt.printf("pawn push: %s->%s\n", square_to_coordinates[source_square], square_to_coordinates[target_square])
                            // two square ahead
                            if (source_square >= i32(board_square.a7) && source_square <= i32(board_square.h7))  &&
                                !get_bit(occupancies[both], target_square + 8)                             {
                                
                                    fmt.printf("pawn double push: %s->%s\n", square_to_coordinates[source_square], square_to_coordinates[target_square + 8])
                            }
                        }
                    }
                    pop_bit(&bitboard, source_square)
                }
            }
        }

        // knight
        // bishop
        // rook
        // queen
        // king
    }
}
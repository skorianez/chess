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
                    attacks = pawn_attacks[side][source_square] & occupancies[black]
                    for attacks > 0 {
                        target_square = get_ls1b_index(attacks)

                        if source_square >= i32(board_square.a7)  && source_square <= i32(board_square.h7) {
                            fmt.printf("pawn capture promo: %s->%s\n", square_to_coordinates[source_square], square_to_coordinates[target_square])
                        } else {
                            // one square ahead
                            fmt.printf("pawn capture: %s->%s\n", square_to_coordinates[source_square], square_to_coordinates[target_square])
                        }    

                        pop_bit(&attacks, target_square)
                    }
                    // generate enpassant capures
                    if enpassant != i32(board_square.no_sq) {
                        enpassant_attacks := pawn_attacks[side][source_square] & ( 1 << u32(enpassant))
                        if enpassant_attacks > 0 {
                            target_enpassant := get_ls1b_index(enpassant_attacks)
                            fmt.printf("pawn enpassant: %s->%s\n", square_to_coordinates[source_square], square_to_coordinates[target_enpassant])
                        }
                    }

                    pop_bit(&bitboard, source_square)
                }
            }
            // Castling moves
            if piece == K {
                // king side castling
                if (castle & wk) > 0 {
                    if (!get_bit(occupancies[both], get_square(.f1))) &&
                    (!get_bit(occupancies[both], get_square(.g1))) {
                        // king and f1 cant be attacked
                        if (is_square_attacked(get_square(.e1), black) == 0)  &&
                        (is_square_attacked(get_square(.f1), black)== 0) {
                            fmt.printf("castle move e1g1\n")
                        }
                    }
                }
                // queen side castling
                if (castle & wq) > 0 {
                    if (!get_bit(occupancies[both], get_square(.d1))) &&
                    (!get_bit(occupancies[both], get_square(.c1))) &&
                    (!get_bit(occupancies[both], get_square(.b1))) {
                        // king and f1 cant be attacked
                        if (is_square_attacked(get_square(.e1), black) == 0)  &&
                        (is_square_attacked(get_square(.d1), black)== 0) {
                            fmt.printf("castle move e1c1\n")
                        }
                    }
                }
                
            }
        } else { //generate black moves
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
                                !get_bit(occupancies[both], target_square + 8){
                                    fmt.printf("pawn double push: %s->%s\n", square_to_coordinates[source_square], square_to_coordinates[target_square + 8])
                            }
                        }
                    }
                    //
                    attacks = pawn_attacks[side][source_square] & occupancies[white]
                    for attacks > 0 {
                        target_square = get_ls1b_index(attacks)

                        if source_square >= i32(board_square.a2)  && source_square <= i32(board_square.h2) {
                            fmt.printf("pawn capture promo: %s->%s\n", square_to_coordinates[source_square], square_to_coordinates[target_square])
                        } else {
                            // one square ahead
                            fmt.printf("pawn capture: %s->%s\n", square_to_coordinates[source_square], square_to_coordinates[target_square])
                        }    

                        pop_bit(&attacks, target_square)
                    }
                    // generate enpassant capures
                    if enpassant != i32(board_square.no_sq) {
                        enpassant_attacks := pawn_attacks[side][source_square] & ( 1 << u32(enpassant))
                        if enpassant_attacks > 0 {
                            target_enpassant := get_ls1b_index(enpassant_attacks)
                            fmt.printf("pawn enpassant: %s->%s\n", square_to_coordinates[source_square], square_to_coordinates[target_enpassant])
                        }
                    }
                    //
                    pop_bit(&bitboard, source_square)
                }
            }
            if piece == k {
                // king side castling
                if (castle & bk) > 0 {
                    if (!get_bit(occupancies[both], get_square(.f8))) &&
                    (!get_bit(occupancies[both], get_square(.g8))) {
                        // king and f1 cant be attacked
                        if (is_square_attacked(get_square(.e8), white) == 0)  &&
                        (is_square_attacked(get_square(.f8), white)== 0) {
                            fmt.printf("castle move e8g8\n")
                        }
                    }
                }
                // queen side castling
                if (castle & bq) > 0 {
                    if (!get_bit(occupancies[both], get_square(.d8))) &&
                    (!get_bit(occupancies[both], get_square(.c8))) &&
                    (!get_bit(occupancies[both], get_square(.B8))) {
                        // king and f1 cant be attacked
                        if (is_square_attacked(get_square(.e8), white) == 0)  &&
                        (is_square_attacked(get_square(.d8), white)== 0) {
                            fmt.printf("castle move e8c8\n")
                        }
                    }
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
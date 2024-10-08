package bbc

import "core:fmt"

// Move Generation

// C ENUM
ALL_MOVES     :: 0
ONLY_CAPTURES :: 1

/*
                           castling   move     in      in
                              right update     binary  decimal

 king & rooks didn't move:     1111 & 1111  =  1111    15

        white king  moved:     1111 & 1100  =  1100    12
  white king's rook moved:     1111 & 1110  =  1110    14
 white queen's rook moved:     1111 & 1101  =  1101    13
     
         black king moved:     1111 & 0011  =  1011    3
  black king's rook moved:     1111 & 1011  =  1011    11
 black queen's rook moved:     1111 & 0111  =  0111    7

*/

// castling constants
castling_rights : [64]i32 = {
    7, 15, 15, 15,  3, 15, 15, 11,
   15, 15, 15, 15, 15, 15, 15, 15,
   15, 15, 15, 15, 15, 15, 15, 15,
   15, 15, 15, 15, 15, 15, 15, 15,
   15, 15, 15, 15, 15, 15, 15, 15,
   15, 15, 15, 15, 15, 15, 15, 15,
   15, 15, 15, 15, 15, 15, 15, 15,
   13, 15, 15, 15, 12, 15, 15, 14,
}

generate_moves :: proc(move_list: ^Moves) {
    source_square, target_square : i32
    bitboard, attacks : u64

    // loop over all bitoboards
    for piece := i32(Piece.P); piece <= i32(Piece.k) ; piece += 1 {
        bitboard = bitboards[piece]

        // pawns and king castling
        if side == white {
            if piece == i32(Piece.P) {
                for bitboard > 0 {
                    source_square = get_ls1b_index(bitboard)
                    target_square = source_square - 8

                    if !(target_square < i32(board_square.a8)) && !get_bit(occupancies[both], target_square ) {
                        // pawn promotion
                        if source_square >= i32(board_square.a7)  && source_square <= i32(board_square.h7) {
                            add_move(move_list, encode_move(source_square, target_square, piece, i32(Piece.Q), 0,0,0,0))
                            add_move(move_list, encode_move(source_square, target_square, piece, i32(Piece.R), 0,0,0,0))
                            add_move(move_list, encode_move(source_square, target_square, piece, i32(Piece.B), 0,0,0,0))
                            add_move(move_list, encode_move(source_square, target_square, piece, i32(Piece.N), 0,0,0,0))
                        } else {
                            // one square ahead
                            add_move(move_list, encode_move(source_square, target_square, piece, 0, 0, 0, 0, 0))
                            // two square ahead
                            if (source_square >= i32(board_square.a2) && source_square <= i32(board_square.h2)) && 
                            !get_bit(occupancies[both], target_square - 8) {                     
                                add_move(move_list, encode_move(source_square, target_square - 8, piece, 0, 0, 1, 0, 0))
                            }
                        }
                    }
                    attacks = pawn_attacks[side][source_square] & occupancies[black]
                    for attacks > 0 {
                        target_square = get_ls1b_index(attacks)

                        if source_square >= i32(board_square.a7)  && source_square <= i32(board_square.h7) {
                            add_move(move_list, encode_move(source_square, target_square, piece, i32(Piece.Q), 1,0,0,0))
                            add_move(move_list, encode_move(source_square, target_square, piece, i32(Piece.R), 1,0,0,0))
                            add_move(move_list, encode_move(source_square, target_square, piece, i32(Piece.B), 1,0,0,0))
                            add_move(move_list, encode_move(source_square, target_square, piece, i32(Piece.N), 1,0,0,0))
                        } else {
                            // one square ahead <--
                            add_move(move_list, encode_move(source_square, target_square, piece, 0, 1,0,0,0))
                        }    

                        pop_bit(&attacks, target_square)
                    }
                    // generate enpassant capures
                    if enpassant != i32(board_square.no_sq) {
                        enpassant_attacks := pawn_attacks[side][source_square] & ( 1 << u32(enpassant))
                        if enpassant_attacks > 0 {
                            target_enpassant := get_ls1b_index(enpassant_attacks)
                            add_move(move_list, encode_move(source_square, target_enpassant, piece, 0, 1, 0, 1, 0))
                        }
                    }

                    pop_bit(&bitboard, source_square)
                }
            }
            // Castling moves
            if piece == i32(Piece.K) {
                // king side castling
                if (castle & wk) > 0 {
                    if (!get_bit(occupancies[both], i32(board_square.f1))) &&
                    (!get_bit(occupancies[both], i32(board_square.g1))) {
                        // king and f1 cant be attacked
                        if (is_square_attacked(i32(board_square.e1), black) == 0)  &&
                        (is_square_attacked(i32(board_square.f1), black)== 0) {
                            add_move(move_list, encode_move(i32(board_square.e1), i32(board_square.g1), piece, 0, 0, 0, 0, 1))
                        }
                    }
                }
                // queen side castling
                if (castle & wq) > 0 {
                    if (!get_bit(occupancies[both], i32(board_square.d1))) &&
                    (!get_bit(occupancies[both], i32(board_square.c1))) &&
                    (!get_bit(occupancies[both], i32(board_square.b1))) {
                        // king and f1 cant be attacked
                        if (is_square_attacked(i32(board_square.e1), black) == 0)  &&
                        (is_square_attacked(i32(board_square.d1), black)== 0) {
                            add_move(move_list, encode_move(i32(board_square.e1), i32(board_square.c1), piece, 0, 0, 0, 0, 1))
                        }
                    }
                }
                
            }
        } else { //generate black moves
            if piece == i32(Piece.p) {
                for bitboard > 0 {
                    source_square = get_ls1b_index(bitboard)
                    target_square = source_square + 8

                    if !(target_square > i32(board_square.h1)) && !get_bit(occupancies[both], target_square ) {
                        // pawn promotion
                        if source_square >= i32(board_square.a2)  && source_square <= i32(board_square.h2) {
                            add_move(move_list, encode_move(source_square, target_square, piece, i32(Piece.q), 0, 0, 0, 0))
                            add_move(move_list, encode_move(source_square, target_square, piece, i32(Piece.r), 0, 0, 0, 0))
                            add_move(move_list, encode_move(source_square, target_square, piece, i32(Piece.b), 0, 0, 0 ,0))
                            add_move(move_list, encode_move(source_square, target_square, piece, i32(Piece.n), 0, 0, 0, 0))
                        } else {
                            // one square ahead
                            add_move(move_list, encode_move(source_square, target_square, piece, 0, 0, 0, 0, 0))
                            // two square ahead
                            if (source_square >= i32(board_square.a7) && source_square <= i32(board_square.h7))  &&
                                !get_bit(occupancies[both], target_square + 8){
                                    add_move(move_list, encode_move(source_square, target_square + 8, piece, 0, 0, 1, 0, 0))
                            }
                        }
                    }
                    //
                    attacks = pawn_attacks[side][source_square] & occupancies[white]
                    for attacks > 0 {
                        target_square = get_ls1b_index(attacks)

                        if source_square >= i32(board_square.a2)  && source_square <= i32(board_square.h2) {
                            add_move(move_list, encode_move(source_square, target_square, piece, i32(Piece.q), 1, 0, 0, 0))
                            add_move(move_list, encode_move(source_square, target_square, piece, i32(Piece.r), 1, 0, 0, 0))
                            add_move(move_list, encode_move(source_square, target_square, piece, i32(Piece.b), 1, 0, 0, 0))
                            add_move(move_list, encode_move(source_square, target_square, piece, i32(Piece.n), 1, 0, 0, 0))
                        } else {
                            // one square ahead
                            add_move(move_list, encode_move(source_square, target_square, piece, 0, 1, 0, 0, 0))
                        }    

                        pop_bit(&attacks, target_square)
                    }
                    // generate enpassant capures
                    if enpassant != i32(board_square.no_sq) {
                        enpassant_attacks := pawn_attacks[side][source_square] & ( 1 << u32(enpassant))
                        if enpassant_attacks > 0 {
                            target_enpassant := get_ls1b_index(enpassant_attacks)
                            //fmt.printf("%s%s pawn enpassant\n", square_to_coordinates[source_square], square_to_coordinates[target_enpassant])
                            add_move(move_list, encode_move(source_square, target_enpassant, piece, 0, 1, 0, 1, 0))
                        }
                    }
                    //
                    pop_bit(&bitboard, source_square)
                }
            }
            if piece == i32(Piece.k) {
                // king side castling
                if (castle & bk) > 0 {
                    if (!get_bit(occupancies[both], i32(board_square.f8))) &&
                    (!get_bit(occupancies[both], i32(board_square.g8))) {
                        // king and f1 cant be attacked
                        if (is_square_attacked(i32(board_square.e8), white) == 0)  &&
                        (is_square_attacked(i32(board_square.f8), white)== 0) {
                            add_move(move_list, encode_move(i32(board_square.e8), i32(board_square.g8), piece, 0, 0, 0, 0, 1))
                        }
                    }
                }
                // queen side castling
                if (castle & bq) > 0 {
                    if (!get_bit(occupancies[both], i32(board_square.d8) )) &&
                    (!get_bit(occupancies[both], i32(board_square.c8) )) &&
                    (!get_bit(occupancies[both], i32(board_square.B8) )) {
                        // king and f1 cant be attacked
                        if (is_square_attacked(i32(board_square.e8), white) == 0)  &&
                        (is_square_attacked(i32(board_square.d8), white)== 0) {
                            add_move(move_list, encode_move(i32(board_square.e8), i32(board_square.c8), piece, 0, 0, 0, 0, 1))
                        }
                    }
                }                
            }
        }
        // knight
        if side == white ? piece == i32(Piece.N) : piece == i32(Piece.n) {
            for bitboard > 0 {
                source_square = get_ls1b_index(bitboard)
                attacks = knight_attacks[source_square] & ((side == white) ? ~occupancies[white] : ~occupancies[black])
                for attacks > 0 {
                    target_square = get_ls1b_index(attacks)
                    if !get_bit((side == white? occupancies[black]:occupancies[white]), target_square ) {
                        add_move(move_list, encode_move(source_square, target_square, piece, 0, 0, 0, 0, 0))
                    } else {
                        add_move(move_list, encode_move(source_square, target_square, piece, 0, 1, 0, 0, 0))
                    }
                    pop_bit(&attacks, target_square)
                }
                pop_bit(&bitboard, source_square)
            }
        }
        // bishop
        if side == white ? piece == i32(Piece.B) : piece == i32(Piece.b) {
            for bitboard > 0 {
                source_square = get_ls1b_index(bitboard)
                attacks = get_bishop_attacks(source_square,occupancies[both])  & ((side == white) ? ~occupancies[white] : ~occupancies[black])
                for attacks > 0 {
                    target_square = get_ls1b_index(attacks)
                    if !get_bit((side == white? occupancies[black]:occupancies[white]), target_square ) {
                        add_move(move_list, encode_move(source_square, target_square, piece, 0, 0, 0, 0, 0))
                    } else {
                        add_move(move_list, encode_move(source_square, target_square, piece, 0, 1, 0, 0, 0))
                        //fmt.printf("%s%s piece capture\n", square_to_coordinates[source_square], square_to_coordinates[target_square])                        
                    }
                    pop_bit(&attacks, target_square)
                }
                pop_bit(&bitboard, source_square)
            }
        }
        // rook
        if side == white ? piece == i32(Piece.R) : piece == i32(Piece.r) {
            for bitboard > 0 {
                source_square = get_ls1b_index(bitboard)
                attacks = get_rook_attacks(source_square,occupancies[both])  & ((side == white) ? ~occupancies[white] : ~occupancies[black])
                for attacks > 0 {
                    target_square = get_ls1b_index(attacks)
                    if !get_bit((side == white? occupancies[black]:occupancies[white]), target_square ) {
                        add_move(move_list, encode_move(source_square, target_square, piece, 0, 0, 0, 0, 0))
                    } else {
                        add_move(move_list, encode_move(source_square, target_square, piece, 0, 1, 0, 0, 0))
                    }
                    pop_bit(&attacks, target_square)
                }
                pop_bit(&bitboard, source_square)
            }
        }
        // queen
        if side == white ? piece == i32(Piece.Q) : piece == i32(Piece.q) {
            for bitboard > 0 {
                source_square = get_ls1b_index(bitboard)
                attacks = get_queen_attacks(source_square,occupancies[both])  & ((side == white) ? ~occupancies[white] : ~occupancies[black])
                for attacks > 0 {
                    target_square = get_ls1b_index(attacks)
                    if !get_bit((side == white? occupancies[black]:occupancies[white]), target_square ) {
                        add_move(move_list, encode_move(source_square, target_square, piece, 0, 0, 0, 0, 0))
                    } else {
                        add_move(move_list, encode_move(source_square, target_square, piece, 0, 1, 0, 0, 0))
                    }
                    pop_bit(&attacks, target_square)
                }
                pop_bit(&bitboard, source_square)
            }
        }
        // king
        if side == white ? piece == i32(Piece.K) : piece == i32(Piece.k) {
            for bitboard > 0 {
                source_square = get_ls1b_index(bitboard)
                attacks = king_attacks[source_square] & ((side == white) ? ~occupancies[white] : ~occupancies[black])
                for attacks > 0 {
                    target_square = get_ls1b_index(attacks)
                    if !get_bit((side == white? occupancies[black]:occupancies[white]), target_square ) {
                        add_move(move_list, encode_move(source_square, target_square, piece, 0, 0, 0, 0, 0))
                    } else {
                        add_move(move_list, encode_move(source_square, target_square, piece, 0, 1, 0, 0, 0))
                    }
                    pop_bit(&attacks, target_square)
                }
                pop_bit(&bitboard, source_square)
            }
        }
    }
}

// TODO: change to return to bool?
make_move :: proc(move , move_flag :i32 ) -> i32 {
    if move_flag == ALL_MOVES {
        copy_board()

        // parse move
        source_square := get_move_source(move)
        target_square := get_move_target(move)
        piece := get_move_piece(move)
        promoted_piece := get_move_promoted(move)
        capture := get_move_capture(move)
        double_push := get_move_double(move)
        enpass := get_move_enpassant(move)
        castling := get_move_castling(move)

        // move piece
        pop_bit(&bitboards[piece], source_square)
        set_bit(&bitboards[piece], target_square)

        // handling capture moves
        if capture > 0 {
            start_piece, end_piece : i32
            if side == white {
                start_piece = i32(Piece.p)
                end_piece = i32(Piece.k)
            } else {
                start_piece = i32(Piece.P)
                end_piece = i32(Piece.K)
            }
            for bb_piece in start_piece..=end_piece {
                if get_bit(bitboards[bb_piece], target_square) {
                    pop_bit(&bitboards[bb_piece], target_square)
                    break
                }
            }
        }

        // handle pawn promotions
        if promoted_piece > 0 {
            pop_bit(&bitboards[side==white ? Piece.P : Piece.p], target_square)
            set_bit(&bitboards[promoted_piece], target_square)

        }

        // handle enpassant captures
        if enpassant > 0 {
            if side == white {
                pop_bit(&bitboards[Piece.p], target_square + 8)
            } else {
                pop_bit(&bitboards[Piece.P], target_square - 8) 
            }
        }

        // reset enpassant square
        enpassant = i32(board_square.no_sq)

        // handle double pawn push
        if double_push > 0 {
            if side == white {
                enpassant = target_square + 8
            } else {
                enpassant = target_square - 8
            }
        }

        // handle castling
        if castling > 0 {
            switch target_square {
                case i32(board_square.g1) :
                    pop_bit(&bitboards[Piece.R], i32(board_square.h1))
                    set_bit(&bitboards[Piece.R], i32(board_square.f1))
                case i32(board_square.c1) :
                    pop_bit(&bitboards[Piece.R], i32(board_square.a1))
                    set_bit(&bitboards[Piece.R], i32(board_square.d1))
                case i32(board_square.g8) :
                    pop_bit(&bitboards[Piece.r], i32(board_square.h8))
                    set_bit(&bitboards[Piece.r], i32(board_square.f8))
                case i32(board_square.c8) :
                    pop_bit(&bitboards[Piece.r], i32(board_square.a8))
                    set_bit(&bitboards[Piece.r], i32(board_square.d8))
            }
        }

        // update castling rights
        castle &= castling_rights[source_square]
        castle &= castling_rights[target_square]

        // update occupancies
        occupancies = {} //reset occupancies
        for bb_piece in Piece.P..=Piece.K {
            occupancies[white] |= bitboards[bb_piece]
        }
        for bb_piece in Piece.p..=Piece.k {
            occupancies[black] |= bitboards[bb_piece]
        }
        occupancies[both] |= occupancies[white]
        occupancies[both] |= occupancies[black]

        // change side
        side ~= 1

        // make sure that king has not been exposed into check
        king_square := get_ls1b_index(side == white ? bitboards[Piece.k] : bitboards[Piece.K])
        if is_square_attacked( king_square, side) > 0 {
            // move is illegal
            take_back()
            return 0
        }

        return 1

    } else {
        if get_move_capture(move) > 0 {
            make_move(move, ALL_MOVES)
        } else {
            return 0
        }
    }
    return 0
}

